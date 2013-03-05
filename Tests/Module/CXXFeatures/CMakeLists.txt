cmake_minimum_required(VERSION 2.8.3 FATAL_ERROR)
project(CxxFeatures CXX)

find_package(CXXFeatures)

foreach (flag IN ITEMS
        CXXFEATURES_STATIC_ASSERT_FOUND
        CXXFEATURES_LONG_LONG_FOUND
        CXXFEATURES_RVALUE_REFERENCES_FOUND
        CXXFEATURES_CONSTEXPR_FOUND
        CXXFEATURES_SIZEOF_MEMBER_FOUND
        CXXFEATURES___FUNC___FOUND
        CXXFEATURES_NULLPTR_FOUND
        CXXFEATURES_CSTDINT_FOUND
        CXXFEATURES_INITIALIZER_LIST_FOUND
        CXXFEATURES_CLASS_OVERRIDE_FOUND
        CXXFEATURES_DECLTYPE_FOUND
        CXXFEATURES_LAMBDA_FOUND
        CXXFEATURES_VARIADIC_TEMPLATES_FOUND
        )
    if (${flag})
        add_definitions("-D${flag}")
        message(STATUS "Compiler C++ support flag ${flag} set")
    endif ()
endforeach (flag)

set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} ${CXX11_COMPILER_FLAGS})
add_executable(CXXFeatures cxxfeatures.cxx)

enable_testing()
if (NOT CROSS_COMPILING)
    add_test(NAME CXXFeatures COMMAND CXXFeatures)
endif ()
