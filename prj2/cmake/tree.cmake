# SPDX-License-Identifier: MIT

# Populates the variables of given names with the absolute path of the files
# for the target 'target_name'.
#
# This assumes the source tree follows an opinionated where the sources are
# inside 'src/', the headers are inside 'src/${target_name}/', with the headers
# under 'src/${target_name}/private/' being the private headers (which are used
# for the build but aren't installed) and the others are the public headers
# (which are used for the build *and* are installed).
function(ade_set_source_files
	target_name
	c_cxx_sources_varname
	cxx_headers_public_varname
	cxx_headers_private_varname
)
	file(GLOB_RECURSE C_CXX_SOURCES CONFIGURE_DEPENDS
		"${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
		"${CMAKE_CURRENT_SOURCE_DIR}/src/*.c")
	file(GLOB_RECURSE CXX_HEADERS CONFIGURE_DEPENDS
		"${CMAKE_CURRENT_SOURCE_DIR}/src/*.h"
		"${CMAKE_CURRENT_SOURCE_DIR}/src/*.hpp")
	set(CXX_HEADERS_PUBLIC)
	set(CXX_HEADERS_PRIVATE)
	foreach(header ${CXX_HEADERS})
		string(REGEX MATCH
			"^${CMAKE_CURRENT_SOURCE_DIR}/src/${target_name}/private/.*"
			header_if_matches
			"${header}")
		if(header_if_matches)
			list(APPEND CXX_HEADERS_PRIVATE "${header}")
		else()
			list(APPEND CXX_HEADERS_PUBLIC "${header}")
		endif()
	endforeach()
	set("${c_cxx_sources_varname}" ${C_CXX_SOURCES} PARENT_SCOPE)
	set("${cxx_headers_public_varname}" ${CXX_HEADERS_PUBLIC} PARENT_SCOPE)
	set("${cxx_headers_private_varname}" ${CXX_HEADERS_PRIVATE} PARENT_SCOPE)
endfunction()
