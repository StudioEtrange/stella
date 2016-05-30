if [ ! "$_STELLA_LIB_BINARY_INCLUDED_" == "1" ]; then
_STELLA_LIB_BINARY_INCLUDED_=1

# LINUX & MACOS :
# 		hexdump -- not always present by default (see ubuntu official docker image)
# 		od -- should always be present ?
# BINARY HEADER :
# 		LINUX ELF :   https://android.googlesource.com/platform/art/+/master/runtime/elf.h
# 									https://github.com/gentoo/pax-utils/blob/master/elf.h
# 		MACOS MACHO : https://github.com/gentoo/pax-utils/blob/master/macho.h
# 									http://llvm.org/docs/doxygen/html/Support_2MachO_8h_source.html
# 									http://stackoverflow.com/q/27669766
# 									http://lowlevelbits.org/parse-mach-o-files/
# 		MACOS MACHO Universal Binary (contains several arch)
# 									http://cocoaintheshell.whine.fr/2009/07/universal-binary-mach-o-format/
# 									https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/MachORuntime/
#     UNIX ARCHIVE (.a) HEADER :
#                   https://en.wikipedia.org/wiki/Ar_(Unix)
# LINUX ELF : info
# 		http://linux-audit.com/elf-binaries-on-linux-understanding-and-analysis/

# MACOS test files :
# MACHO UNIVERSAL
# ./stella.sh boot cmd local -- '__info_bin /usr/lib/libtkstub8.5.a'
# ARCHIVE
# ./stella.sh boot cmd local -- '__info_bin /usr/lib/libQMIParser.a'



# # Mach O ------------------------------------------------------
# -------------
# ELF Header
# -------------
# Data
# -------------


# # Mach O ------------------------------------------------------
# -------------
# Mach O Header
# -------------
# Data
# -------------
# struct mach_header {
#   uint32_t      magic;
#   cpu_type_t    cputype;
#   cpu_subtype_t cpusubtype;
#   uint32_t      filetype;
#   uint32_t      ncmds;
#   uint32_t      sizeofcmds;
#   uint32_t      flags;
# };
#

# # Mach O Universal Binary ---------------------------------------
# -------------
# Fat Header + X Fat Arch
# -------------
# File for architecture 1
# -------------
# File for architecture 2
# -------------
# struct fat_header
# {
#     uint32_t magic;
#     uint32_t nfat_arch;
# };
# struct fat_arch
# {
#     cpu_type_t cputype;
#     cpu_subtype_t cpusubtype;
#     uint32_t offset;
#     uint32_t size;
#     uint32_t align;
# };
#
#
# # File Archive ----------------------------------------------------
# -------------
# AR Header (only magic ID)
# ----------------
# AR Object Header
# ----------------
# File 1
# ----------------
# AR Object Header
# ----------------
# File 2

# AR Header
# Offset	Length	Desc 						Format
# 0				8				Magic						213C617263683E0A

# AR Object Header
# Offset	Length	Desc 						Format
# 0				16	File name						ASCII
# 16			12	File modification timestamp	Decimal
# 28			6		Owner ID						Decimal
# 34			6		Group ID						Decimal
# 40			8		File mode						Octal
# 48			10	File size in bytes	Decimal
# 58			2		File magic					600A


__MACHO_HEADER_SIZE__=28
__FAT_HEADER_SIZE__=8
__FAT_ARCH_SIZE__=20
__MACHO_UNIVERSAL_HEADER_SIZE__=$((__FAT_HEADER_SIZE__ + 4 * __FAT_ARCH_SIZE__))
__AR_HEADER_SIZE__=8
__AR_OBJECT_HEADER_SIZE__=60
# we extend ar object header for SYSTEM V wich put object name after header
__AR_OBJECT_HEADER_EXTENDED_SIZE__=100
__ELF_HEADER_SIZE__=20

# GENERIC ---------------------------------------------------------------
function __info_bin() {
	local _file="$1"
  local _result=0


	__require "od" "coreutils" "SYSTEM"

  local _type_bin="$(__type_bin "$_file")" || return 1
	echo "Format : $_type_bin"

  case $_type_bin in
    FILE_MACHO)
    	__info_macho "$_file"
    ;;
    FILE_MACHO_UNIVERSAL)
    	__info_macho_universal "$_file"
    ;;
    FILE_ELF)
			__info_elf "$_file"
    ;;
    FILE_AR)
			__info_ar "$_file"
    ;;
    *)
			echo "Generic Header : $(__get_generic_magic_bin "$_file")"
      _result=1
      ;;
  esac

	return $_result
}

