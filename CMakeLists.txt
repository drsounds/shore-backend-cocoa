cmake_minimum_required(VERSION 3.16)
project(shore-backend-cocoa VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

if(NOT APPLE)
  message(FATAL_ERROR "The Cocoa backend is only supported on macOS")
endif()
enable_language(OBJCXX)

find_package(shore CONFIG REQUIRED)

add_library(shore_backend_cocoa SHARED src/cocoa_backend.mm)
add_library(shore-backend-cocoa::shore-backend-cocoa ALIAS shore_backend_cocoa)
set_target_properties(shore_backend_cocoa PROPERTIES EXPORT_NAME shore-backend-cocoa)
target_include_directories(shore_backend_cocoa
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  PRIVATE src
)
target_link_libraries(shore_backend_cocoa PUBLIC shore::shore "-framework Cocoa")

install(TARGETS shore_backend_cocoa EXPORT shoreBackendCocoaTargets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(EXPORT shoreBackendCocoaTargets
  FILE shoreBackendCocoaTargets.cmake
  NAMESPACE shore-backend-cocoa::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/shore-backend-cocoa
)

configure_package_config_file(
  cmake/shore-backend-cocoaConfig.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/shore-backend-cocoaConfig.cmake"
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/shore-backend-cocoa
)
write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/shore-backend-cocoaConfigVersion.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
)
install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/shore-backend-cocoaConfig.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/shore-backend-cocoaConfigVersion.cmake"
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/shore-backend-cocoa
)
