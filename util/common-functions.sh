function get_terraform_state_region() { echo "us-east-1"; }
function get_terraform_state_bucket() { echo "${STATE_BUCKET}"; }

# Terraform state folders
function get_network_state_folder() { echo "${ENVIRON}/${AWS_REG}/layer-network"; }
function get_database_state_folder() { echo "${ENVIRON}/${AWS_REG}/layer-database"; }
function get_compute_state_folder() { echo "${ENVIRON}/${AWS_REG}/layer-compute"; }
function get_identity_state_folder() { echo "${ENVIRON}/${AWS_REG}/layer-identity"; }
function get_app_state_folder() { echo "${ENVIRON}/${AWS_REG}/layer-app"; }
function get_web_state_folder() { echo "${ENVIRON}/${AWS_REG}/layer-web"; }
function get_elb_state_folder() { echo "${ENVIRON}/${AWS_REG}/layer-elb"; }
function get_networking_rules_state_folder() { echo "${ENVIRON}/${AWS_REG}/layer-networking-rules"; }

TERRAFORM_CONFIG_FILE="terraform_config.tf"

LAYER_NETWORK_STATE_FILE="terraform-network.tfstate"
LAYER_DATABASE_STATE_FILE="terraform-database.tfstate"
LAYER_COMPUTE_STATE_FILE="terraform-compute.tfstate"
LAYER_IDENTITY_STATE_FILE="terraform-identity.tfstate"
LAYER_APP_STATE_FILE="terraform-app.tfstate"
LAYER_WEB_STATE_FILE="terraform-web.tfstate"
LAYER_ELB_STATE_FILE="terraform-elb.tfstate"
LAYER_NETWORKING_RULES_STATE_FILE="terraform-networking-rules.tfstate"

function taint_or_remove() {
	set +e

	# Taint
	if [ "$TAINT" != "" ]; then
		TAINT=$(echo $TAINT | perl -pe "s# ##g" | perl -pe "s#,#\n#g")

		for t in $TAINT
		do
			MODULE=$(echo $t | cut -d ":" -f 1)
			RESOURCE=$(echo $t | cut -d ":" -f 2)

			if [ "$MODULE" == "$RESOURCE" ]; then
				terraform taint $RESOURCE
			else
				terraform taint -module=$MODULE $RESOURCE
			fi
		done
	fi

	# State removal
	if [ "$RM_STATE" != "" ]; then
		RM_STATE=$(echo $RM_STATE | perl -pe "s# ##g" | perl -pe "s#,#\n#g")

		for s in $RM_STATE
		do
			terraform state rm $s
		done
	fi

	set -e
}

function create_terraform_state_file_backup() {
	local LAYER_NAME=$1
	local BACKUP_FOLDER_NAME=$2
	local ECHO_FUNCTION=$3
	
	# We only will do backups in creation mode. Termination mode doesn't make much sense.
	if [[ "$CREATE" == "true" ]]; then
		# This is where the state file lives.
		local STATE_FOLDER=$(get_terraform_state_folder_for_layer $LAYER_NAME)
		local STATE_FILE=$(get_terraform_state_filename_for_layer $LAYER_NAME)

		# Does the state file exist yet?
		set +e
		
		aws s3 --region $(get_terraform_state_region) ls s3://$(get_terraform_state_bucket)/${STATE_FOLDER}/${STATE_FILE} > /dev/null 2>&1	&& STATE_FILE_EXISTS=1

		set -e
		
		# If there is a state file, then back it up.
		if [[ $STATE_FILE_EXISTS == 1 ]]; then
			$ECHO_FUNCTION "Backing up state file '${STATE_FILE}' to 's3://$(get_terraform_state_bucket)/${STATE_FOLDER}/${BACKUP_FOLDER_NAME}'..."
			
			aws s3 cp --region $(get_terraform_state_region) "s3://$(get_terraform_state_bucket)/${STATE_FOLDER}/${STATE_FILE}" "s3://$(get_terraform_state_bucket)/${STATE_FOLDER}/${BACKUP_FOLDER_NAME}/${STATE_FILE}" > /dev/null
		fi
	fi
}

