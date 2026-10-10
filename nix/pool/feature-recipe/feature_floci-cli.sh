if [ ! "$_FLOCI_CLI_INCLUDED_" = "1" ]; then
_FLOCI_CLI_INCLUDED_=1

# NOTE : floci-cli installs script only download binary (https://floci.io/install.sh)
# NOTE : JVM alternavite to binary download floci.jar in releasees : java -jar floci.jar version
# NOTE : floci alternative dashboard : https://github.com/ofsazib/floci-dash


# floci default command is floci aws
# floci config default-product <gcp | az | aws | oci>
# OCI = Oracle Cloud

# logs
# floci logs --follow  # stream live logs from floci container

# ----- AWS quick start -----
# floci aws start 		# Start Floci (AWS emulator)
# floci aws doctor 		# Check environment
# 			Export AWS env var AWS_ENDPOINT_URL="http://localhost:4566", AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION see https://github.com/floci-io/floci-cli#floci-env)
# eval $(floci env) 
# 			Use AWS services normally
# aws s3 mb s3://my-bucket
# aws dynamodb create-table --table-name users \
#  --attribute-definitions AttributeName=id,AttributeType=S \
#  --key-schema AttributeName=id,KeyType=HASH \
#  --billing-mode PAY_PER_REQUEST
# floci aws stop 		# Stop Floci

# ----- GCP quickstart -----
# floci gcp start		 # Start Floci GCP emulator
# floci gcp doctor		 # Check environment
# eval $(floci gcp env)  # Export GCP emulator host variables
# 					Use GCP services normally
# gcloud storage buckets create gs://my-bucket
# gcloud pubsub topics create my-topic
# floci gcp stop		 # Stop Floci GCP




feature_floci-cli() {
	FEAT_NAME="floci-cli"
	FEAT_LIST_SCHEMA="0_3_0@x64:binary"
	FEAT_DEFAULT_FLAVOUR="binary"
	FEAT_DESC="Floci CLI manages local cloud emulators"
	FEAT_LINK="https://github.com/floci-io/floci-cli https://github.com/floci-io/floci https://floci.io/"
}

feature_floci-cli_0_3_0() {
	FEAT_VERSION="0_3_0"

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://github.com/floci-io/floci-cli/releases/download/0.3.0/floci-linux-amd64"
			FEAT_BINARY_URL_FILENAME_x64="floci-linux-amd64-${FEAT_VERSION}"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP"
		fi
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
			FEAT_BINARY_URL_x64="https://github.com/floci-io/floci-cli/releases/download/0.3.0/floci-linux-arm64"
			FEAT_BINARY_URL_FILENAME_x64="floci-linux-arm64-${FEAT_VERSION}"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP"
		fi
	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://github.com/floci-io/floci-cli/releases/download/0.3.0/floci-darwin-amd64"
			FEAT_BINARY_URL_FILENAME_x64="floci-darwin-amd64-${FEAT_VERSION}"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP"
		fi
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
			FEAT_BINARY_URL_x64="https://github.com/floci-io/floci-cli/releases/download/0.3.0/floci-darwin-arm64"
			FEAT_BINARY_URL_FILENAME_x64="floci-darwin-arm64-${FEAT_VERSION}"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP"
		fi
	fi

	FEAT_INSTALL_TEST="${FEAT_INSTALL_ROOT}/floci"
	FEAT_SEARCH_PATH="${FEAT_INSTALL_ROOT}"
}

feature_floci-cli_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE FORCE_NAME $FEAT_BINARY_URL_FILENAME"
	mv "${FEAT_INSTALL_ROOT}/${FEAT_BINARY_URL_FILENAME}" "${FEAT_INSTALL_ROOT}/floci"
	chmod +x "${FEAT_INSTALL_ROOT}/floci"
}

fi
