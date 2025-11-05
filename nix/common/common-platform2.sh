
# Helper: append a path at the end of a colon-separated list if not yet in list
# DOES NOT force absolute, DOES NOT check existence
# $1 = current list
# $2 = candidate path
__path_append_any() {
  local list="$1"
  local p="$2"

  [ -z "$p" ] && { printf '%s' "$list"; return; }

  case ":$list:" in
    *:"$p":*)
      printf '%s' "$list"
      ;;
    *)
      if [ -n "$list" ]; then
        printf '%s:%s' "$list" "$p"
      else
        printf '%s' "$p"
      fi
      ;;
  esac
}

# Helper: append a path only if directory exists
__path_append_if_dir() {
  local list="$1"
  local p="$2"

  [ -z "$p" ] && { printf '%s' "$list"; return; }
  [ -d "$p" ] || { printf '%s' "$list"; return; }

  case ":$list:" in
    *:"$p":*)
      printf '%s' "$list"
      ;;
    *)
      if [ -n "$list" ]; then
        printf '%s:%s' "$list" "$p"
      else
        printf '%s' "$p"
      fi
      ;;
  esac
}

# add all lines from STDIN (one per line) into colon list $1
__path_append_list_from_stdin() {
  local list="$1" line
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    list="$(__path_append_any "$list" "$line")"
  done
  printf '%s' "$list"
}

# add all lines from a list (one by line)
__path_append_from_list() {
  local list="$1"; shift
  local IFS=$'\n' # preserve line with spaces
  local line
  for line in "$@"; do
    [ -n "$line" ] || continue
    list="$(__path_append_any "$list" "$line")"
  done
  printf '%s' "$list"
}

# Helper: get Darwin SDK path
# 1. use SDKROOT if set
# 2. else use xcrun --sdk macosx --show-sdk-path
# 3. else empty
__darwin_get_sdkroot() {
  if [ -n "${SDKROOT:-}" ]; then
    printf '%s' "$SDKROOT"
    return
  fi
  if command -v xcrun >/dev/null 2>&1; then
    xcrun --sdk macosx --show-sdk-path 2>/dev/null && return 0
  fi
  return 1
}

# ----------------------------- AT RUNTIME/RUN TIME -------------

# order of search - reading LC_LOAD_DYLIB
# 1.check dependency if absolute path (i.e : /usr/lib/libSystem.B.dylib) - could be in dyld cache or on disk
# 2.if present in LC_LOAD_DYLIB value try to solve @rpath, @loader_path, @executable_path
# 3 DYLD_LIBRARY_PATH (if not disabled by apple security SIP)
# 4 DYLD_FALLBACK_LIBRARY_PATH (if not disabled by apple security SIP) or its default values : $HOME/lib:/usr/local/lib:/usr/lib
# NOTE : this function do not extract the paths from dyld cache
__darwin_default_search_library_paths_at_runtime() {
  local res=""
  local p

  # from DYLD_LIBRARY_PATH
  if [ -n "${DYLD_LIBRARY_PATH:-}" ]; then
    IFS=:; for p in $DYLD_LIBRARY_PATH; do
      # here we keep only existing dirs, runtime should be real
      res="$(__path_append_if_dir "$res" "$p")"
    done
    unset IFS
  fi

  # fallback (or default)
  local fb="${DYLD_FALLBACK_LIBRARY_PATH:-$HOME/lib:/usr/local/lib:/usr/lib}"
  IFS=:; for p in $fb; do
    res="$(__path_append_if_dir "$res" "$p")"
  done
  unset IFS

  printf '%s\n' "$(printf '%s' "$res" | tr ':' '\n')"
}

# order of search - reading LC_LOAD_DYLIB
# 1.check dependency if absolute path (i.e : /System/Library/Frameworks/CoreFoundation.framework/CoreFoundation) - could be in dyld cache or on disk
# 2.if present in LC_LOAD_DYLIB value try to solve @rpath, @loader_path, @executable_path
# 3 DYLD_FRAMEWORK_PATH (if not disabled by apple security SIP)
# 4 DYLD_FALLBACK_FRAMEWORK_PATH (if not disabled by apple security SIP) or its default values : $HOME/Library/Frameworks:/Library/Frameworks:/Network/Library/Frameworks:/System/Library/Frameworks
# NOTE : this function do not extract the paths from dyld cache
__darwin_default_search_framework_paths_at_runtime() {
  local res=""
  local p

  # DYLD_FRAMEWORK_PATH
  if [ -n "${DYLD_FRAMEWORK_PATH:-}" ]; then
    IFS=:; for p in $DYLD_FRAMEWORK_PATH; do
      res="$(__path_append_if_dir "$res" "$p")"
    done
    unset IFS
  fi

  # fallback (or default)
  local fb="${DYLD_FALLBACK_FRAMEWORK_PATH:-$HOME/Library/Frameworks:/Library/Frameworks:/Network/Library/Frameworks:/System/Library/Frameworks}"
  IFS=:; for p in $fb; do
    res="$(__path_append_if_dir "$res" "$p")"
  done
  unset IFS

  printf '%s\n' "$(printf '%s' "$res" | tr ':' '\n')"
}


