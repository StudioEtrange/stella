if [ ! "$_minikube_INCLUDED_" = "1" ]; then
_minikube_INCLUDED_=1

# kubernetes single-node cluster, inside a single VM on localhost
# https://github.com/kubernetes/minikube
# https://medium.com/@claudiopro/getting-started-with-kubernetes-via-minikube-ada8c7a29620#.3hu5p2m7j

# example :
# minikube start --vm-driver=virtualbox
# eval $(minikube docker-env)
# minikube dashboard

# use with kubectl
# export KUBECONFIG=$HOME/.kube/config
# kubectl config use-context minikube
# kubectl run-container hello-minikube --image=gcr.io/google_containers/echoserver:1.4 --port=8080

# use with docker
# docker ps

feature_minikube() {
	FEAT_NAME=minikube
	FEAT_LIST_SCHEMA="0_11_0:binary"
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="binary"
}

# with kubernetes v1.4.0
feature_minikube_0_11_0() {
	FEAT_VERSION=0_11_0
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL=https://github.com/kubernetes/minikube/releases/download/v0.11.0/minikube-linux-amd64
		FEAT_BINARY_URL_FILENAME=minikube-0_11_0-linux-amd64
		FEAT_BINARY_URL_PROTOCOL=HTTP

	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL=https://github.com/kubernetes/minikube/releases/download/v0.11.0/minikube-darwin-amd64
		FEAT_BINARY_URL_FILENAME=minikube-0_11_0-darwin-amd64
		FEAT_BINARY_URL_PROTOCOL=HTTP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/minikube
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"

}



feature_minikube_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "FORCE_NAME $FEAT_BINARY_URL_FILENAME"

	mv $FEAT_INSTALL_ROOT/$FEAT_BINARY_URL_FILENAME $FEAT_INSTALL_ROOT/minikube
	chmod +x $FEAT_INSTALL_ROOT/minikube

}


fi