# we need offset and size in case of we are inside a macho Univeral Binary which may contains several archive
function __info_ar() {
	local _file="$1"
	local _offset="$2"
	local _size="$3"
	# HEADER ---
	local _header="$(__ar_header "$_file" "$_offset")"
	echo "Header : $_header"
	# MAGIC ---
	echo "Magic : $(__ar_magic "$_header")"
	# ENDIAN ---
	echo "Endian : $(__ar_endian)"
	# NB OBJ ---
	local _nbobj=$(__ar_nb_object "$_file" "$_offset" "$_size")
	echo "Nb object : $_nbobj"
	# TODO : __ar_global_arch ?
	#echo "Global Arch : $(__ar_global_arch "$_file")"
	local _ar_object_header
	local _obj_pos
	local _data_pos
	local i
	for ((i=1; i<=$_nbobj; i++)) {
		echo "----*---- OBJ #$i ----*----"
		# HEADER ---
		_ar_object_header="$(__ar_object_header "$_file" "$i" "$_offset")"
		# NAME ---
		printf "Name : $(__ar_object_name "$_ar_object_header")"
		# SIZE ---
		printf "\t Size : $(__ar_object_size "$_ar_object_header")"
		# POS ---
		_obj_pos=$(__ar_object_pos "$_file" "$i" "$_offset")
		printf "\t Object pos : $_obj_pos"
		_data_pos=$(__ar_object_data_pos "$_file" "$i" "$_offset")
		printf "\t Data file pos : $_data_pos"
		echo
		# EMBEDDED FILE --
		echo "-*-Embedded-*-"
		_format="$(__type_bin "$_file" "$((_data_pos))")"
		echo "Format : $_format"
		if [ "$_format" == "FILE_MACHO" ]; then
			__info_macho "$_file" "$_data_pos"
		fi
		if [ "$_format" == "FILE_ELF" ]; then
			__info_elf "$_file" "$_data_pos"
		fi
	}
}

function __info_macho() {
	local _file="$1"
	local _offset="$2"
	[ "$_offset" = "" ] && _offset=0
	# HEADER ---
	local _header="$(__macho_header "$_file" "$_offset")"
	echo "Header : $_header"
	# MAGIC and ENDIAN ---
	echo "Magic : $(__macho_magic "$_header")"
	echo "Endian : $(__macho_endian "$_header")"
	# CPU TYPE ---
	echo "CPU Type : $(__macho_cputype "$_header")"
	# CPU SUBTYPE ---
	echo "CPU SubType : $(__macho_cpusubtype "$_header")"
	# FILETYPE ---
	echo "File Type : $(__macho_filetype "$_header")"
}

function __info_macho_universal() {
	local _file="$1"
	# HEADER ---
	echo "This is an Universal Binary"
	local _header="$(__macho_universal_header "$_file")"
	echo "Header (FAT) : $_header"
	# MAGIC and ENDIAN ---
	echo "Magic : $(__macho_magic "$_header")"
	echo "Endian : $(__macho_endian "$_header")"
	# NB ARCH ---
	_nb_arch=$(__macho_universal_nbarch  "$_header")
	echo "Nb arch supported : $_nb_arch"
	echo "Global File Type : $(__macho_universal_global_filetype "$_file")"
	echo
	local _pos
	local _arch_header
	local _ar_header
	local _format
	local _size
	local i
	for ((i=1; i<=$_nb_arch; i++)) {
		echo "----*---- ARCH #$i ----*----"
		# CPU TYPE ---
		echo "CPU Type : $(__macho_universal_cputype "$_header" "$i")"
		# CPU SUBTYPE ---
		echo "CPU SubType : $(__macho_universal_cpusubtype "$_header" "$i")"
		# POSITION ---
		_pos=$(__macho_universal_position "$_header" "$i")
		echo "Offset : $_pos"
		# SIZE ---
		_size=$(__macho_universal_size "$_header" "$i")
		echo "Size : $_size"
		# EMBEDDED FILE --
		echo "-*-Embedded-*-"
		# FORMAT ---
		_format="$(__type_bin "$_file" "$_pos ")"
		echo "Format : $_format"
		if [ "$_format" == "FILE_MACHO" ]; then
			__info_macho "$_file" "$_pos"
		fi
		if [ "$_format" == "FILE_AR" ]; then
			__info_ar "$_file" "$_pos" "$_size"
		fi
		echo
	}
}

