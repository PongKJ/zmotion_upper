# TODO: Check MSVC /fsanitize-coverage support

function(zmotion_upper_check_libfuzzer_support var_name)
  set(LibFuzzerTestSource
      "
#include <cstdint>
extern \"C\" int LLVMFuzzerTestOneInput(const std::uint8_t *data, std::size_t size) {
  return 0;
}
    ")
  include(CheckCXXSourceCompiles)
  set(CMAKE_REQUIRED_FLAGS "-fsanitize=fuzzer")
  set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=fuzzer")
  check_cxx_source_compiles("${LibFuzzerTestSource}" ${var_name})
endfunction()

function(zmotion_upper_check_sanitizer_support sanitizer_type var_name)
  include(CheckCXXSourceCompiles)
  if(NOT MSVC)
    set(CMAKE_REQUIRED_FLAGS "-fsanitize=${sanitizer_type}")
    set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=${sanitizer_type}")
  else()
    set(CMAKE_REQUIRED_FLAGS "/fsanitize=${sanitizer_type} /Zi /INCREMENTAL:NO")
    set(CMAKE_REQUIRED_LINK_OPTIONS "/INCREMENTAL:NO")
    set(CMAKE_REQUIRED_DEFINITIONS "_DISABLE_VECTOR_ANNOTATION _DISABLE_STRING_ANNOTATION")
  endif()
  check_cxx_source_compiles("int main() {return 0;}" ${var_name})
endfunction()
