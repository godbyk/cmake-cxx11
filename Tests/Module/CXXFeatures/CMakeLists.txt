cmake_minimum_required(VERSION 2.8.3 FATAL_ERROR)
project(CxxFeatures CXX)

include(CheckCXXFeatures)

foreach (flag IN ITEMS
        HAS_CXX_STATIC_ASSERT
        HAS_CXX_LONG_LONG
        HAS_CXX_RVALUE_REFERENCES
        HAS_CXX_CONSTEXPR
        HAS_CXX_SIZEOF_MEMBER
        HAS_CXX___FUNC__
        HAS_CXX_NULLPTR
        HAS_CXX_CSTDINT
        HAS_CXX_INITIALIZER_LIST
        HAS_CXX_CLASS_OVERRIDE
        HAS_CXX_DECLTYPE
        HAS_CXX_LAMBDA
        HAS_CXX_VARIADIC_TEMPLATES
        )
    if (${flag})
        add_definitions("-D${flag}")
        message(STATUS "Compiler C++ support flag ${flag} set")
    endif ()
endforeach (flag)

set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} ${CXX11_COMPILER_FLAGS})
add_executable(CXXFeatures cxxfeatures.cxx)
