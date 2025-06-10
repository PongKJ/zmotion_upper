include(cmake/SystemLink.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)
include(cmake/CompilerCheck.cmake)

macro(zmotion_upper_setup_options)
  # NOTE: enable hardening may cause build failed in debug mode
  option(zmotion_upper_ENABLE_HARDENING "Enable hardening" OFF)
  option(zmotion_upper_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    zmotion_upper_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    zmotion_upper_ENABLE_HARDENING
    OFF)

  if(NOT PROJECT_IS_TOP_LEVEL OR zmotion_upper_PACKAGING_MAINTAINER_MODE)
    option(zmotion_upper_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(zmotion_upper_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(zmotion_upper_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(zmotion_upper_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(zmotion_upper_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(zmotion_upper_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(zmotion_upper_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(zmotion_upper_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(zmotion_upper_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(zmotion_upper_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(zmotion_upper_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(zmotion_upper_ENABLE_PCH "Enable precompiled headers" OFF)
    option(zmotion_upper_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(zmotion_upper_ENABLE_IPO "Enable IPO/LTO" ON)
    option(zmotion_upper_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(zmotion_upper_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(zmotion_upper_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(zmotion_upper_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(zmotion_upper_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(zmotion_upper_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(zmotion_upper_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(zmotion_upper_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(zmotion_upper_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(zmotion_upper_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(zmotion_upper_ENABLE_PCH "Enable precompiled headers" OFF)
    option(zmotion_upper_ENABLE_CACHE "Enable ccache" ON)
  endif()
  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      zmotion_upper_ENABLE_IPO
      zmotion_upper_WARNINGS_AS_ERRORS
      zmotion_upper_ENABLE_USER_LINKER
      zmotion_upper_ENABLE_SANITIZER_ADDRESS
      zmotion_upper_ENABLE_SANITIZER_LEAK
      zmotion_upper_ENABLE_SANITIZER_UNDEFINED
      zmotion_upper_ENABLE_SANITIZER_THREAD
      zmotion_upper_ENABLE_SANITIZER_MEMORY
      zmotion_upper_ENABLE_UNITY_BUILD
      zmotion_upper_ENABLE_CLANG_TIDY
      zmotion_upper_ENABLE_CPPCHECK
      zmotion_upper_ENABLE_COVERAGE
      zmotion_upper_ENABLE_PCH
      zmotion_upper_ENABLE_CACHE)
  endif()

  zmotion_upper_check_sanitizer_support("address" SUPPORTS_ASAN)
  zmotion_upper_check_sanitizer_support("memory" SUPPORTS_MSAN)
  zmotion_upper_check_sanitizer_support("undefined" SUPPORTS_UBSAN)
  zmotion_upper_check_sanitizer_support("leak" SUPPORTS_LSAN)
  zmotion_upper_check_sanitizer_support("thread" SUPPORTS_TSAN)
  if(NOT SUPPORTS_ASAN AND zmotion_upper_ENABLE_SANITIZER_ADDRESS)
    message(WARNING "Address sanitizer is not supported. Disabling zmotion_upper_ENABLE_SANITIZER_ADDRESS")
    set(zmotion_upper_ENABLE_SANITIZER_ADDRESS OFF)
  endif()
  if(NOT SUPPORTS_MSAN AND zmotion_upper_ENABLE_SANITIZER_MEMORY)
    message(WARNING "Memory sanitizer is not supported. Disabling zmotion_upper_ENABLE_SANITIZER_MEMORY")
    set(zmotion_upper_ENABLE_SANITIZER_MEMORY OFF)
  endif()
  if(NOT SUPPORTS_UBSAN AND zmotion_upper_ENABLE_SANITIZER_UNDEFINED)
    message(WARNING "Undefined sanitizer is not supported. Disabling zmotion_upper_ENABLE_SANITIZER_UNDEFINED")
    set(zmotion_upper_ENABLE_SANITIZER_UNDEFINED OFF)
  endif()
  if(NOT SUPPORTS_LSAN AND zmotion_upper_ENABLE_SANITIZER_LEAK)
    message(WARNING "Leak sanitizer is not supported. Disabling zmotion_upper_ENABLE_SANITIZER_LEAK")
    set(zmotion_upper_ENABLE_SANITIZER_LEAK OFF)
  endif()
  if(NOT SUPPORTS_TSAN AND zmotion_upper_ENABLE_SANITIZER_THREAD)
    message(WARNING "Thread sanitizer is not supported. Disabling zmotion_upper_ENABLE_SANITIZER_THREAD")
    set(zmotion_upper_ENABLE_SANITIZER_THREAD OFF)
  endif()

  zmotion_upper_check_libfuzzer_support(LIBFUZZER_SUPPORTED)
  if(LIBFUZZER_SUPPORTED
     AND (zmotion_upper_ENABLE_SANITIZER_ADDRESS
          OR zmotion_upper_ENABLE_SANITIZER_THREAD
          OR zmotion_upper_ENABLE_SANITIZER_UNDEFINED))
    set(DEFAULT_FUZZER ON)
  else()
    set(DEFAULT_FUZZER OFF)
  endif()

  option(zmotion_upper_BUILD_FUZZ_TESTS "Enable fuzz testing executable" ${DEFAULT_FUZZER})

endmacro()

macro(zmotion_upper_global_options)
  if(zmotion_upper_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    zmotion_upper_enable_ipo()
  endif()

  if(zmotion_upper_ENABLE_HARDENING AND zmotion_upper_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN
       OR zmotion_upper_ENABLE_SANITIZER_UNDEFINED
       OR zmotion_upper_ENABLE_SANITIZER_ADDRESS
       OR zmotion_upper_ENABLE_SANITIZER_THREAD
       OR zmotion_upper_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message(
      "${zmotion_upper_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${zmotion_upper_ENABLE_SANITIZER_UNDEFINED}")
    zmotion_upper_enable_hardening(zmotion_upper_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(zmotion_upper_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(zmotion_upper_warnings INTERFACE)
  add_library(zmotion_upper_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  zmotion_upper_set_project_warnings(
    zmotion_upper_warnings
    ${zmotion_upper_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  if(zmotion_upper_ENABLE_USER_LINKER)
    include(cmake/Linker.cmake)
    zmotion_upper_configure_linker(zmotion_upper_options)
  endif()

  include(cmake/Sanitizers.cmake)
  zmotion_upper_enable_sanitizers(
    zmotion_upper_options
    ${zmotion_upper_ENABLE_SANITIZER_ADDRESS}
    ${zmotion_upper_ENABLE_SANITIZER_LEAK}
    ${zmotion_upper_ENABLE_SANITIZER_UNDEFINED}
    ${zmotion_upper_ENABLE_SANITIZER_THREAD}
    ${zmotion_upper_ENABLE_SANITIZER_MEMORY})

  set_target_properties(zmotion_upper_options PROPERTIES UNITY_BUILD ${zmotion_upper_ENABLE_UNITY_BUILD})

  if(zmotion_upper_ENABLE_PCH)
    target_precompile_headers(
      zmotion_upper_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(zmotion_upper_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    zmotion_upper_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(zmotion_upper_ENABLE_CLANG_TIDY)
    zmotion_upper_enable_clang_tidy(zmotion_upper_options ${zmotion_upper_WARNINGS_AS_ERRORS})
  endif()

  if(zmotion_upper_ENABLE_CPPCHECK)
    zmotion_upper_enable_cppcheck(${zmotion_upper_WARNINGS_AS_ERRORS} "") # override cppcheck options
  endif()

  if(zmotion_upper_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    zmotion_upper_enable_coverage(zmotion_upper_options)
  endif()

  if(zmotion_upper_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(zmotion_upper_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(zmotion_upper_ENABLE_HARDENING AND NOT zmotion_upper_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN
       OR zmotion_upper_ENABLE_SANITIZER_UNDEFINED
       OR zmotion_upper_ENABLE_SANITIZER_ADDRESS
       OR zmotion_upper_ENABLE_SANITIZER_THREAD
       OR zmotion_upper_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    zmotion_upper_enable_hardening(zmotion_upper_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()
