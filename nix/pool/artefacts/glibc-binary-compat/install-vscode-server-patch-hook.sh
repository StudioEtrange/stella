#!/usr/bin/env bash
# install patch VS Code server mechanism
set -eu

# --- Config ---
VSCODE_SERVER_ROOT="${HOME}/.vscode-server"


CUSTOM_GLIBC_PATH="${VSCODE_SERVER_CUSTOM_GLIBC_PATH:-/opt/custom-glibc228-runtime}"
CUSTOM_GLIBC_LINKER="${VSCODE_SERVER_CUSTOM_GLIBC_LINKER:-/opt/custom-glibc228-runtime/lib/ld-linux-x86-64.so.2}"

PATCH_WORKSPACE="$HOME/.patch-workspace/$(basename "${VSCODE_SERVER_ROOT}")"
SCRIPT_FOLDER="$(cd -- "$(dirname -- "$0")" && pwd)"

ACTION="${1:-install}"

BEGIN_MARK="# >>> vscode-server-patch >>>"
END_MARK="# <<< vscode-server-patch <<<"
		
SSH_RC="$HOME/.ssh/rc"

install_patchelf() {
	echo "install patchelf"
	mkdir -p "$PATCH_WORKSPACE/patchelf"
	cd "$PATCH_WORKSPACE/patchelf"
	rm -f "patchelf-0.18.0-x86_64.tar.gz"
	wget --no-check-certificate "https://github.com/NixOS/patchelf/releases/download/0.18.0/patchelf-0.18.0-x86_64.tar.gz" || return 1
	tar -zxvf "patchelf-0.18.0-x86_64.tar.gz" 1>/dev/null || return 1
	rm -f "patchelf-0.18.0-x86_64.tar.gz"
}


uninstall_hook_in_rc() {
	if [ -f "$SSH_RC" ]; then
		tmp_file="$(mktemp)"
		awk -v begin="$BEGIN_MARK" -v end="$END_MARK" ' 
			$0 == begin { skip=1; next } 
			$0 == end { skip=0; next } !skip 
		' "$SSH_RC" > "$tmp_file" && mv "$tmp_file" "$SSH_RC"
		rm -f "$tmp_file"
	fi
}


case "$ACTION" in
	"install")
		# install patchelf
		PATCHELF="$PATCH_WORKSPACE/patchelf/bin/patchelf"
		PATH="$PATCH_WORKSPACE/patchelf/bin:$PATH"
		if [ -x "$PATCHELF" ]; then
    			echo "patchelf is already installed"
		else
			if ! install_patchelf; then
				echo "ERROR: error on patchelf install" >&2
				exit 1
			fi
		fi
		# check patchelf exists and is executable
		if ! command -v "patchelf" >/dev/null 2>&1; then
			echo "ERROR: patchelf not found" >&2
			exit 1
		fi

		echo "disable vs code server requirements check"
		if [ ! -f "/tmp/vscode-skip-server-requirements-check" ]; then
			touch /tmp/vscode-skip-server-requirements-check || true
			chmod 777 /tmp/vscode-skip-server-requirements-check
		fi

		echo "install vs code patch system hook in $HOME/.ssh/rc file"
		uninstall_hook_in_rc

		[ -d "$HOME/.ssh" ] || { mkdir -p "$HOME/.ssh"; chmod 700 "$HOME/.ssh"; }
		[ -f "$SSH_RC" ] || { touch "$SSH_RC"; chmod 600 "$SSH_RC"; }
		if ! grep -Fq "$BEGIN_MARK" "$SSH_RC"; then
    		{
				echo "$BEGIN_MARK"
				echo "export CUSTOM_GLIBC_PATH=\"$CUSTOM_GLIBC_PATH\""
				echo "export CUSTOM_GLIBC_LINKER=\"$CUSTOM_GLIBC_LINKER\""
				echo "mkdir -p \"$PATCH_WORKSPACE\" 1>/dev/null 2>&1 || true"
				echo "\"$SCRIPT_FOLDER/patch-with-custom-glibc.sh\" \"node\" \"$VSCODE_SERVER_ROOT\" 1>\"$PATCH_WORKSPACE/patch.log\" 2>&1 || true"
				echo "$END_MARK" 
			} >> "$SSH_RC"
		fi

		echo "installation done"
		;;

	"uninstall")
		if [ ! -f "/tmp/vscode-skip-server-requirements-check" ]; then
			rm -f /tmp/vscode-skip-server-requirements-check || true
		fi

		uninstall_hook_in_rc
		
		
		echo "uninstallation done"
		;;	
	*) 
		echo "Usage :"
		echo "$0 install|uninstall"	
		;;

esac


exit 0