__linux_default_search_library_paths_at_runtime() {
	# inspired by lddtree : https://github.com/StudioEtrange/lddtree/blob/579ebe449b76ed9d22f116a6f30b87b1f2ded2ca/lddtree.sh#L169
	read_ldso_conf() {
		local __depth="${__depth:-0}"
		[ "$__depth" -gt 20 ] && return 0
		__depth=$((__depth+1))

		local p line
		for p in "$@"; do
			# Fichier lisible ?
			[ -r "$p" ] || continue

			while IFS= read -r line || [ -n "$line" ]; do
				# Enlever commentaires en fin de ligne (# ...)
				# (simple, ne gère pas les # échappés — suffisant ici)
				line=${line%%\#*}

				# Trim spaces
				line=${line#"${line%%[![:space:]]*}"}
				line=${line%"${line##*[![:space:]]}"}

				# bypass empty lines
				[ -z "$line" ] && continue
				case $line in
					include[[:space:]]*)
						# Extraire motif après "include"
						set -- ${line#include}
						# $@ contient maintenant le motif (éventuellement avec glob)
						# Laisser le glob s'étendre volontairement (non quoté)
						read_ldso_conf $__depth "$@"
						;;
					*)
						# Première "colonne" seulement (au cas où)
						# (ld.so.conf n'attend qu'un chemin par ligne)
						set -- $line
						local path=$1

						# Normaliser: garantir un seul / en tête
						case $path in
							/*) : ;;
							*) path="/$path" ;;
						esac

						# Garder seulement les répertoires existants
						if [ -d "$path" ]; then
							# Ajouter sans créer de ":" initial
							case ":$c_ldso_paths:" in
								*:"$path":*) : ;;     # déjà présent → ignorer
								*)
									if [ -n "$c_ldso_paths" ]; then
										c_ldso_paths="$c_ldso_paths:$path"
									else
										c_ldso_paths="$path"
									fi
									;;
							esac
						fi
						;;
				esac
			done < "$p"
		done
	}

	# inspired by lddtree : https://github.com/StudioEtrange/lddtree/blob/579ebe449b76ed9d22f116a6f30b87b1f2ded2ca/lddtree.sh#L184
	if [ -r /etc/ld.so.conf ] ; then
		# the 'include' can be relative
		local _oldpwd="$(pwd)"
		cd "/etc" >/dev/null
		interp=$(__get_elf_interpreter_linux "$(type -P ls 2>/dev/null)")
		case "$interp" in
			*/ld-musl-*)
				# muslc
				musl_arch=${interp%.so*}
				musl_arch=${musl_arch##*-}
				read_ldso_conf /etc/ld-musl-${musl_arch}.path
				;;
			*/ld-linux*|*/ld.so*)
				# glibc
				read_ldso_conf /etc/ld.so.conf
				;;
		esac
		cd "$_oldpwd"
	fi
}

__default_search_library_paths_at_runtime() {
	case $STELLA_CURRENT_PLATFORM in
		darwin)
			__darwin_default_search_library_paths_at_runtime
		;;
		linux)
			__linux_default_search_library_paths_at_runtime
		;;
	esac
}