function __info_elf() {
	local _file="$1"
	local _offset="$2"
	# HEADER ---
	local _header="$(__elf_header "$_file" "$_offset")"
	echo "Header : $_header"
	# MAGIC ---
	echo "Magic : $(__elf_magic "$_header")"
	# CLASS ---
	echo "Class : $(__elf_class "$_header")"
	# DATA and ENDIAN
	echo "Data : $(__elf_data "$_header")"
	local _endian="$(__elf_endian "$_header")"
	echo "Endian : $_endian"
	# VERSION (we skip this) (field 6)
	# OS/ABI
	echo "OS/ABI : $(__elf_osabi "$_header")"
	# ABI version
	echo "ABI Version : $(__elf_abiver "$_header")"
	# FILE TYPE
	echo "File type : $(__elf_filetype "$_header")"
	# MACHINE
	echo "Machine : $(__elf_machine "$_header")"
}

function __type_bin() {
  local _file="$1"
  # Usefull to read files in archive
  local _offset="$2"
  [ "$_offset" == "" ] && _offset=0
  local _result=0

  local _generic_magic="$(__get_generic_magic_bin "$_file" "$_offset")"
  local _type="FILE_UNKNOWN"

  local _type
  _type=$(__macho_magic "$_generic_magic" "FORMAT") || \
  _type=$(__elf_magic "$_generic_magic" "FORMAT") || \
  _type=$(__ar_magic "$_generic_magic" "FORMAT") || \
  _type="FILE_UNKNOWN"

  echo "$_type"
  return $_result
}

function __is_macho_universal() {
  local _file="$1"
  local _result=1
  [[ "$(__type_bin "$_file")" =~ FILE_MACHO_UNIVERSAL ]] && _result=0
  return $_result
}

function __is_macho() {
  local _file="$1"
  local _result=1
  [[ "$(__type_bin "$_file")" =~ FILE_MACHO ]] && _result=0
  return $_result
}

function __is_elf() {
  local _file="$1"
  local _result=1
  [[ "$(__type_bin "$_file")" =~ FILE_ELF ]] && _result=0
  return $_result
}

# ar format used for static lib
function __is_archive() {
  local _file="$1"
  local _result=1
  [[ "$(__type_bin "$_file")" =~ FILE_AR ]] && _result=0
  return $_result
}



# INTERNAL ---------------------------------------------------------------
# extract bytes from file
function __extract_raw_bin() {
  local _file="$1"
  local _size="$2"
  local _offset="$3"

	[ -f "$_file" ] || return 1

  [ "$_offset" == "" ] && _offset=0
  local _head=$(__trim $(od -v -j $_offset -A none -t x1 -N $_size "$_file") | tr '[:lower:]' '[:upper:]')
  echo "${_head// /}"
  return 0
}


# extract enough bytes from file to get file signature
function __get_generic_magic_bin() {
  local _file="$1"
  local _offset="$2"
  local _result=0
  # macho magic size 4
  # macho-universal magic size 4
  # elf magic size 4
  # ar magic size 8
  local _max_magic_size=8
  [ "$_offset" == "" ] && _offset=0
  local _raw_magic="$(__extract_raw_bin "$_file" "$_max_magic_size" "$_offset")" || _result=$?

  echo "$_raw_magic"
  return $_result
}


# build a bash array from a string representing raw bytes
# NOTE : return an array - use it like this
#       local head=( $(__build_header file) )
#       http://stackoverflow.com/a/10589820
function __build_array_bin() {
  local _raw_bin="$1"
  #local _size="$2"
  local _result=0
  local _size=${#_raw_bin}
  _size=$(( _size / 2 ))
  local pattern=
	local i
  for ((i=1; i<=$_size; i++)) {
    pattern="([a-zA-Z0-9][a-zA-Z0-9])$pattern"
  }
  pattern='^'$pattern'$'
  [[ "$_raw_bin" =~ $pattern ]] || _result=1

  local _array=( ${BASH_REMATCH[*]} )
  unset _array[0]
  echo "${_array[*]}"

  return $_result
}

# give an ordered string of bytes
# with regard to endianness
function __get_ordered_bin() {
	local _raw_bin="$1"
	local _endian="$2"
	# starting position
	local _offset="$3"
	# nb of bytes
	local _size="$4"
	local _ordered_bin
  local _array_bin=( $(__build_array_bin "$_raw_bin") )
	local i
	for ((i=0; i<$_size; i++)) {
		[ "$_endian" == "BIG" ] && _ordered_bin="$_ordered_bin${_array_bin[$((_offset + i))]}" || \
		_ordered_bin="${_array_bin[$((_offset + i))]}$_ordered_bin"
	}

	echo "$_ordered_bin"
}


function __print_ascii_code() {
	echo -e "$(echo "$1" | sed 's/\(..\)/\\x\1/g')"
}

# AR FORMAT ---------------------------------------------------------------
function __ar_header() {
  local _file="$1"
	local _offset="$2"
  local _size=$__AR_HEADER_SIZE__
	[ "$_offset" == "" ] && _offset=0
  local _raw_header="$(__extract_raw_bin "$_file" "$_size" "$_offset")"  || _result=$?
  echo "$_raw_header"
  return 0
}

function __ar_magic() {
  local _header="$1"
	local _opt="$2"
  # FORMAT -- return file format
  # KEY -- return magic key [DEFAULT]
  [ "$_opt" == "" ] && _opt="KEY"
  local _magic
  local _format
  case $_header in
    213C617263683E0A*) _magic="UNIXARCH";_format="FILE_AR";;
    *)
    return 1;;
  esac
  [ "$_opt" == "KEY" ] && echo "$_magic" || echo "$_format"
  return 0
}

