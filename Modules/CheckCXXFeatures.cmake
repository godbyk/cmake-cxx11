# - Check which features of the C++ standard the compiler supports
#
# When found it will set the following variables
#
#  CXX11_COMPILER_FLAGS         - the compiler flags needed to get C++11 features
#
#  HAS_CXX_AUTO                 - auto keyword
#  HAS_CXX_CLASS_OVERRIDE       - override and final keywords for classes and methods
#  HAS_CXX_CONSTEXPR            - constexpr keyword
#  HAS_CXX_CSTDINT_H            - cstdint header
#  HAS_CXX_DECLTYPE             - decltype keyword
#  HAS_CXX_FUNC                 - __func__ preprocessor constant
#  HAS_CXX_INITIALIZER_LIST     - initializer list
#  HAS_CXX_LAMBDA               - lambdas
#  HAS_CXX_LONG_LONG            - long long signed & unsigned types
#  HAS_CXX_NULLPTR              - nullptr
#  HAS_CXX_RVALUE_REFERENCES    - rvalue references
#  HAS_CXX_SIZEOF_MEMBER        - sizeof() non-static members
#  HAS_CXX_STATIC_ASSERT        - static_assert()
#  HAS_CXX_VARIADIC_TEMPLATES   - variadic templates

#=============================================================================
# Copyright 2011,2012,2013 Rolf Eike Beer <eike@sf-mail.de>
# Copyright 2012 Andreas Weis
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

if (NOT CMAKE_CXX_COMPILER_LOADED)
    message(FATAL_ERROR "CheckCXXFeatures modules only works if language CXX is enabled")
endif ()

cmake_minimum_required(VERSION 2.8.3)

#
### Check for needed compiler flags
#
include(CheckCXXCompilerFlag)
check_cxx_compiler_flag("-std=c++11" _HAS_CXX11_FLAG)
if (_HAS_CXX11_FLAG)
    set(CXX11_COMPILER_FLAGS "-std=c++11")
else ()
    check_cxx_compiler_flag("-std=c++0x" _HAS_CXX0X_FLAG)
    if (_HAS_CXX0X_FLAG)
        set(CXX11_COMPILER_FLAGS "-std=c++0x")
    endif ()
endif ()

function(cxx_check_feature FEATURE_NAME RESULT_VAR)
    if (NOT DEFINED ${RESULT_VAR})
        set(_bindir "${CMAKE_CURRENT_BINARY_DIR}/cxx_${FEATURE_NAME}")

        set(_SRCFILE_BASE ${CMAKE_CURRENT_LIST_DIR}/CheckCXXFeatures/cxx11-test-${FEATURE_NAME})
        set(_LOG_NAME "\"${FEATURE_NAME}\"")
        message(STATUS "Checking C++ support for ${_LOG_NAME}")

        set(_SRCFILE "${_SRCFILE_BASE}.cpp")
        set(_SRCFILE_FAIL "${_SRCFILE_BASE}_fail.cpp")
        set(_SRCFILE_FAIL_COMPILE "${_SRCFILE_BASE}_fail_compile.cpp")

        if (CROSS_COMPILING)
            try_compile(${RESULT_VAR} "${_bindir}" "${_SRCFILE}"
                        COMPILE_DEFINITIONS "${CXX11_COMPILER_FLAGS}")
            if (${RESULT_VAR} AND EXISTS ${_SRCFILE_FAIL})
                try_compile(${RESULT_VAR} "${_bindir}_fail" "${_SRCFILE_FAIL}"
                            COMPILE_DEFINITIONS "${CXX11_COMPILER_FLAGS}")
            endif (${RESULT_VAR} AND EXISTS ${_SRCFILE_FAIL})
        else (CROSS_COMPILING)
            try_run(_RUN_RESULT_VAR _COMPILE_RESULT_VAR
                    "${_bindir}" "${_SRCFILE}"
                    COMPILE_DEFINITIONS "${CXX11_COMPILER_FLAGS}")
            if (_COMPILE_RESULT_VAR AND NOT _RUN_RESULT_VAR)
                set(${RESULT_VAR} TRUE)
            else (_COMPILE_RESULT_VAR AND NOT _RUN_RESULT_VAR)
                set(${RESULT_VAR} FALSE)
            endif (_COMPILE_RESULT_VAR AND NOT _RUN_RESULT_VAR)
            if (${RESULT_VAR} AND EXISTS ${_SRCFILE_FAIL})
                try_run(_RUN_RESULT_VAR _COMPILE_RESULT_VAR
                        "${_bindir}_fail" "${_SRCFILE_FAIL}"
                         COMPILE_DEFINITIONS "${CXX11_COMPILER_FLAGS}")
                if (_COMPILE_RESULT_VAR AND _RUN_RESULT_VAR)
                    set(${RESULT_VAR} TRUE)
                else (_COMPILE_RESULT_VAR AND _RUN_RESULT_VAR)
                    set(${RESULT_VAR} FALSE)
                endif (_COMPILE_RESULT_VAR AND _RUN_RESULT_VAR)
            endif (${RESULT_VAR} AND EXISTS ${_SRCFILE_FAIL})
        endif (CROSS_COMPILING)
        if (${RESULT_VAR} AND EXISTS ${_SRCFILE_FAIL_COMPILE})
            try_compile(_TMP_RESULT "${_bindir}_fail_compile" "${_SRCFILE_FAIL_COMPILE}"
                        COMPILE_DEFINITIONS "${CXX11_COMPILER_FLAGS}")
            if (_TMP_RESULT)
                set(${RESULT_VAR} FALSE)
            else (_TMP_RESULT)
                set(${RESULT_VAR} TRUE)
            endif (_TMP_RESULT)
        endif (${RESULT_VAR} AND EXISTS ${_SRCFILE_FAIL_COMPILE})

        if (${RESULT_VAR})
            message(STATUS "Checking C++ support for ${_LOG_NAME}: works")
        else (${RESULT_VAR})
            message(STATUS "Checking C++ support for ${_LOG_NAME}: not supported")
        endif (${RESULT_VAR})
        set(${RESULT_VAR} ${${RESULT_VAR}} CACHE INTERNAL "C++ support for ${_LOG_NAME}")
    endif (NOT DEFINED ${RESULT_VAR})
endfunction(cxx_check_feature)

cxx_check_feature("static_assert" HAS_CXX_STATIC_ASSERT)
cxx_check_feature("long_long" HAS_CXX_LONG_LONG)
cxx_check_feature("auto" HAS_CXX_AUTO)
cxx_check_feature("rvalue-references" HAS_CXX_RVALUE_REFERENCES)
cxx_check_feature("constexpr" HAS_CXX_CONSTEXPR)
cxx_check_feature("sizeof_member" HAS_CXX_SIZEOF_MEMBER)
cxx_check_feature("__func__" HAS_CXX_FUNC)
cxx_check_feature("nullptr" HAS_CXX_NULLPTR)
cxx_check_feature("cstdint" HAS_CXX_CSTDINT_H)
cxx_check_feature("initializer_list" HAS_CXX_INITIALIZER_LIST)
cxx_check_feature("class_override_final" HAS_CXX_CLASS_OVERRIDE)
cxx_check_feature("decltype" HAS_CXX_DECLTYPE)
cxx_check_feature("lambda" HAS_CXX_LAMBDA)
cxx_check_feature("variadic_templates" HAS_CXX_VARIADIC_TEMPLATES)