# retrieve in solving order all search path for libraries at RUNTIME
# if a binary is in arg, then runtime path hardcoded in binary will also be returned into the result
__search_library_paths_at_runtime() {
	local binary="$1"
	case $STELLA_CURRENT_PLATFORM in
		darwin)
			# 1. extract LC_RPATH and add its value as a rpath, which will be used when looking for library
			[ -f "$binary" ] && __get_rpath "$binary" | tr -s '[:space:]' '\n'
			# 2 DYLD_* PATHs
			__darwin_default_search_library_paths_at_runtime
		;;

		linux)
			# TODO
			# 0. extract DT_RPATH (but printed in step 2 because __get_rpath return DT_RPATH and DT_RUNPATH together)
			# 1. LD_LIBRARY_PATH
			[ ! -z $LD_LIBRARY_PATH ] && printf '%s\n' "$(printf '%s' "$LD_LIBRARY_PATH" | sed 's/:/\n/g')"
			# 2. extract DT_RUNPATH which will be used when looking for library
			[ -f "$binary" ] && __get_rpath "$binary" | tr -s '[:space:]' '\n'
			# 3.__default_runtime_search_path
			# __default_runtime_search_path # TODO REIMPLEMENT THIS
		;; 
	esac
	
}

# ----------------------------- AT BUILD TIME -------------
__darwin_default_search_framework_paths_at_buildtime() {
  local res=""
  local arg p

  # 1. SDKROOT
  local sdk
  if ! sdk="$(__darwin_get_sdkroot)"; then
	# ALTERNATIVE : __gcc_default_search_framework_paths_at_buildtime if xcrun do not exist
	# NOTE : gcc method is not complete, do not add other Frameworks path
	path="$(__gcc_default_search_framework_paths_at_buildtime)"
	res="$(__path_append_any "$res" "$path")"
	sdk="$(echo $path | sed 's,/System/Library/Frameworks.*,,')"
  fi
  if [ -n "$sdk" ]; then
    res="$(__path_append_any "$res" "$sdk/System/Library/Frameworks")"
    res="$(__path_append_any "$res" "$sdk/Library/Frameworks")"
  fi

  # 2. host defaults (these should exist on real macOS, but we still check)
  res="$(__path_append_if_dir "$res" "$HOME/Library/Frameworks")"
  res="$(__path_append_if_dir "$res" /Library/Frameworks)"
  res="$(__path_append_if_dir "$res" /Network/Library/Frameworks)"
  res="$(__path_append_if_dir "$res" /System/Library/Frameworks)"

  printf '%s\n' "$(printf '%s' "$res" | tr ':' '\n')"
}

# it is a hack because rgcc -Xlinker -vr alwayrs generate an error we ignore to get information
# method used as an alternative in __darwin_default_search_framework_paths_at_buildtime
__gcc_default_search_framework_paths_at_buildtime() {
	case $STELLA_CURRENT_PLATFORM in
		linux);;
		darwin)
			gcc -Xlinker -v 2>&1 \
				| awk '
				/^Library search paths:/ {lib=1; fw=0; next}
				/^Framework search paths:/ {lib=0; fw=1; next}
				fw && $0 ~ /^[[:space:]]+\// { sub(/^[[:space:]]+/,""); print }
				'
		;;
	esac
}


# default library search paths during linking at build time  (linker path)
__darwin_default_search_library_paths_at_buildtime() {
  local res=""
  local arg p
  local expect_L=0

  # 2. SDKROOT
  local sdk
  if ! sdk="$(__darwin_get_sdkroot)"; then
	# NOTE : for darwin gcc method is not complete, do not add /usr/local/lib
  	res="$(__gcc_default_search_library_paths_at_buildtime)"
	return $?
  fi
  if [ -n "$sdk" ]; then
    # standard places inside SDK
    res="$(__path_append_any "$res" "$sdk/usr/local/lib")"
    res="$(__path_append_any "$res" "$sdk/usr/lib")"
  fi

  # 3. system defaults if they exists
  res="$(__path_append_if_dir "$res" /usr/local/lib)"
  res="$(__path_append_if_dir "$res" /usr/lib)"

  printf '%s\n' "$(printf '%s' "$res" | tr ':' '\n')"
}


# default gcc/ld library search paths during linking at build time (linker path)
# it is a hack because gcc -Xlinker -v alwayrs generate an error we ignore to get information
# method used as an alternative in __darwin_default_search_library_paths_at_buildtime
__gcc_default_search_library_paths_at_buildtime() {
	case $STELLA_CPU_ARCH in
		"64")
			__arch="-m64"
		;;
		"32")
			__arch="-m32"
		;;
	esac
	
	case $STELLA_CURRENT_PLATFORM in
		linux)
			# ALTERNATIVE FOR LINUX : use ld : __ld_default_search_library_paths_at_buildtime
			gcc $__arch -Xlinker --verbose  2>/dev/null | grep SEARCH | sed 's/SEARCH_DIR("=\?\([^"]\+\)"); */\1\n/g'  | grep -vE '^$'
		;;

		darwin)
			gcc $__arch -Xlinker -v 2>&1 \
				| awk '
				/^Library search paths:/ {lib=1; fw=0; next}
				/^Framework search paths:/ {lib=0; fw=1; next}
				lib && $0 ~ /^[[:space:]]+\// { sub(/^[[:space:]]+/,""); print }
				'
		;;

	esac
}