function __ar_endian() {
	echo "BIG"
}


# we need offset and size in case of we are inside a macho Univeral Binary which may contains several archive
function __ar_nb_object() {
	local _file="$1"
	local _offset="$2"
	local _size="$3"
	[ "$_offset" == "" ] && _offset=0
	local _end_offset
	if [ ! "$_size" == "" ]; then
		_end_offset=$(( _offset + _size ))
	else
		_end_offset=$(wc -c "$_file" | awk '{print $1}')
	fi

	local _raw_header
	local _current_pos=$(( _offset + __AR_HEADER_SIZE__))
	local _nb_obj=0
	while [ $_current_pos -lt $_end_offset ]
	do
		_nb_obj=$(( _nb_obj + 1 ))
		_raw_header="$(__extract_raw_bin "$_file" "$__AR_OBJECT_HEADER_SIZE__" "$_current_pos")" || _result=$?
		_obj_size=$(__ar_object_size "$_raw_header")
		_current_pos=$((__AR_OBJECT_HEADER_SIZE__ + _current_pos + _obj_size))
	done

	echo "$_nb_obj"
	return 0

}

# ar header of an object contained in ar
# each object embedded in archive have an ar header (plus its own header)
function __ar_object_header() {
	local _file="$1"
	local _obj_number="$2"
	# represent the beginning of the ar if it is inside another file (Macho Universal Binary)
	local _offset="$3"
	[ "$_obj_number" == "" ] && _obj_number=1
	[ "$_offset" == "" ] && _offset=0

	local _raw_header
	local _obj_pos=$(( _offset + __AR_HEADER_SIZE__))
	local _obj_size
	local i
	for ((i=1;i<=$_obj_number;i++)) {
		# we read more in case of we are dealing with an a System V variant
		_raw_header="$(__extract_raw_bin "$_file" "$__AR_OBJECT_HEADER_EXTENDED_SIZE__" "$_obj_pos")" || _result=$?
		_obj_size=$(__ar_object_size "$_raw_header")
		_obj_pos=$((__AR_OBJECT_HEADER_SIZE__ + _obj_pos + _obj_size))
	}
	echo "$_raw_header"
  return 0
}

function __ar_object_pos() {
	local _file="$1"
	local _obj_number="$2"
	# represent the beginning of the ar if it is inside another file (Macho Universal Binary)
	local _offset="$3"
	[ "$_obj_number" == "" ] && _obj_number=1
	[ "$_offset" == "" ] && _offset=0
	local _raw_header
	local _obj_pos=$(( _offset + __AR_HEADER_SIZE__))
	local _obj_size
	local _return_obj_pos
	local i
	for ((i=1;i<=$_obj_number;i++)) {
		_raw_header="$(__extract_raw_bin "$_file" "$__AR_OBJECT_HEADER_SIZE__" "$_obj_pos")" || _result=$?
		_obj_size=$(__ar_object_size "$_raw_header")
		_return_obj_pos=$_obj_pos
		_obj_pos=$((__AR_OBJECT_HEADER_SIZE__ + _obj_pos + _obj_size))
	}
	echo "$_return_obj_pos"
  return 0
}

