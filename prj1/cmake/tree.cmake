# SPDX-License-Identifier: MIT

# Populates the variables of given names with the absolute path of the files
# for the target 'target_name'.
#
# This assumes the source tree follows an opinionated where the sources are
# inside 'src/', the headers are inside 'src/', with the headers under
# 'src/${target_name}/private/' being the private headers (which are used
# for the build but aren't installed) and the others are the public headers
# (which are used for the build *and* are installed).
function(ade_set_source_files
	target_name
	c_cxx_sources_varname
	headers_public_varname
	headers_private_varname
)
	file(GLOB_RECURSE C_CXX_SOURCES CONFIGURE_DEPENDS
		"${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
		"${CMAKE_CURRENT_SOURCE_DIR}/src/*.c")
	file(GLOB_RECURSE HEADERS CONFIGURE_DEPENDS
		"${CMAKE_CURRENT_SOURCE_DIR}/src/*.h"
		"${CMAKE_CURRENT_SOURCE_DIR}/src/*.hpp")
	set(HEADERS_PUBLIC)
	set(HEADERS_PRIVATE)
	foreach(header ${HEADERS})
		string(REGEX MATCH
			"^${CMAKE_CURRENT_SOURCE_DIR}/src/${target_name}/private/.*"
			header_if_matches
			"${header}")
		if(header_if_matches)
			list(APPEND HEADERS_PRIVATE "${header}")
		else()
			list(APPEND HEADERS_PUBLIC "${header}")
		endif()
	endforeach()
	set("${c_cxx_sources_varname}" ${C_CXX_SOURCES} PARENT_SCOPE)
	set("${headers_public_varname}" ${HEADERS_PUBLIC} PARENT_SCOPE)
	set("${headers_private_varname}" ${HEADERS_PRIVATE} PARENT_SCOPE)
endfunction()
