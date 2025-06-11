#include "zmc_controller.h"

#include <spdlog/spdlog.h>

ZMCController::ZMCController( const char* ipaddr ) {
    _handle = nullptr;
    if ( ZMC_OpenEth( const_cast< char* >( ipaddr ), &_handle ) != 0 ) {
        spdlog::error( "Failed to open ZMC controller with IP: {}", ipaddr );
        throw std::runtime_error( "Failed to open ZMC controller" );
    }
    else {
        spdlog::info( "ZMC controller opened successfully with IP: {}", ipaddr );
    }
}

ZMCController::~ZMCController() {
    if ( _handle != nullptr ) {
        if ( ZMC_Close( _handle ) != 0 ) {
            spdlog::error( "Failed to close ZMC controller" );
        }
        else {
            spdlog::info( "ZMC controller closed successfully" );
        }
    }
}
