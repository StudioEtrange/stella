#!/usr/bin/env bash
if [ ! "$_STELLA_COMMON_GITHUB_INCLUDED_" = "1" ]; then
_STELLA_COMMON_GITHUB_INCLUDED_=1


__get_github_releases_list() {
    local repo="$1"

    local result=""
	local last_page=$(curl ${CURL_AUTH} -i -sL "https://api.github.com/repos/${GITHUB_REPO}/releases" | grep rel=\"last\" | cut -d "," -f 2 | cut -d "=" -f 2 | cut -d ">" -f 1)
	for i in $(seq 1 ${last_page}); do 
		result="${result} $(curl ${CURL_AUTH} -sL https://api.github.com/repos/${GITHUB_REPO}/releases?page=${i} | grep tag_name | cut -d '"' -f 4)"
	done

	result="$(__filter_list_with_list "${result}" "${EXCLUDE_VERSION}" "FILTER_REMOVE")"

	local sorted

	if [ "${VERSION_CONSTRAINT}" = "" ]; then
		[ "${nb}" = "" ] && sorted="$(__sort_version "${result}" "DESC ${version_order_option}")" \
			|| sorted="$(__sort_version "${result}" "DESC ${version_order_option} LIMIT ${nb}")"
	else
		[ "${nb}" = "" ] && sorted="$(__filter_version_list "${VERSION_CONSTRAINT}" "${result}" "DESC ${version_order_option}")" \
			|| sorted="$(__filter_version_list "${VERSION_CONSTRAINT}" "${result}" "DESC ${version_order_option} LIMIT ${nb}")"
	fi

	echo "${sorted}"   
}

fi