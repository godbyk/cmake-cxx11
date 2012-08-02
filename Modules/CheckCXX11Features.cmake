# - Check which parts of the C++11 standard the compiler supports

#=============================================================================
# Copyright 2011,2012 Rolf Eike Beer <eike@sf-mail.de>
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
    message(FATAL_ERROR "CheckCXX11Features modules only works if language CXX is enabled")
endif ()

cmake_minimum_required(VERSION 2.8.3)

#
### CHECK FOR NEEDED COMPILER FLAGS
#
include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("--std=c++11" _HAS_CXX11_FLAG)
CHECK_CXX_COMPILER_FLAG("--std=c++0x" _HAS_CXX0X_FLAG)

if(_HAS_CXX11_FLAG)
    set(CXX11_COMPILER_FLAGS "--std=c++11")
elseif(_HAS_CXX0X_FLAG)
    set(CXX11_COMPILER_FLAGS "--std=c++0x")
endif()



# Try to compile a source file and report to CMakeError.log / CMakeOutput.log
function(_cxx11_compile_program SRCFILE BINDIR RESULT_VAR SHOULD_COMPILE)

    # Cross Compilation. Not running possible.
    try_compile(
        _COMPILE_RESULT "${BINDIR}" "${SRCFILE}"
        COMPILE_DEFINITIONS     "${CXX11_COMPILER_FLAGS}"
        OUTPUT_VARIABLE         _COMPILE_OUTPUT)

    if (${_COMPILE_RESULT} AND SHOULD_COMPILE)
        set(msg         "compilation succeeded (expected success)\n")
        set(logfile     "CMakeOutput")
        set(${RESULT_VAR} TRUE PARENT_SCOPE)

    elseif (${_COMPILE_RESULT} AND NOT SHOULD_COMPILE)
        set(msg         "compilation succeeded (expected failure)\n")
        set(logfile     "CMakeError")
        set(${RESULT_VAR} FALSE PARENT_SCOPE)

    elseif (NOT ${_COMPILE_RESULT} AND SHOULD_COMPILE)
        set(msg         "compilation failed (expected success)\n")
        set(logfile     "CMakeError")
        set(${RESULT_VAR} FALSE PARENT_SCOPE)

    elseif (NOT ${_COMPILE_RESULT} AND NOT SHOULD_COMPILE)
        set(msg         "compilation failed (expected failure)\n")
        set(logfile     "CMakeOutput")
        set(${RESULT_VAR} TRUE PARENT_SCOPE)

    endif ()

    # The compilation was successfully.
    file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${logfile}.log
        "CXX11 Feature ${FEATURE_NAME} : ${msg}"
        "${_COMPILE_OUTPUT}\n\n"})

endfunction(_cxx11_compile_program)




# Try to compile and run a source file and report to CMakeError.log / CMakeOutput.log
function(_cxx11_run_program SRCFILE BINDIR RESULT_VAR EXPECTED_RESULT)

    set(${RESULT_VAR} FALSE PARENT_SCOPE)

    if (CROSS_COMPILING)

        # No running possible
        _cxx11_compile_program( "${SRCFILE}" "${BINDIR}" ${RESULT_VAR} TRUE)

    else (CROSS_COMPILING)

        # Native compilation. Compile and run the files
        try_run(
            _RUN_RESULT_VAR _COMPILE_RESULT_VAR
            "${_bindir}" "${SRCFILE}"
            COMPILE_DEFINITIONS         "${CXX11_COMPILER_FLAGS}"
            COMPILE_OUTPUT_VARIABLE     _COMPILE_OUTPUT
            RUN_OUTPUT_VARIABLE         _RUN_OUTPUT)

        if (_COMPILE_RESULT_VAR)

            # The compilation was successfully.
            file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
                "CXX11 Feature ${FEATURE_NAME} : compilation succeeded\n"
                "${_COMPILE_OUTPUT}\n\n"})

            if (_RUN_RESULT_VAR EQUAL ${EXPECTED_RESULT})
                set(msg         "run succeeded and returned expected result\n")
                set(logfile     "CMakeOutput")
                set(${RESULT_VAR} TRUE PARENT_SCOPE)

            elseif (_RUN_RESULT_VAR STREQUAL "FAILED_TO_RUN")
                set(msg         "run failed\n")
                set(logfile     "CMakeError")

            else ()
                set(msg         "run succeeded but did not return expected result\n"
                                "got: ${_RUN_RESULT_VAR}\n"
                                "expected: ${EXPECTED_RESULT}\n")
                set(logfile     "CMakeError")

            endif ()

            # Log the result
            file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${logfile}.log
                "CXX11 Feature ${FEATURE_NAME} : ${msg}"
                "${_COMPILE_OUTPUT}\n\n"})

        else (_COMPILE_RESULT_VAR)

            # The compilation failed
            file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
                "CXX11 Feature ${FEATURE_NAME} : compilation failed\n"
                "${_COMPILE_OUTPUT}\n\n")

        endif ()

    endif (CROSS_COMPILING)

