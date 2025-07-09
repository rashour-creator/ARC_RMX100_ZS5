#pragma once 

#include "config.h"

typedef unsigned long uint32;
typedef unsigned long long uint64;
typedef unsigned char uint8;
typedef signed char int8;
typedef signed short int16;
typedef signed long int32;
typedef signed long long int64; 

typedef float float32;
typedef double float64;

#define MAX_INPUT_SZ	3200U  //400 locations if data width is 8 bytes
#define FIRST_PACKET_OVERHEAD	(1+4)
#define INPUT_BASE_ADDR		32


#if AXI_VERSION_64B == 1
#define REG_SZ_BYTES		8
typedef unsigned long long 	AXI_DATA_TYPE;

#elif AXI_VERSION_32B == 1

#define REG_SZ_BYTES		4
typedef unsigned long 		AXI_DATA_TYPE;
#endif
#define DETECTIONS_SZ (MAX_NUM_DETECTIONS *  REG_SZ_BYTES)
class SynchronizationFlags
{
    public:
        SynchronizationFlags()
        {
            socketThreadStarted = false;
            clientAccepted = false;
            dataReceived = false;
            terminateARCApp = false;
        }

        bool socketThreadStarted;
        bool clientAccepted;
        bool dataReceived;
        bool terminateARCApp;
};

typedef enum
{
    AXI_ACC_CLIENT_RECV_DATA_FLAG = 0,
    AXI_INPUT_DATA_READY_FLAG = 8,
    AXI_TERMINATE_APP_FLAG = 16,
    AXI_SEND_OUTPUT_ADDR_FLAG = 24,

    AXI_INPUT_BASE_ADDR = 32,
    AXI_IMAGE_BASE_ADDR = 32,
    AXI_OUTPUT_BASE_ADDR = 3232
}address_type;