# return the position of the real file inside archive
function __ar_object_data_pos() {
	local _file="$1"
	local _obj_number="$2"
	# represent the beginning of the ar if it is inside another file (Macho Universal Binary)
	local _offset="$3"
	[ "$_obj_number" == "" ] && _obj_number=1
	[ "$_offset" == "" ] && _offset=0
	local _raw_header
	local _obj_pos=$(( _offset + __AR_HEADER_SIZE__))
	local _obj_size
	local _return_obj_pos
	local i
	for ((i=1;i<=$_obj_number;i++)) {
		_raw_header="$(__extract_raw_bin "$_file" "$__AR_OBJECT_HEADER_SIZE__" "$_obj_pos")" || _result=$?
		_obj_size=$(__ar_object_size "$_raw_header")
		_return_obj_pos=$_obj_pos
		_obj_pos=$((__AR_OBJECT_HEADER_SIZE__ + _obj_pos + _obj_size))
	}

	local _name="$(__get_ordered_bin "$_raw_header" "BIG" "0" "16")"
	_name="$(__trim $(__print_ascii_code "$_name"))"
	local _pattern='^.*/([0-9][0-9])$'
	local _ext_name_size=0
	if [[ $_name =~ $_pattern ]]; then
			_ext_name_size="${BASH_REMATCH[1]}"
	fi
	local _data_pos=$((_return_obj_pos + _ext_name_size + __AR_OBJECT_HEADER_SIZE__))
	echo "$_data_pos"
  return 0
}


function __ar_object_name() {
	local _header="$1"
  local _endian="BIG"
  local _offset=0
	local _name="$(__get_ordered_bin "$_header" "$_endian" "$_offset" "16")"
	_name="$(__trim $(__print_ascii_code "$_name"))"
	local _pattern='^.*/([0-9][0-9])$'
	local _ext_name_size
	# ar file variant System V -- name is stored just after object header
	if [[ $_name =~ $_pattern ]]; then
			_ext_name_size="${BASH_REMATCH[1]}"
			_name="$(__get_ordered_bin "$_header" "$_endian" "$((_offset + __AR_OBJECT_HEADER_SIZE__))" "$_ext_name_size")"
			_name="$(__trim $(__print_ascii_code "$_name"))"
	fi
	# in some variant the filame end with /
  echo "${_name//\//}"
  return 0
}

function __ar_object_size() {
	local _header="$1"
  local _endian="BIG"
  local _offset=48
	local _size="$(__get_ordered_bin "$_header" "$_endian" "$_offset" "10")"
  echo "$(( $(__print_ascii_code $_size) ))"
  return 0
}

# MACH-O FORMAT ---------------------------------------------------------------
function __macho_header() {
  local _file="$1"
	local _offset="$2"
  local _size=$__MACHO_HEADER_SIZE__
	[ "$_offset" == "" ] && _offset=0
  local _raw_header="$(__extract_raw_bin "$_file" "$_size" "$_offset")"  || _result=$?
  echo "$_raw_header"
  return 0
}

function __macho_universal_header() {
  local _file="$1"
  local _size=$__MACHO_UNIVERSAL_HEADER_SIZE__
  local _raw_header="$(__extract_raw_bin "$_file" "$_size")"  || _result=$?
  echo "$_raw_header"
  return 0
}


function __macho_magic() {
  local _header="$1"
  local _opt="$2"
  # FORMAT -- return file format
  # KEY -- return magic key [DEFAULT]
  [ "$_opt" == "" ] && _opt="KEY"
  local _key_magic
  local _format

  case $_header in
    FEEDFACE*) _key_magic="MH_MAGIC";_format="FILE_MACHO";;
    CEFAEDFE*) _key_magic="MH_CIGAM";_format="FILE_MACHO";;
    FEEDFACF*) _key_magic="MH_MAGIC_64";_format="FILE_MACHO";;
    CFFAEDFE*) _key_magic="MH_CIGAM_64";_format="FILE_MACHO";;
    # These twho magic number correspond to Universal Binary
    # UB are always in Big Endian
    CAFEBABE*) _key_magic="FAT_MAGIC";_format="FILE_MACHO_UNIVERSAL";;
    BEBAFECA*) _key_magic="FAT_CIGAM";_format="FILE_MACHO_UNIVERSAL";;
    *)
    return 1;;
  esac

  [ "$_opt" == "KEY" ] && echo "$_key_magic" || echo "$_format"
  return 0
}


function __macho_endian() {
  local _header="$1"
  local _magic="$(__macho_magic "$_header")"
  # Default is little endian
  local _endian="LITTLE"
  case $_magic in
    MH_MAGIC) _endian="BIG";;
    MH_CIGAM) _endian="LITTLE";;
    MH_MAGIC_64) _endian="BIG";;
    MH_CIGAM_64) _endian="LITTLE";;
    # These twho magic number correspond to Universal Binary
    # UB are always in Big Endian
    FAT_MAGIC) _endian="BIG";;
    FAT_CIGAM) _endian="BIG";;
  esac
  echo "$_endian"
  return 0
}

