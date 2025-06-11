#pragma once
#include <zmotion.h>

class ZMCController {
public:
    explicit ZMCController( const char* ipaddr );
    ~ZMCController();

private:
    ZMC_HANDLE _handle;
};
