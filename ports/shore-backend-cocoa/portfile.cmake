if(NOT VCPKG_TARGET_IS_OSX)
  message(FATAL_ERROR "shore-backend-cocoa requires macOS")
endif()

set(SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}/../..")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/shore-backend-cocoa)
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
