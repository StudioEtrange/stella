if [ ! "$_LLMFIT_INCLUDED_" = "1" ]; then
_LLMFIT_INCLUDED_=1


feature_llmfit() {
	FEAT_NAME="llmfit"
	FEAT_LIST_SCHEMA="0_9_37@x64:binary"
	
	FEAT_DEFAULT_FLAVOUR="binary"

	FEAT_DESC="One command to find what models runs on your hardware. Hundreds of models & providers."
	FEAT_LINK="https://github.com/AlexsJones/llmfit"
}

feature_llmfit_0_9_37() {

	FEAT_VERSION="0_9_37"

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://github.com/AlexsJones/llmfit/releases/download/v0.9.37/llmfit-v0.9.37-x86_64-apple-darwin.tar.gz"
			FEAT_BINARY_URL_FILENAME_x64="llmfit-v0.9.37-x86_64-apple-darwin.tar.gz"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
			FEAT_BINARY_URL_x64="https://github.com/AlexsJones/llmfit/releases/download/v0.9.37/llmfit-v0.9.37-aarch64-apple-darwin.tar.gz"
			FEAT_BINARY_URL_FILENAME_x64="llmfit-v0.9.37-aarch64-apple-darwin.tar.gz"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://github.com/AlexsJones/llmfit/releases/download/v0.9.37/llmfit-v0.9.37-x86_64-unknown-linux-gnu.tar.gz"
			FEAT_BINARY_URL_FILENAME_x64="llmfit-v0.9.37-x86_64-unknown-linux-gnu.tar.gz"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
			FEAT_BINARY_URL_x64="https://github.com/AlexsJones/llmfit/releases/download/v0.9.37/llmfit-v0.9.37-aarch64-unknown-linux-gnu.tar.gz"
			FEAT_BINARY_URL_FILENAME_x64="llmfit-v0.9.37-aarch64-unknown-linux-gnu.tar.gz"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
	fi

	FEAT_ENV_CALLBACK=""

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/llmfit"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"
}




feature_llmfit_install_binary() {

	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP"
	

	
}








fi
