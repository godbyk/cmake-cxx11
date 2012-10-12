cmake_minimum_required(VERSION 2.8.3 FATAL_ERROR)
project(Cxx11Features CXX)

include(CheckCXX11Features)

foreach (flag
        HAS_CXX11_STATIC_ASSERT
        HAS_CXX11_LONG_LONG
        HAS_CXX11_RVALUE_REFERENCES
        HAS_CXX11_CONSTEXPR
        HAS_CXX11_SIZEOF_MEMBER
        HAS_CXX11_FUNC
        HAS_CXX11_NULLPTR
        HAS_CXX11_CSTDINT_H
        HAS_CXX11_INITIALIZER_LIST
        HAS_CXX11_CLASS_OVERRIDE)
    if (${flag})
        add_definitions("-D${flag}")
        message(STATUS "Compiler C++11 support flag ${flag} set")
    endif ()
endforeach (flag)

set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} ${CXX11_COMPILER_FLAGS})
add_executable(CXX11Features cxx11features.cxx)
