
function layer_echo() {
	echo -e "[$(date '+%Y-%m-%d %H:%2M:%2S')] [$LAYER_NAME]: $1"
}

function layer_debug() {
	if [[ "$DEBUG" == "true" ]]; then
		layer_echo "[DEBUG]: $1"
	fi
}

function usage() {
	echo "--max-retries <n>: attempt <n> retries before exiting"
	echo "--parallelism <n>: adjust 'terraform plan' parallelism"
	echo "--taint <resources>: 'terraform taint' the provided resources (comma-separated list)"
	echo "--rm-state <modules>: 'terraform state rm' the provided resources (comma-separated list)"
	echo "--var-override: add override for one or more variables, e.g. '--var-override vpc_id=vpc-xxxxxxx' (comma separated list)"
	echo "--terraform-path <path to terraform>: a local path to the Terraform executable"
	echo "--help: shows this help"

	show-stack-help $STACKS
}

function parse_arguments() {

	TEMP=$(getopt -o v --long help,env:,region:,failback,dr-region:,create,terminate,max-retries:,taint:,rm-state:,var-override:,vars:,DR,dryrun,terraform-path:,skip-state-folder-deletion,back-up-state-file -n rlizone -- $@)

	eval set -- "$TEMP"

	FULL_CLI="$@"
	CREATE=false
	TERMINATE=false
	ENVIRON=""
	TAINT=""
	AWS_REG=""
	DR_AWS_REG=""
	FAILBACK=false
	RM_STATE=""
	VAR_OVERRIDE=""
	DRYRUN=false
	TERRAFORM_PATH=""
	MAXRETRIES=8
	SKIP_STATE_FOLDER_DELETION=true
	BACK_UP_STATE_FILE=false
	TFVARS=""
	ENV_TYPE="Primary"

	while true; do
		case "$1" in
			--taint ) TAINT="$2"; shift 2;;
			--env ) ENVIRON="$2"; shift 2;;
			--region ) AWS_REG="$2"; shift 2;;
			--max-retries ) MAXRETRIES="$2"; shift 2;;
			--dr-region ) DR_AWS_REG="$2"; shift 2;;
			--create ) CREATE=true; shift ;;
			--terminate ) TERMINATE=true; shift ;;
			--failback ) FAILBACK=true; shift ;;
			--rm-state ) RM_STATE="$2"; shift 2;;
			--var-override ) VAR_OVERRIDE="$2"; shift 2;;
			--terraform-path ) TERRAFORM_PATH=$2; shift 2;;
			--dryrun ) DRYRUN=true; shift ;;
			--DR ) ENV_TYPE="DR"; shift ;;
			--vars ) TFVARS="$2"; shift 2;;
			--skip-state-folder-deletion ) SKIP_STATE_FOLDER_DELETION=true; shift ;;
			--back-up-state-file ) BACK_UP_STATE_FILE=true; shift ;;
			--help ) usage; exit; shift ;;
			-- ) shift; break ;;
			* ) STACKARG="$STACKARG $1"; shift; continue; ;;
		esac
	done
	
	# In that specific case, we will overwrite the $SCOPE parameter to just be that layer.

	if [ "$TERRAFORM_PATH" != "" ]; then
		export PATH="${TERRAFORM_PATH}:$PATH"
	fi

	SPLIT_VAR_OVERRIDE=""

	if [ "$VAR_OVERRIDE" != "" ]; then
		SPLIT_VAR_OVERRIDE=$(echo "-var $VAR_OVERRIDE" | sed 's/,/ -var /g')
	fi
}