endfunction(_cxx11_run_program)



function(cxx11_check_feature FEATURE_NAME RESULT_VAR)

    if (NOT DEFINED ${RESULT_VAR})
        set(_bindir "${CMAKE_CURRENT_BINARY_DIR}/cxx11_${FEATURE_NAME}")

        set(_SRCFILE_BASE ${CMAKE_CURRENT_LIST_DIR}/CheckCXX11Features/cxx11-test-${FEATURE_NAME})
        set(_LOG_NAME "\"${FEATURE_NAME}\"")
        message(STATUS "Checking C++11 support for ${_LOG_NAME}")

        set(_SRCFILE "${_SRCFILE_BASE}.cpp")
        set(_SRCFILE_FAIL "${_SRCFILE_BASE}_fail.cpp")
        set(_SRCFILE_FAIL_COMPILE "${_SRCFILE_BASE}_fail_compile.cpp")

        # Run the expected to return success program
        _cxx11_run_program( "${_SRCFILE}" "${_bindir}" ${RESULT_VAR} 0 )

        # Now (if needed run the expected to fail program)
        if (${RESULT_VAR} AND EXISTS "${_SRCFILE_FAIL}")
            _cxx11_run_program( "${_SRCFILE_FAIL}" "${_bindir}_fail" ${RESULT_VAR} 1 )
        endif ()

        # Now try the expected to fail compile prgram
        if (${RESULT_VAR} AND EXISTS "${_SRCFILE_FAIL_COMPILE}")
            _cxx11_compile_program( "${_SRCFILE_FAIL_COMPILE}" "${_bindir}_fail_compile" ${RESULT_VAR} FALSE )
        endif ()

        if (${RESULT_VAR})
            message(STATUS "Checking C++11 support for ${_LOG_NAME}: works")
        else (${RESULT_VAR})
            message(STATUS "Checking C++11 support for ${_LOG_NAME}: not supported")
        endif (${RESULT_VAR})

        set(${RESULT_VAR} ${${RESULT_VAR}} CACHE INTERNAL "C++11 support for ${_LOG_NAME}")

    endif (NOT DEFINED ${RESULT_VAR})

endfunction(cxx11_check_feature)


cxx11_check_feature("static_assert" HAS_CXX11_STATIC_ASSERT)
cxx11_check_feature("long_long" HAS_CXX11_LONG_LONG)
cxx11_check_feature("auto" HAS_CXX11_AUTO)
cxx11_check_feature("rvalue-references" HAS_CXX11_RVALUE_REFERENCES)
cxx11_check_feature("constexpr" HAS_CXX11_CONSTEXPR)
cxx11_check_feature("sizeof_member" HAS_CXX11_SIZEOF_MEMBER)
cxx11_check_feature("__func__" HAS_CXX11_FUNC)
cxx11_check_feature("nullptr" HAS_CXX11_NULLPTR)
cxx11_check_feature("cstdint" HAS_CXX11_CSTDINT_H)
cxx11_check_feature("initializer_list" HAS_CXX11_INITIALIZER_LIST)
cxx11_check_feature("class_override_final" HAS_CXX11_CLASS_OVERRIDE)