function __macho_cputype() {
  local _header="$1"
  local _endian="$(__macho_endian "$_header")"
	local _offset=4
	local _cpu_type="$(__get_ordered_bin "$_header" "$_endian" "$_offset" "4")"
  echo "$(__macho_convert_cputype "$_cpu_type")"
  return 0
}

function __macho_cpusubtype() {
  local _header="$1"
	local _endian="$(__macho_endian "$_header")"
  local _offset=8
	local _cpusubtype="$(__get_ordered_bin "$_header" "$_endian" "$_offset" "4")"
  echo "$(__macho_convert_cpusubtype "$_cpusubtype")"
  return 0
}

function __macho_convert_cpusubtype() {
	# TODO : complete convert list ?
	local _cpusubtype="$1"
	local _x_cpusubtype="0x$_cpusubtype"
  echo "$_x_cpusubtype"
}

function __macho_convert_cputype() {
	local _cpu_type="$1"
	local _x_cpu_type="0x$_cpu_type"
  local _r_cpu_type
	# Mask for architecture bits
  local CPU_ARCH_MASK="0xff000000"
  # 64 bit ABI
  local CPU_ARCH_ABI64="0x01000000"
  local CPU_TYPE_ANY=-1
  local CPU_TYPE_X86=7
  local CPU_TYPE_I386=$((CPU_TYPE_X86))
  local CPU_TYPE_X86_64=$((CPU_TYPE_X86 | CPU_ARCH_ABI64))
  # Old Motorola PowerPC
  local CPU_TYPE_MC98000=10
  local CPU_TYPE_ARM=12
  local CPU_TYPE_ARM64=$((CPU_TYPE_ARM | CPU_ARCH_ABI64))
  local CPU_TYPE_SPARC=14
  local CPU_TYPE_POWERPC=18
  local CPU_TYPE_POWERPC64=$((CPU_TYPE_POWERPC | CPU_ARCH_ABI64))
  case $((_x_cpu_type)) in
    $CPU_TYPE_X86_64) _r_cpu_type="CPU_TYPE_X86_64";;
    $CPU_TYPE_ANY) _r_cpu_type="CPU_TYPE_ANY";;
    $CPU_TYPE_X86)_r_cpu_type="CPU_TYPE_X86";;
    $CPU_TYPE_I386)_r_cpu_type="CPU_TYPE_I386";;
    $CPU_TYPE_X86_64)_r_cpu_type="CPU_TYPE_X86_64";;
    $CPU_TYPE_MC98000)_r_cpu_type="CPU_TYPE_MC98000";;
    $CPU_TYPE_ARM)_r_cpu_type="CPU_TYPE_ARM";;
    $CPU_TYPE_ARM64)_r_cpu_type="CPU_TYPE_ARM64";;
    $CPU_TYPE_SPARC)_r_cpu_type="CPU_TYPE_SPARC";;
    $CPU_TYPE_POWERPC)_r_cpu_type="CPU_TYPE_POWERPC";;
    $CPU_TYPE_POWERPC64)_r_cpu_type="CPU_TYPE_POWERPC64";;
    *)
    _r_cpu_type="$_x_cpu_type";;
  esac
  echo "$_r_cpu_type"
}


function __macho_filetype() {
  local _header="$1"
	local _endian="$(__macho_endian "$_header")"
	local _offset=12
	local _ftype="$(__get_ordered_bin "$_header" "$_endian" "$_offset" "4")"
  local _x_ftype="0x$_ftype"
  local _r_ftype
  case $(($_x_ftype)) in
    1) _r_ftype="MH_OBJECT";;
    2) _r_ftype="MH_EXECUTE";;
    3) _r_ftype="MH_FVMLIB";;
    4) _r_ftype="MH_CORE";;
    5) _r_ftype="MH_PRELOAD";;
    6) _r_ftype="MH_DYLIB";;
    7) _r_ftype="MH_DYLINKER";;
    8) _r_ftype="MH_BUNDLE";;
    9) _r_ftype="MH_DYLIB_STUB";;
    10) _r_ftype="MH_DSYM";;
    11) _r_ftype="MH_KEXT_BUNDLE";;
    *)
    _r_ftype="$_x_ftype";;
  esac
  echo "$_r_ftype"
  return 0
}


# nb arch supported by this universal binary
function __macho_universal_nbarch() {
  local _header="$1"
	local _endian="BIG"
	local _offset=4
	local _nb_arch="$(__get_ordered_bin "$_header" "$_endian" "$_offset" "4")"
  local _x_nb_arch="0x$_nb_arch"
  echo $((_x_nb_arch))
  return 0
}


