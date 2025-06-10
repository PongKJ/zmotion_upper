#include <qapplication.h>
#define DBG_MACRO_NO_WARNING
#include <dbg.h>
#include <json/json.h>
#include <spdlog/common.h>
#include <spdlog/spdlog.h>

#include <CLI/CLI.hpp>
#include <QApplication>
#include <QScreen>
#include <cstdlib>
#include <internal_use_only/config.hpp>

#include "ElaApplication.h"
#include "mainwindow.h"

int main( [[maybe_unused]] int argc, [[maybe_unused]] char* argv[] ) {
    spdlog::set_level( spdlog::level::debug );
    spdlog::debug( "hello world" );
    QGuiApplication::setAttribute( Qt::AA_EnableHighDpiScaling );
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy( Qt::HighDpiScaleFactorRoundingPolicy::PassThrough );
    QApplication a( argc, argv );
    eApp->init();
    MainWindow w;
    w.show();
    return QApplication::exec();
}
