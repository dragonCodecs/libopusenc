# SPDX-FileCopyrightText: 2001-2011 Xiph.Org, Skype Limited, Octasic, Jean-Marc Valin, Timothy B. Terriberry, CSIRO, Gregory Maxwell, Mark Borgerding, Erik de Castro Lopo
# SPDX-FileCopyrightText: 2023 Amyspark <amy@amyspark.me>
# SPDX-License-Identifier: BSD-3-Clause

#[[Cmake helper function to parse source files from make files
this is to avoid breaking existing make and auto make support
but still have the option to use CMake with only lists at one place]]

cmake_minimum_required(VERSION 3.1)

function(get_library_version OPUS_LIBRARY_VERSION OPUS_LIBRARY_VERSION_MAJOR)
  file(STRINGS configure.ac OP_LT_CURRENT_string
       LIMIT_COUNT 1
       REGEX "OP_LT_CURRENT=")
  string(REGEX MATCH
               "OP_LT_CURRENT=([0-9]*)"
               _
               ${OP_LT_CURRENT_string})
  set(OP_LT_CURRENT ${CMAKE_MATCH_1})

  file(STRINGS configure.ac OP_LT_REVISION_string
       LIMIT_COUNT 1
       REGEX "OP_LT_REVISION=")
  string(REGEX MATCH
               "OP_LT_REVISION=([0-9]*)"
               _
               ${OP_LT_REVISION_string})
  set(OP_LT_REVISION ${CMAKE_MATCH_1})

  file(STRINGS configure.ac OP_LT_AGE_string
       LIMIT_COUNT 1
       REGEX "OP_LT_AGE=")
  string(REGEX MATCH
               "OP_LT_AGE=([0-9]*)"
               _
               ${OP_LT_AGE_string})
  set(OP_LT_AGE ${CMAKE_MATCH_1})

  math(EXPR OPUS_LIBRARY_VERSION_MAJOR "${OP_LT_CURRENT} - ${OP_LT_AGE}")
  set(OPUS_LIBRARY_VERSION_MINOR ${OP_LT_AGE})
  set(OPUS_LIBRARY_VERSION_PATCH ${OP_LT_REVISION})
  set(
    OPUS_LIBRARY_VERSION
    "${OPUS_LIBRARY_VERSION_MAJOR}.${OPUS_LIBRARY_VERSION_MINOR}.${OPUS_LIBRARY_VERSION_PATCH}"
    PARENT_SCOPE)
  set(OPUS_LIBRARY_VERSION_MAJOR ${OPUS_LIBRARY_VERSION_MAJOR} PARENT_SCOPE)
endfunction()

function(get_package_version PACKAGE_VERSION)
  find_package(Git)
  if(GIT_FOUND)
    execute_process(COMMAND ${GIT_EXECUTABLE} describe --tags --match "v*"
                    OUTPUT_VARIABLE OPUS_PACKAGE_VERSION)
    if(OPUS_PACKAGE_VERSION)
      string(STRIP ${OPUS_PACKAGE_VERSION}, OPUS_PACKAGE_VERSION)
      string(REPLACE \n
                     ""
                     OPUS_PACKAGE_VERSION
                     ${OPUS_PACKAGE_VERSION})
      string(REPLACE ,
                     ""
                     OPUS_PACKAGE_VERSION
                     ${OPUS_PACKAGE_VERSION})

      string(SUBSTRING ${OPUS_PACKAGE_VERSION}
                       1
                       -1
                       OPUS_PACKAGE_VERSION)
      set(PACKAGE_VERSION ${OPUS_PACKAGE_VERSION} PARENT_SCOPE)
      return()
    endif()
  endif()

  if(EXISTS "${CMAKE_SOURCE_DIR}/package_version")
    # Not a git repo, lets' try to parse it from package_version file if exists
    file(STRINGS package_version opus_package_version_string
         LIMIT_COUNT 1
         REGEX "PACKAGE_VERSION=")
    string(REPLACE "PACKAGE_VERSION="
                   ""
                   opus_package_version_string
                   ${opus_package_version_string})
    string(REPLACE "\""
                   ""
                   opus_package_version_string
                   ${opus_package_version_string})
    set(PACKAGE_VERSION ${opus_package_version_string} PARENT_SCOPE)
    return()
  endif()

  # if all else fails set to 0
  set(PACKAGE_VERSION 0 PARENT_SCOPE)
endfunction()