function __macho_universal_cputype() {
  local _header="$1"
	local _arch_number="$2"
	[ "$_arch_number" == "" ] && _arch_number=1
	_arch_number=$((_arch_number - 1))
	local _endian="BIG"
	local _offset=$((__FAT_HEADER_SIZE__ + __FAT_ARCH_SIZE__ * _arch_number ))
	local _cpu_type="$(__get_ordered_bin "$_header" "$_endian" "$_offset" "4")"
  echo "$(__macho_convert_cputype "$_cpu_type")"
  return 0
}

function __macho_universal_cpusubtype() {
  local _header="$1"
	local _arch_number="$2"
	[ "$_arch_number" == "" ] && _arch_number=1
	_arch_number=$((_arch_number - 1))
	local _endian="BIG"
	local _offset=$((__FAT_HEADER_SIZE__ + __FAT_ARCH_SIZE__ * _arch_number + 4))
	local _cpusubtype="$(__get_ordered_bin "$_header" "$_endian" "$_offset" "4")"
  echo "$(__macho_convert_cpusubtype "$_cpusubtype")"
  return 0
}

# extract pos of an arch
function __macho_universal_position() {
  local _header="$1"
  local _arch_number="$2"
	[ "$_arch_number" == "" ] && _arch_number=1
	_arch_number=$((_arch_number - 1))
	local _endian="BIG"
	local _offset=$((__FAT_HEADER_SIZE__ + __FAT_ARCH_SIZE__ * _arch_number + 8))
	local _pos="$(__get_ordered_bin "$_header" "$_endian" "$_offset" "4")"
  local _x_pos="0x$_pos"
  echo "$_x_pos"
  return 0
}

function __macho_universal_size() {
  local _header="$1"
	local _arch_number="$2"
	[ "$_arch_number" == "" ] && _arch_number=1
	_arch_number=$((_arch_number - 1))
	local _endian="BIG"
	local _offset=$((__FAT_HEADER_SIZE__ + __FAT_ARCH_SIZE__ * _arch_number + 12))
	local _size="$(__get_ordered_bin "$_header" "$_endian" "$_offset" "4")"
  local _x_size="0x$_size"
  echo $(( _x_size ))
  return 0
}

# Universal Binaries contains up to 4 architectures of the same file type
function __macho_universal_global_filetype() {
	local _file="$1"
	local _header="$(__macho_universal_header "$_file")"
	local _ftype=
	# We look only for first contained binary
	# get position of first contained arch
	local _pos=$(__macho_universal_position "$_header")
	local _format="$(__type_bin "$_file" "$_pos")"
	local _arch_header
	case $_format in
		FILE_AR )
			_arch_header="$(__ar_header "$_file" "$_pos")"
			_ftype="$(__ar_magic "$_arch_header")"
			;;
		FILE_MACHO )
			_arch_header="$(__macho_header "$_file" "$_pos")"
			_ftype=$(__macho_filetype "$_arch_header")
			;;
	esac

	echo "$_ftype"
}

# ELF FORMAT ---------------------------------------------------------------
function __elf_header() {
  local _file="$1"
	local _offset="$2"
	[ "$_offset" == "" ] && _offset=0
  local _size=$__ELF_HEADER_SIZE__
  local _raw_header="$(__extract_raw_bin "$_file" "$_size" "$_offset")"  || _result=$?
  echo "$_raw_header"
  return 0
}



function __elf_magic() {
  local _header="$1"
  local _opt="$2"
  # FORMAT -- return file format
  # KEY -- return magic key [DEFAULT]
  [ "$_opt" == "" ] && _opt="KEY"
  local _key_magic
  local _format
  case $_header in
    7F454C46*) _key_magic="ELF";_format="FILE_ELF";;
    *)
    return 1;;
  esac

  [ "$_opt" == "KEY" ] && echo "$_key_magic" || echo "$_format"
  return 0
}

function __elf_class() {
  local _header="$1"
	local _endian="LITTLE"
	local _offset=4
	local _class="$(__get_ordered_bin "$_header" "$_endian" "$_offset" "1")"
  local _x_class="0x$_class"
  local _r_class
  case $((_x_class)) in
    0) _r_class="ELFCLASSNONE";;
    1) _r_class="ELFCLASS32";;
    2) _r_class="ELFCLASS64";;
    3) _r_class="ELFCLASSNUM";;
    *)
      _r_class="$_x_class";;
  esac
  echo "$_r_class"
  return 0
}

