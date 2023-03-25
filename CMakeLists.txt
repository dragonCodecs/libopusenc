# SPDX-FileCopyrightText: 2017-2021 Microsoft Corporation
# SPDX-FileCopyrightText: 2023 Amyspark <amy@amyspark.me>
# SPDX-License-Identifier: MIT

cmake_minimum_required(VERSION 3.4)
include(opus_functions.cmake)

get_library_version(OPUS_LIBRARY_VERSION OPUS_LIBRARY_VERSION_MAJOR)
message(STATUS "Opus library version: ${OPUS_LIBRARY_VERSION}")

get_package_version(PACKAGE_VERSION)
message(STATUS "Opus package version: ${PACKAGE_VERSION}")

string(REGEX
       REPLACE "^([0-9]+.[0-9]+\\.?([0-9]+)?).*"
               "\\1"
               PROJECT_VERSION
               ${PACKAGE_VERSION})
message(STATUS "Opus project version: ${PROJECT_VERSION}")

project(libopusenc LANGUAGES C VERSION ${PROJECT_VERSION})

if(MSVC)
 set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /wd4267 /wd4244 /wd4996 /wd4101 /wd4018")
endif()

find_path(OPUS_INCLUDE_DIR opus.h PATH_SUFFIXES opus)
find_library(OPUS_LIBRARY opus REQUIRED)

add_library(opusenc
    src/ogg_packer.c
    src/opus_header.c
    src/opusenc.c
    src/picture.c
    src/resample.c
    src/unicode_support.c)

target_compile_definitions(opusenc PRIVATE
    RANDOM_PREFIX=libopusenc
    OUTSIDE_SPEEX
    FLOATING_POINT
    PACKAGE_VERSION="${PACKAGE_VERSION}"
    PACKAGE_NAME="libopusenc"
    OPE_BUILD)
set_target_properties(opusenc PROPERTIES DEFINE_SYMBOL DLL_EXPORT)
target_include_directories(opusenc PRIVATE include ${OPUS_INCLUDE_DIR})
target_link_libraries(opusenc PRIVATE ${OPUS_LIBRARY})

install(TARGETS opusenc
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)

if(NOT OPUSENC_SKIP_HEADERS)
    install(FILES include/opusenc.h
        DESTINATION include/opus)
endif()

set(PACKAGE_VERSION "${PROJECT_VERSION}")
set(prefix "${CMAKE_INSTALL_PREFIX}")
set(exec_prefix "\$\{prefix\}")
set(libdir "\$\{exec_prefix\}/lib")
set(includedir "\$\{prefix\}/include")
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/libopusenc.pc.in" "libopusenc.pc" @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/libopusenc.pc DESTINATION lib/pkgconfig)
