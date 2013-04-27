cmake_minimum_required(VERSION 2.8.3 FATAL_ERROR)
project(CxxFeatures CXX)

find_package(CXXFeatures)

foreach (flag IN ITEMS
        CXXFeatures_auto_FOUND
        CXXFeatures_class_override_final_FOUND
        CXXFeatures_constexpr_FOUND
        CXXFeatures_cstdint_header_FOUND
        CXXFeatures_decltype_FOUND
        CXXFeatures_defaulted_functions_FOUND
        CXXFeatures_deleted_functions_FOUND
        CXXFeatures_func_identifier_FOUND
        CXXFeatures_initializer_list_FOUND
        CXXFeatures_lambda_FOUND
        CXXFeatures_long_long_FOUND
        CXXFeatures_nullptr_FOUND
        CXXFeatures_rvalue_references_FOUND
        CXXFeatures_sizeof_member_FOUND
        CXXFeatures_static_assert_FOUND
        CXXFeatures_variadic_templates_FOUND
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
