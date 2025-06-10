# Changed cmake_minimum_required from 3.21 to 3.27 to prevent compile error
cmake_minimum_required(VERSION 3.27)

set(CMAKE_PROJECT_TOP_LEVEL_INCLUDES "cmake/ConanProvider.cmake")
# Only set the cxx_standard if it is not set by someone else
if(NOT DEFINED CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 20)
endif()

# Set the project name and language
project(
  zmotion_upper
  VERSION 0.0.7
  DESCRIPTION ""
  HOMEPAGE_URL "https://github.com/PongKJ/zmotion_upper"
  LANGUAGES CXX C)

# strongly encouraged to enable this globally to avoid conflicts between -Wpedantic being enabled
# and -std=c++20 and -std=gnu++20 for example when compiling with PCH enabled
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
  set(CMAKE_CXX_EXTENSIONS ON)
endif()

include(cmake/PreventInSourceBuilds.cmake)
include(ProjectOptions.cmake)

zmotion_upper_setup_options()

zmotion_upper_global_options()

zmotion_upper_local_options()

# don't know if this should be set globally from here or not...
set(CMAKE_CXX_VISIBILITY_PRESET hidden)

set(GIT_SHA
    "Unknown"
    CACHE STRING "SHA this build was generated from")
string(
  SUBSTRING "${GIT_SHA}"
            0
            8
            GIT_SHORT_SHA)

target_compile_features(zmotion_upper_options INTERFACE cxx_std_${CMAKE_CXX_STANDARD})

add_library(zmotion_upper::zmotion_upper_options ALIAS zmotion_upper_options)
add_library(zmotion_upper::zmotion_upper_warnings ALIAS zmotion_upper_warnings)

# add_library(zmotion_upper::zmotion_upper_options INTERFACE IMPORTED)
# add_library(zmotion_upper::zmotion_upper_warnings INTERFACE IMPORTED)

# configure files based on CMake configuration options
add_subdirectory(configured_files)

# Adding the src:
add_subdirectory(src)

# Don't even look at tests if we're not top level
if(NOT PROJECT_IS_TOP_LEVEL)
  return()
endif()

# Adding the tests:
include(CTest)

if(BUILD_TESTING)
  message(AUTHOR_WARNING "Building Tests. Be sure to check out test/constexpr_tests.cpp for constexpr testing")
  add_subdirectory(test)
endif()

if(zmotion_upper_BUILD_FUZZ_TESTS)
  message(AUTHOR_WARNING "Building Fuzz Tests, using fuzzing sanitizer https://www.llvm.org/docs/LibFuzzer.html")
  if(NOT zmotion_upper_ENABLE_ADDRESS_SANITIZER AND NOT zmotion_upper_ENABLE_THREAD_SANITIZER)
    message(WARNING "You need asan or tsan enabled for meaningful fuzz testing")
  endif()
  add_subdirectory(fuzz_test)

endif()

include(cmake/Utilities.cmake)
# If MSVC is being used, and ASAN is enabled, we need to set the debugger environment so that it
# behaves well with MSVC's debugger, and we can run the target from visual studio
if(MSVC)
  get_all_installable_targets(all_targets)
  message("all_targets=${all_targets}")
  set_target_properties(${all_targets} PROPERTIES VS_DEBUGGER_ENVIRONMENT "PATH=$(VC_ExecutablePath_x64);%PATH%")
endif()

# set the startup project for the "play" button in MSVC
set_property(DIRECTORY PROPERTY VS_STARTUP_PROJECT gui)

if(CMAKE_SKIP_INSTALL_RULES)
  return()
endif()

include(cmake/PackageProject.cmake)

# Add other targets that you want installed here, by default we just package the one executable we
# know we want to ship
zmotion_upper_package_project(
  TARGETS
  gui
  # zmotion_upper_options
  # zmotion_upper_warnings
  # FIXME: this does not work! CK PRIVATE_DEPENDENCIES_CONFIGURED project_options project_warnings
)

set(CPACK_PACKAGE_FILE_NAME
    "${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}-${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")
include(CPack)
