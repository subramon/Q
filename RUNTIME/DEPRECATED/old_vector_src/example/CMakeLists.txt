cmake_minimum_required (VERSION 2.8)
project (lcounter C)
 
find_package(Lua REQUIRED)
 
include_directories (
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${LUA_INCLUDE_DIR}
)
 
set (SOURCES
    counter.c
    wrap.c
)
 
add_library (${PROJECT_NAME} SHARED ${SOURCES} ${LUA_LIBRARIES})
target_link_libraries (${PROJECT_NAME} lua)
set_target_properties (${PROJECT_NAME} PROPERTIES PREFIX "")