function execute_terraform_init() {
	local ECHO_FUNCTION=$1
	
	$ECHO_FUNCTION "Initializing Terraform..."
	
	local ATTEMPT=1
	local MAX_ATTEMPTS=5
	local INIT_EXIT_CODE=0
	
	set +e
	
	while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
		$ECHO_FUNCTION "Attempt $ATTEMPT of $MAX_ATTEMPTS."
		
		# Try to initialize Terraform.
		terraform init -input=false
		
		INIT_EXIT_CODE=$?
		
		# If everything worked, or if we're past our limit, break out.
		if [[ $INIT_EXIT_CODE == 0 ]]; then
			break
		fi		
	
		# If we're not done yet, sleep a little bit before the next try.
		if [[ $ATTEMPT -ne $MAX_ATTEMPTS ]]; then
			layer_echo "Sleeping for $SLEEP_INTERVAL second(s) before the next attempt..."
			
			sleep $SLEEP_INTERVAL
		else
			# We're at our limit, so stop trying.
			break
		fi
		
		# Next attempt.
		((ATTEMPT++))
	done
	
	set -e
	
	# Return the last exit code from trying to initialize Terraform.
	return $INIT_EXIT_CODE
}

# Dynamic Terraform functions

function create_terraform_configuration_file() {
	local ECHO_FUNCTION=$1
	local LAYER=$2

	# Validation
	if [[ "${STATEFOLDER}" == "" || "${STATEFILE}" == "" ]]; then
		$ECHO_FUNCTION "The STATEFOLDER and/or the STATEFILE variable is empty. Both must have valid values."

		return 1
	fi

	cat - > $TERRAFORM_CONFIG_FILE <<EOF
terraform {
	backend "s3" {
		region  = "$(get_terraform_state_region)"
		bucket  = "$(get_terraform_state_bucket)"
		key     = "${STATEFOLDER}/${STATEFILE}"
	}
}
EOF

	append_layer_dependencies_remote_state $ECHO_FUNCTION $LAYER

}

function append_generic_terraform_state() {
	cat - >> $TERRAFORM_CONFIG_FILE <<EOF

data "terraform_remote_state" "$1" {
	backend = "s3"
	config {
		region = "$(get_terraform_state_region)"
		bucket = "$(get_terraform_state_bucket)"
		key = "$2"
	}
}
EOF
}

function get_terraform_state_folder_for_layer() {
	local LAYER_NAME=$1

	# Depending on the layer's name, use convention to derive its state folder.
	# There are some special exceptions for a couple layer0 instances (for now).
	if [[ "$LAYER_NAME" == "layer_network" ]]; then
		echo $(get_network_state_folder)
	elif [[ "$LAYER_NAME" == "layer_identity" ]]; then
		echo $(get_identity_state_folder)
	elif [[ "$LAYER_NAME" == "layer_database" ]]; then
		echo $(get_database_state_folder)
	elif [[ "$LAYER_NAME" == "layer_compute" ]]; then
		echo $(get_compute_state_folder)
	elif [[ "$LAYER_NAME" == "layer_app" ]]; then
		echo $(get_app_state_folder)
	elif [[ "$LAYER_NAME" == "layer_web" ]]; then
		echo $(get_web_state_folder)
	elif [[ "$LAYER_NAME" == "layer_elb" ]]; then
		echo $(get_elb_state_folder)
	elif [[ "$LAYER_NAME" == "layer_networking_rules" ]]; then
		echo $(get_networking_rules_state_folder)
	else
		layer_echo "Could not determine a Terraform state folder for layer '$LAYER_NAME'."
		return 127;
	fi
}

function get_terraform_state_filename_for_layer() {
	local LAYER_NAME=$1
	local LAYER_UPCASE="$(echo ${LAYER_NAME} | tr [a-z] [A-Z])"
	local STATE_FILE_VAR_NAME="${LAYER_UPCASE}_STATE_FILE"

	STATE_FILE_VALUE=$(eval "echo \$$STATE_FILE_VAR_NAME")
	echo $STATE_FILE_VALUE
}

function append_layer_dependencies_remote_state() {
	local ECHO_FUNCTION=$1
	local DEPENDENCIES=$(cat ../layer_dependencies.json | jq -r ".dependencies.${LAYER} | @csv" | sed 's/"//g' | sed 's/,/ /g')

	$ECHO_FUNCTION "Layer dependencies: $DEPENDENCIES"

	if [[ ! -z "$DEPENDENCIES" ]]; then
	# For each layer this layer depends on, append the remote state for it.
		for DEPENDENCY in $DEPENDENCIES
		do
			# If there is an explicit function for this layer to append its state, call it.
			local APPEND_FUNCTION="append_${DEPENDENCY}_terraform_state"

			if [[ $(type -t "$APPEND_FUNCTION") == "function" ]]; then
				eval "$APPEND_FUNCTION"
			else
				# Otherwise, call a generic function.
				local STATE_FOLDER=$(get_terraform_state_folder_for_layer $DEPENDENCY)
				local STATE_FILE=$(get_terraform_state_filename_for_layer $DEPENDENCY)

				append_generic_terraform_state "$DEPENDENCY" "${STATE_FOLDER}/${STATE_FILE}"
			fi
		done
	fi
}