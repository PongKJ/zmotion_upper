#include <qapplication.h>
#define DBG_MACRO_NO_WARNING
#include <dbg.h>
#include <json/json.h>
#include <spdlog/common.h>
#include <spdlog/spdlog.h>

#include <CLI/CLI.hpp>
#include <QApplication>
#include <QScreen>
#include <internal_use_only/config.hpp>

#include "ElaApplication.h"
#include "control/zmc_controller.h"
#include "view/mainwindow.h"

int main( [[maybe_unused]] int argc, [[maybe_unused]] char* argv[] ) {
    try {
        ZMCController controller( "127.0.0.1" );
    }
    catch ( const std::exception& ) {
    }
    spdlog::set_level( spdlog::level::debug );
    spdlog::debug( "Starting App ..." );
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy( Qt::HighDpiScaleFactorRoundingPolicy::PassThrough );
    QApplication a( argc, argv );
    eApp->init();
    MainWindow w;
    w.show();
    return QApplication::exec();
}