function __elf_data() {
	local _header="$1"
	local _endian="LITTLE"
	local _offset=5
	local _data="$(__get_ordered_bin "$_header" "$_endian" "$_offset" "1")"
  local _x_data="0x$_data"
  local _r_data
  case $((_x_data)) in
    0) _r_data="ELFDATANONE";;
    1) _r_data="ELFDATA2LSB";_endian="LITTLE";;
    2) _r_data="ELFDATA2MSB";_endian="BIG";;
    3) _r_data="ELFDATANUM";;
    *)
      _r_data="$_x_data";;
  esac
  echo "$_r_data"
  return 0
}

function __elf_endian() {
  local _header="$1"
  local _data="$(__elf_data "$_header")"
  # Default is little endian
  local _endian="LITTLE"
  case $_data in
    ELFDATA2LSB) _endian="LITTLE";;
    ELFDATA2MSB) _endian="BIG";;
  esac
  echo "$_endian"
  return 0
}


function __elf_osabi() {
  local _header="$1"
	# only 1 byte
	local _endian="LITTLE"
	local _offset=7
	local _osabi="$(__get_ordered_bin "$_header" "$_endian" "$_offset" "1")"
  local _x_osabi="0x$_osabi"
  local _r_osabi
  case $((_x_osabi)) in
    # UNIX System V ABI -- alias : ELFOSABI_SYSV
    0) _r_osabi="ELFOSABI_NONE";;
    1) _r_osabi="ELFOSABI_HPUX";;
    2) _r_osabi="ELFOSABI_NETBSD";;
    # ELFOSABI_LINUX is historical alias for ELFOSABI_GNU.
    3) _r_osabi="ELFOSABI_GNU";;
    4) _r_osabi="ELFOSABI_HURD";;
    6) _r_osabi="ELFOSABI_SOLARIS";;
    7) _r_osabi="ELFOSABI_AIX";;
    8) _r_osabi="ELFOSABI_IRIX";;
    9) _r_osabi="ELFOSABI_FREEBSD";;
    10) _r_osabi="ELFOSABI_TRU64";;
    11) _r_osabi="ELFOSABI_MODESTO";;
    12) _r_osabi="ELFOSABI_OPENBSD";;
    13) _r_osabi="ELFOSABI_OPENVMS";;
    14) _r_osabi="ELFOSABI_NSK";;
    15) _r_osabi="ELFOSABI_AROS";;
    16) _r_osabi="ELFOSABI_FENIXOS";;
    64) _r_osabi="ELFOSABI_C6000_ELFABI";;
    65) _r_osabi="ELFOSABI_C6000_LINUX";;
    97) _r_osabi="ELFOSABI_ARM";;
    255) _r_osabi="ELFOSABI_STANDALONE";;
    *)
      _r_osabi="$_x_osabi";;
  esac
  echo "$_r_osabi"
  return 0
}

function __elf_abiver() {
  local _header="$1"
	# only 1 byte
	local _endian="LITTLE"
	local _offset=8
	local _abiver="$(__get_ordered_bin "$_header" "$_endian" "$_offset" "1")"
  local _x_abiver="0x$_abiver"
  local _r_abiver=$((_x_abiver))
  echo "$_r_abiver"
  return 0
}


function __elf_filetype() {
  local _header="$1"
	local _endian="$(__elf_endian "$_header")"
	local _offset=16
	local _ftype="$(__get_ordered_bin "$_header" "$_endian" "$_offset" "2")"
  local _x_ftype="0x$_ftype"
  local _r_ftype
  case $((_x_ftype)) in
    0) _r_ftype="ET_NONE";;
    1) _r_ftype="ET_REL";;
    2) _r_ftype="ET_EXEC";;
    3) _r_ftype="ET_DYN";;
    4) _r_ftype="ET_CORE";;
    5) _r_ftype="ET_NUM";;
    $((0xfe00)))_r_ftype="ET_LOOS";;
    $((0xfeff)))_r_ftype="ET_HIOS";;
    $((0xff00)))_r_ftype="ET_LOPROC";;
    $((0xffff)))_r_ftype="ET_HIPROC";;
    *)
      _r_ftype="$_x_ftype";;
  esac
  echo "$_r_ftype"
  return 0
}

# MACHINE -- we do not translate code machine, there is too much
function __elf_machine() {
  local _header="$1"
	local _endian="$(__elf_endian "$_header")"
	local _offset=18
	local _machine="$(__get_ordered_bin "$_header" "$_endian" "$_offset" "2")"
  local _x_machine="0x$_machine"
  echo "$_x_machine"
  return 0
}

fi