function clean_up_terraform_state_for_layer() {
	local LAYER_NAME=$1

	# Remove the state file for the layer.
	echo "Removing the state file for layer '${LAYER_NAME}'..."

	local STATE_FOLDER=$(get_terraform_state_folder_for_layer $LAYER_NAME)
	local STATE_FILE=$(get_terraform_state_filename_for_layer $LAYER_NAME)
	
	aws --region $(get_terraform_state_region) s3 rm "s3://$(get_terraform_state_bucket)/${STATE_FOLDER}/${STATE_FILE}" > /dev/null
	
	# If there are no files left in this folder, then the zone as a whole is terminated and there is some cleanup we can do.
	local FILES_LEFT=$(aws --region $(get_terraform_state_region) s3 ls s3://$(get_terraform_state_bucket)/${STATE_FOLDER}/ | grep -P "^\d{4}-\d{2}-\d{2}" | wc -l)
	
	if [[ $FILES_LEFT == 0 ]]; then
		# Remove the state file's folder.
		# Normally deleting all files in a folder automatically deletes the folder, but we might have state file backups in other folders, so we explicitly delete if we need to.
		if [[ "$SKIP_STATE_FOLDER_DELETION" == "false" ]]; then
			echo "Removing the S3 folder for environment '${STATE_FOLDER}'..."
		
			aws --region $(get_terraform_state_region) s3 rm "s3://$(get_terraform_state_bucket)/${STATE_FOLDER}/" --recursive > /dev/null
		fi	
	fi
}

function calculate_layer_dependencies() {
	# Get our list of layers and their dependencies on other layers, and write them to a file.
	python create_layer_dependencies.py

	# Figure out the list of layers to run, based on the layers given to rlizone and other options.
	local MODE=""

	if [ "$CREATE" == "true" ]; then
		MODE="create"
	elif [ "$TERMINATE" == "true" ]; then
		MODE="terminate"
	fi
	
	# This is so we control whether we should create a layer manifest to run.
	# There are circumstances where we will not want to.
	local CREATE_EXECUTION_LIST=false

	# If we wanted our layers automatically figured out for us, then do it.
	# If we didn't want them calculated, we'll always create a layer manifest.
	if [[ "$AUTO_CALCULATE_LAYERS" == "false" ]]; then
		CREATE_EXECUTION_LIST=true
	else
		echo "Auto-calculation mode detected."	
			
		# If we figured out there is something to do, then let's do it.
		if [[ ! -z "$SCOPE" ]]; then
			CREATE_EXECUTION_LIST=true				
		fi
	fi

	# This is the list of layer chains, i.e. "a,b,c d,e f".
	# This is what we will run, and in what order we will run it.
	LAYER_CHAIN=""
	
	if [[ "$CREATE_EXECUTION_LIST" == "true" ]]; then
		# Do not allow "resuming" or "excluding" when layer auto-calculation is on. We want the full thing to run cleanly.
		local LOCAL_START_AT_LAYER="$START_AT_LAYER"
		local LOCAL_STOP_AT_LAYER="$STOP_AT_LAYER"
		local LOCAL_LAYER_RIPPLE="$LAYER_RIPPLE"
		
		if [[ "$AUTO_CALCULATE_LAYERS" == "true" ]]; then
			LOCAL_START_LAYER=""
			LOCAL_STOP_AT_LAYER=""
			LOCAL_LAYER_RIPPLE="downstream"
		fi
		
		LAYER_CHAIN=$(python create_layer_execution_list.py "$SCOPE" "$MODE" "$LOCAL_LAYER_RIPPLE")
	fi
}

function execute_layers() {
	# This is a common variable to identify this run across all layers that might happen during the run.
	RUN_IDENTIFIER="$(uuidgen)"
	
	zone_echo "Run identifier: $RUN_IDENTIFIER"	

	# If layer auto-calculation was chosen, it is possible that there is nothing to process (no-op).
	# In that case, we do very little here.
	if [[ -z "$LAYER_CHAIN" ]]; then
		notify "There are no layers to run. This run is a no-op." ":white_check_mark:"
	else
		if [[ "$LAYER_GROUP" == "feature_zone" && "$BACK_UP_STATE_FILE" == "true" ]]; then
			# Make a backup of the state file for the feature zone before we run any layers in case we need to revert later.
			create_terraform_state_file_backup "layer_feature_zone" $RUN_IDENTIFIER zone_echo
		fi

		# These keys are used by multiple layers, so get them once and store them once.
		get_mongo_and_ansible_keys
		
		# Let the user know what we're going to be doing, and in what order.
		zone_echo
		zone_echo "Layer chains to execute:"
		
		local CHAIN_NUMBER=0
		local TOTAL_LAYERS=0
		
		for CHAIN in $LAYER_CHAIN; do
			((CHAIN_NUMBER += 1))
			
			zone_echo "  - [${CHAIN_NUMBER}]: $(echo $CHAIN | sed "s/,/, /g")"
			
			# Tally up the number of layers.
			local LAYER_ARRAY=($(csv_to_bash_array $CHAIN))
			
			((TOTAL_LAYERS += ${#LAYER_ARRAY[@]}))
		done
		
		zone_echo
		zone_echo "${TOTAL_LAYERS} layer(s) will be executed across ${CHAIN_NUMBER} layer chain(s)."
		zone_echo
		
		# Execute the layers in parallel if we are creating or terminating.
		if [[ "$CREATE" == "true" || "$TERMINATE" == "true" ]]; then
			# Figure out the longest layer name so we can dynamically size our report column.
			local LONGEST_LAYER=0
			
			for CHAIN in $LAYER_CHAIN; do
				for LAYER in $(csv_to_bash_array $CHAIN); do
					if [[ ${#LAYER} -gt $LONGEST_LAYER ]]; then
						LONGEST_LAYER=${#LAYER}
					fi
				done
			done
		
			# Create a results file that will be appended to by the individual layers, and shows our configuration.
			local LOG_FILE="__results.log"
			local LOG_FORMAT="%-$(($LONGEST_LAYER + 3))s%-22s%-22s%8s%12s"
			local LAYERS_EXECUTED=0
			
			printf "${LOG_FORMAT}\n" "Layer" "Started" "Ended" "Run Time" "Exit Code" > $LOG_FILE
			printf "${LOG_FORMAT}\n" "-----" "-------" "-----" "--------" "---------" >> $LOG_FILE
		
			# If there was a "--vars" value passed by rlizone, it is already inside "$FULL_CLI" and we don't have to forward it on.
			# But if there wasn't a "--vars" value passed, we need to pass the value of $TFVARS to layer-parallel.sh so all layers know about which file is now used.
			local VARS_ARGUMENT=""
					
			if [[ "$ORIGINAL_TFVARS_VALUE" == "" ]]; then
				VARS_ARGUMENT="--vars $TFVARS"
			fi
				
			# $LAYER_CHAIN will be something like "a,b,c d,e f". It is a bash array of CSVs, where each CSV is a list
			# of layers that can be executed in parallel, but each CSV in the array must be done sequentially.
			local LAST_CHAIN_EXIT_CODE=0
			local STARTED_PROCESSING=$(date +%s)
			
			CHAIN_NUMBER=0
			
			for LAYER_CSV in $LAYER_CHAIN; do
				((CHAIN_NUMBER += 1))
				
				local LAYER_ARRAY=($(csv_to_bash_array $LAYER_CSV))
				local LAYER_COUNT=${#LAYER_ARRAY[@]}
				
				zone_echo "Executing layer chain [${CHAIN_NUMBER}] -> $LAYER_COUNT layer(s)..."

				# If interleaved output was asked for, let it all write to the screen (not recommended).
				if [[ "$INTERLEAVED_OUTPUT" == "true" ]]; then
					LOG_OUTPUT="| tee {}.log"
				else
					LOG_OUTPUT="> {}.log"
				fi
				
				# Determine how many parallel operations we will allow for this chain. If not overridden, we will spin up one parallel operation per layer in the CSV.
				local LAYER_CHAIN_PARALLELISM=$LAYER_PARALLELISM
				
				if [[ "$LAYER_CHAIN_PARALLELISM" == "0" ]]; then
					LAYER_CHAIN_PARALLELISM=$LAYER_COUNT
					
					# Don't go nuts; we should implement a sensible cap.
					if [[ $LAYER_CHAIN_PARALLELISM -gt $MAX_LAYER_PARALLELISM ]]; then
						LAYER_CHAIN_PARALLELISM=$MAX_LAYER_PARALLELISM
					fi
				fi		
		
				# Execute each layer in the CSV in parallel.
				set +e			

				printf "%s\0" "${LAYER_ARRAY[@]}" | xargs -0 -n 1 -P $LAYER_CHAIN_PARALLELISM -i{} bash -c "set -eo pipefail; bash ./layer-parallel.sh {} $LOG_FILE \"$LOG_FORMAT\" $RUN_IDENTIFIER $VARS_ARGUMENT $FULL_CLI $LOG_OUTPUT 2>&1"
				
				LAST_CHAIN_EXIT_CODE=$?
				
				set -e
				
				# We executed X layers, so keep track of them.
				((LAYERS_EXECUTED += $LAYER_COUNT))
				
				zone_debug "Layer chain exit code: $LAST_CHAIN_EXIT_CODE"
				
				# We should stop the script if we had any errors, so echo back the last exit code.			
				if [[ $LAST_CHAIN_EXIT_CODE != 0 ]]; then
					break
				fi
			done
			
			local RIGHT_NOW=$(date +%s)
			local SCRIPT_DURATION=$(($RIGHT_NOW - $STARTED_PROCESSING))
			
			# Write out a report footer.
			printf "\n" >> $LOG_FILE
			printf "    Parallelism: %s\n" "$LAYER_PARALLELISM" >> $LOG_FILE
			printf "Script duration: %s\n" "$SCRIPT_DURATION" >> $LOG_FILE
			printf "Layers executed: %s\n" "$LAYERS_EXECUTED" >> $LOG_FILE
			printf "  Seconds/layer: %s" "$(echo $SCRIPT_DURATION $LAYERS_EXECUTED | awk '{ print $1 / $2 }')" >> $LOG_FILE
			
			# Did we succeed with all layer chains?
			zone_echo ""
			
			if [[ $LAST_CHAIN_EXIT_CODE == 0 ]]; then			
				notify "All layers executed successfully." ":white_check_mark:"
			else				
				notify "At least one layer failed. Review the '$LOG_FILE' log file for specifics." ":red_circle:"
				
				# We should stop the script if we had any errors, so echo back the last exit code.			
				return $LAST_CHAIN_EXIT_CODE
			fi
		fi

		# If we are in verification mode for the feature zone, execute it.
		if [[ "$VERIFY" == "true" && "$DRYRUN" == "false" ]]; then
			verify_feature_zone
		fi
	fi
}

function execute_layer() {
	local MODE=$1
	ATTEMPT=1

	layer_debug "Entering main layer logic section."

	layer_echo "Beginning Terraform 'plan'."

	# Keep trying until we succeed or fail too many times.
	while [ $ATTEMPT -le $MAXRETRIES ]; do
		layer_echo "Attempt $ATTEMPT of $MAXRETRIES."

		# Decide which parameters to use.
		RUN_PARAMETERS=""

		if [ $MODE == "create" ]; then
			RUN_PARAMETERS=$(get_create_parameters)
		else
			RUN_PARAMETERS="$(get_terminate_parameters) -destroy"
		fi

		# Run the Terraform "plan".
		layer_echo "Custom parameters: $RUN_PARAMETERS"
		echo ""

		taint_or_remove

		# Determine whether we give Terraform a variables file or not.
		local VAR_FILE=""


		if [[ -f "${TFVARS}.tfvars" ]]; then
			VAR_FILE="-var-file=${TFVARS}.tfvars"
		else
			layer_echo "Variables file '${TFVARS}.tfvars' could not be found for the layer."
			return 1
		fi

		# Do the Terraform plan and see what shakes out.
		set +e
                
		terraform plan -no-color -out=plan.out -input=false \
			-var environment=${ENVIRON} -var aws_region=${AWS_REG} -var failback="${FAILBACK}" -var max_retries=${MAXRETRIES} \
			$VAR_FILE $RUN_PARAMETERS $SPLIT_VAR_OVERRIDE | tee tf.out

		PLAN_EXIT_CODE=$?

		set -e

		layer_debug "Terraform 'plan' exit code: $PLAN_EXIT_CODE"

		echo ""

		# Did we succeed?
		if [[ $PLAN_EXIT_CODE -eq 0 ]]; then
			layer_echo "Terraform 'plan' succeeded."

			# Run the Terraform "apply" if desired.
			if [[ "$DRYRUN" == "true" ]]; then
				layer_echo "Skipping Terraform 'apply' due to 'dry run' mode."

				break
			else
				layer_echo "Beginning Terraform 'apply'."
				echo ""

				set +e

				terraform apply -no-color plan.out | tee tf.out

				APPLY_EXIT_CODE=$?

				set -e

				layer_debug "Terraform 'apply' exit code: $APPLY_EXIT_CODE"
				echo ""

				# Did we succeed?
				if [[ $APPLY_EXIT_CODE -eq 0 ]]; then
					layer_echo "Terraform 'apply' successful."

					return 0
				else
					layer_echo "Terraform 'apply' encountered errors."
				fi
			fi
		fi

		# Next attempt.
		((ATTEMPT++))
	done

	# For termination, remove the remote state now that the layer is gone.
	if [ $MODE == "terminate" ] && [ $DRYRUN == "false" ]; then
		layer_echo "Removing Terraform state file due to termination succeeding."

		aws --region $(get_terraform_state_region) s3 rm "s3://$(get_terraform_state_bucket)/$(get_terraform_state_folder)/$(get_state_filename)"
	fi

	# Success!
	return 0
}

function clean_workspace() {
	rm -f plan.out
	rm -f tf.out
	rm -f tf.out.1
	rm -rf .terraform
	rm -f state.tf
	rm -f terraform.tfstate
}