# gcc hardcoded libraries search path when linking
# gcc passes a few extra -L paths to the linker, which you can list with the following command:
# 		linux & darwin : https://stackoverflow.com/a/21610523/5027535
#		darwin : https://opensource.apple.com/source/dyld/dyld-519.2.1/src/dyld.cpp.auto.html
__gcc_extra_search_library_paths_at_buildtime() {
	local __arch=""
	case $STELLA_CPU_ARCH in
		"64")
			__arch="-m64"
		;;
		"32")
			__arch="-m32"
		;;
	esac
	
	if [ "${STELLA_CURRENT_PLATFORM}" = "linux" ]; then
		gcc -print-search-dirs $__arch \
		| sed '/^lib/b 1;d;:1;s,/[^/.][^/]*/\.\./,/,;t 1;s,:[^=]*=,:;,;s,;,;  ,g; s/^libraries:[[:space:]]*;[[:space:]]*//' \
		| tr : '\n'
	elif [ "${STELLA_CURRENT_PLATFORM}" = "darwin" ]; then
		gcc -print-search-dirs $__arch \
		| sed -n 's/^libraries:[[:space:]]*\(=\)\{0,1\}[[:space:]]*//p' \
		| tr ':' '\n' \
		| sed -E '/^$/d; s|/+$/||; s|(/lib)?$|/lib|'
	fi
}

# default gcc/ld library search paths during linking at build time (linker path)
# https://stackoverflow.com/a/21610523/5027535
# ld is the linker only on linux
# existing alternative : __gcc_default_search_library_paths_at_buildtime
__ld_default_search_library_paths_at_buildtime() {
	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		case $STELLA_CPU_ARCH in
			"64")
				__arch="-m elf_x86_64"
			;;
			"32")
				__arch="-m elf_i386"
			;;
		esac
		ld --verbose $__arch 2>/dev/null \
			| grep SEARCH \
			| sed 's/SEARCH_DIR("=\?\([^"]\+\)"); */\1\n/g' \
			| grep -vE '^$'
	fi
}




# library search paths during linking at build time (linker path)
# NOTE :
# 		linux : https://stackoverflow.com/questions/9922949/how-to-print-the-ldlinker-search-path
#		macos : https://opensource.apple.com/source/dyld/dyld-519.2.1/src/dyld.cpp.auto.html
#				harcoded values : https://opensource.apple.com/source/dyld/dyld-519.2.1/src/dyld.cpp.auto.html
__search_library_paths_at_buildtime() {
	local res="" p
	case "$STELLA_CURRENT_PLATFORM" in
		"darwin")
			# 1. LIBRARY_PATH
			if [ -n "${LIBRARY_PATH:-}" ]; then
				IFS=:; for p in $LIBRARY_PATH; do
					res="$(__path_append_any "$res" "$p")"
				done
				unset IFS
			fi
			
			# 2. hardcoded gcc search path
			res="$(__gcc_extra_search_library_paths_at_buildtime | __path_append_list_from_stdin "$res")"

			# 3. default lib search path
			res="$(__darwin_default_search_library_paths_at_buildtime | __path_append_list_from_stdin "$res")"

			printf '%s\n' "$(printf '%s' "$res" | tr ':' '\n')"
		;;

		"linux")
			# 1. LIBRARY_PATH
			if [ -n "${LIBRARY_PATH:-}" ]; then
				IFS=:; for p in $LIBRARY_PATH; do
					res="$(__path_append_any "$res" "$p")"
				done
				unset IFS
			fi

			# 2. hardcoded gcc search path
			res="$(__gcc_extra_search_library_paths_at_buildtime | __path_append_list_from_stdin "$res")"

			# 3. default lib search path
			res="$(__gcc_default_search_library_paths_at_buildtime | __path_append_list_from_stdin "$res")"

			printf '%s\n' "$(printf '%s' "$res" | tr ':' '\n')"
		;;

	esac


}