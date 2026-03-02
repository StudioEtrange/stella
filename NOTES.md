# feature library dependency system - TODO WORK IN PROGRESS

## when install a feature from source

* 1.install FEAT_SOURCE_DEPENDENCIES list
    * parse schemas values in FEAT_SOURCE_DEPENDENCIES list
      * schema format : "[cond_lib[#version]%][cond_bin[#version]!]feature_name"
    * for each cond_lib of feature_name call __feature_condition_find_dyn_lib() TODO : exclude workspace folder while looking for dyn_lib (or use a file .STELLA_INSTALLED ?)
      * find existing lib with __search_dynamic_library_at_runtime() function
      * if found : do not install feature_name and add feature_name to FEAT_SOURCE_DEP_FROM_SYSTEM
      * if not found : install stella feature_name and add feature_name to list FEAT_SOURCE_DEP_FROM_STELLA
    * for each cond_bin of feature_name WHAT TODO ?

* 2.OLD.prepare build source
  * download code source
  * set build toolset
  * set build flags for stella feature linked lib with __link_feature_library()
  ```
	__link_feature_library "zlib" "FORCE_DYNAMIC"
	__link_feature_library "pcre" "GET_FLAGS _pcre FORCE_STATIC LIBS_NAME pcre NO_SET_FLAGS"
	__link_feature_library "xzutils" "GET_FLAGS _lzma LIBS_NAME lzma NO_SET_FLAGS"

	AUTO_INSTALL_CONF_FLAG_PREFIX="LZMA_CFLAGS=\"$_lzma_C_CXX_FLAGS $_lzma_CPP_FLAGS\" LZMA_LIBS=\"$_lzma_LINK_FLAGS\" PCRE_CFLAGS=\"$_pcre_C_CXX_FLAGS $_pcre_CPP_FLAGS\" PCRE_LIBS=\"$_pcre_LINK_FLAGS\""
  ```
  * __link_feature_library to stella feature "$SCHEMA"
    * for the schema choose between
      * FORCE_ORIGIN_SYSTEM
        * do not generate any compilation flags, we do not have any option useable while building against a system libraries
      * FORCE_ORIGIN_STELLA
      * AUTOMATIC ORIGIN : TODO use __feature_condition_find_dyn_lib on $SCHEMA (for now use a hardcoded list)
    * if found stella feature 
      * if FORCE_DYNAMIC or FORCE_STATIC : copy all dynamic or static libraries found into stella feature root folder to an isolate folder
      * use library root folder path to compute values for build flags (including rpath values)


* 2.NEW.prepare build source
  * download code source
  * set build toolset
  * call __auto_build_link "FEAT_SOURCE_LINK_CALLBACK" "$FEAT_SOURCE_DEP_FROM_STELLA" to set build flags for stella feature linked libs
    * __auto_build_link(): for each list item of FEAT_SOURCE_DEP_FROM_STELLA call  FEAT_SOURCE_LINK_CALLBACK "dependency"
      ```
      feature_ag_link() {
        local __linked_feature="$1"
        case $__linked_feature in
          zlib*)
            __link_feature_library "zlib" "FORCE_DYNAMIC"
          ;;
        esac
      }
      ```
      * __link_feature_library to stella feature "$SCHEMA"
        * check feature installed : if found stella feature 
          * if FORCE_DYNAMIC or FORCE_STATIC : copy all dynamic or static libraries found into stella feature root folder to an isolate folder
          * use library root folder path to compute values for build flags (including rpath values)

3.build
  * launch build : __auto_build()



## when install a feature from binary

* 1.install FEAT_BINARY_DEPENDENCIES
    * parse value with __feature_condition_find_cmd
    * find existing cmd in PATH (only outside of stella workspace ? find only cmd installed in system and outside of stella ?)
      * if yes : do not install anything
      * if no : install stella feature
  


## when using installed feature (at runtime)