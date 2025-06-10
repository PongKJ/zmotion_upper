find_package(spdlog REQUIRED)
find_package(jsoncpp REQUIRED)
find_package(dbg-macro REQUIRED)
find_package(CLI11 REQUIRED)
find_package(Qt6 REQUIRED)

qt_standard_project_setup()
qt_add_executable(gui main.cc mainwindow.cc)

target_link_libraries(gui PRIVATE zmotion_upper::zmotion_upper_options zmotion_upper::zmotion_upper_warnings)
target_link_system_libraries(
  gui
  PRIVATE
  spdlog::spdlog
  JsonCpp::JsonCpp
  dbg-macro::dbg-macro
  CLI11::CLI11
  ElaWidgetTools
  qt::qt)

target_include_directories(gui PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")

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
  gui
  "ElaWidgetToolsExample"
  RESOURCES
  PREFIX
  "/"
  FILES
  ${resource_files})

qt_generate_deploy_app_script(
  TARGET
  gui
  #NO_COMPILER_RUNTIME
  NO_TRANSLATIONS
  OUTPUT_SCRIPT
  deploy_script)
install(SCRIPT ${deploy_script})
