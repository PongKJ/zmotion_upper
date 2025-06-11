find_package(spdlog REQUIRED)
find_package(jsoncpp REQUIRED)
find_package(dbg-macro REQUIRED)
find_package(CLI11 REQUIRED)
find_package(Qt6 REQUIRED)

qt_standard_project_setup()
qt_add_executable(
  upper
  main.cc
  view/mainwindow.cc
  view/about.cc
  control/zmc_controller.cc)

target_link_directories(upper PRIVATE "${CMAKE_SOURCE_DIR}/third_party/zmotion/lib")
target_link_libraries(upper PRIVATE zmotion_upper::zmotion_upper_options zmotion_upper::zmotion_upper_warnings zmotion)
target_include_directories(upper PRIVATE "${CMAKE_SOURCE_DIR}/third_party/zmotion/include")

target_link_system_libraries(
  upper
  PRIVATE
  spdlog::spdlog
  JsonCpp::JsonCpp
  dbg-macro::dbg-macro
  CLI11::CLI11
  ElaWidgetTools
  qt::qt)

target_include_directories(upper PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")

#遍历所有资源文件
file(
  GLOB_RECURSE
  RES_PATHS
  *.png
  *.jpg
  *.svg
  *.ico
  *.ttf
  *.webp
  *.js)
foreach(filepath ${RES_PATHS})
  string(
    REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/"
            ""
            filename
            ${filepath})
  list(APPEND resource_files ${filename})
endforeach(filepath)

qt_add_resources(
  upper
  "ElaWidgetToolsExample"
  RESOURCES
  PREFIX
  "/"
  FILES
  ${resource_files})

qt_generate_deploy_app_script(
  TARGET
  upper
  #NO_COMPILER_RUNTIME
  NO_TRANSLATIONS
  OUTPUT_SCRIPT
  deploy_script)
install(SCRIPT ${deploy_script})
