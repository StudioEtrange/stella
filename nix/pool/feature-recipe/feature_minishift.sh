if [ ! "$_minishift_INCLUDED_" = "1" ]; then
_minishift_INCLUDED_=1

# openshift origin single-node cluster, inside a single VM on localhost
# https://github.com/jimmidyson/minishift

# example :
# minishift start --vm-driver=virtualbox
# eval $(minishift docker-env)
# minishift console
# <admin/admin>

# use with openshift origin client
# oc config set-context minishift
# oc login --username=admin --password=admin
# oc status

# oc run hello-minishift --image=gcr.io/google_containers/echoserver:1.4 --port=8080 --expose --service-overrides='{"apiVersion": "v1", "spec": {"type": "NodePort"}}'
# oc get pods


# use with docker
# docker ps




feature_minishift() {
	FEAT_NAME=minishift
	FEAT_LIST_SCHEMA="0_9_0:binary"
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="binary"
}

# with openshift origin 1.3.1
feature_minishift_0_9_0() {
	FEAT_VERSION=0_9_0
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL=https://github.com/jimmidyson/minishift/releases/download/v0.9.0/minishift-linux-amd64
		FEAT_BINARY_URL_FILENAME=minishift-0_9_0-linux-amd64
		FEAT_BINARY_URL_PROTOCOL=HTTP

	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL=https://github.com/jimmidyson/minishift/releases/download/v0.9.0/minishift-darwin-amd64
		FEAT_BINARY_URL_FILENAME=minishift-0_9_0-darwin-amd64
		FEAT_BINARY_URL_PROTOCOL=HTTP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/minishift
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"

}



feature_minishift_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "FORCE_NAME $FEAT_BINARY_URL_FILENAME"

	mv $FEAT_INSTALL_ROOT/$FEAT_BINARY_URL_FILENAME $FEAT_INSTALL_ROOT/minishift
	chmod +x $FEAT_INSTALL_ROOT/minishift

}


fi
