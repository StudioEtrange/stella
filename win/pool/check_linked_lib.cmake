include(GetPrerequisites)

#set(BINARY_FILE "E:\CODE\stella\workspace\feature_win\windows\libpng\1_6_18\bin\libpng16.dll")
SET(BINARY_FILE "" CACHE PATH "binary file to analyse")

message("*** Checking missing dynamic library at runtime")

#GET_PREREQUISITES(<target> <prerequisites_var> <exclude_system> <recurse> <exepath> <dirs>)
get_prerequisites(${BINARY_FILE} DEPENDENCIES 0 0 "" "")



foreach(DEPENDENCY_FILE ${DEPENDENCIES})
  set(msg "====> checking linked lib : ${DEPENDENCY_FILE}")
  gp_resolve_item("${BINARY_FILE}" "${DEPENDENCY_FILE}" "" "" resolved_file)
  if(resolved_file STREQUAL DEPENDENCY_FILE)
  	set(msg "${msg} -- WARN not found")
  else()
  	set(msg "${msg} ==> ${resolved_file} -- OK")
  endif()
  message("${msg}")
endforeach()


#LIST_PREREQUISITES(<target> [<recurse> [<exclude_system> [<verbose>]]])
#LIST_PREREQUISITES(${BINARY_FILE} 0 0 0)
