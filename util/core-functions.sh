
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
	RM_STATE=""
	VAR_OVERRIDE=""
	DRYRUN=false
	TERRAFORM_PATH=""
	MAXRETRIES=8
	SKIP_STATE_FOLDER_DELETION=true
	BACK_UP_STATE_FILE=false
	TFVARS=""

	while true; do
		case "$1" in
			--taint ) TAINT="$2"; shift 2;;
			--env ) ENVIRON="$2"; shift 2;;
			--region ) AWS_REG="$2"; shift 2;;
			--max-retries ) MAXRETRIES="$2"; shift 2;;
			--create ) CREATE=true; shift ;;
			--terminate ) TERMINATE=true; shift ;;
			--rm-state ) RM_STATE="$2"; shift 2;;
			--var-override ) VAR_OVERRIDE="$2"; shift 2;;
			--terraform-path ) TERRAFORM_PATH=$2; shift 2;;
			--dryrun ) DRYRUN=true; shift ;;
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
	local SCOPE="$1"
	local LAYER_RIPPLE="$2"
	local MODE="$3"
	# Get our list of layers and their dependencies on other layers, and write them to a file.
	python create_layer_dependencies.py
	
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

	echo "$CREATE_EXECUTION_LIST"
	
	if [[ "$CREATE_EXECUTION_LIST" == "true" ]]; then
		# Do not allow "resuming" or "excluding" when layer auto-calculation is on. We want the full thing to run cleanly.
		local LOCAL_LAYER_RIPPLE="$LAYER_RIPPLE"
		
		if [[ "$AUTO_CALCULATE_LAYERS" == "true" ]]; then
			LOCAL_START_LAYER=""
			LOCAL_STOP_AT_LAYER=""
			LOCAL_LAYER_RIPPLE="downstream"
		fi
		echo "$SCOPE"
		echo $MODE
		echo $LOCAL_LAYER_RIPPLE

		LAYER_CHAIN=$(python create_layer_execution_list.py "$SCOPE" "$MODE" "$LOCAL_LAYER_RIPPLE")
		echo $LAYER_CHAIN
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

		# Do the Terraform plan and see what shakes out.
		set +e
                
		terraform plan -no-color -out=plan.out -input=false \
			-var environment=${ENVIRON} -var aws_region=${AWS_REG} -var max_retries=${MAXRETRIES} \
			$RUN_PARAMETERS $SPLIT_VAR_OVERRIDE | tee tf.out

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
