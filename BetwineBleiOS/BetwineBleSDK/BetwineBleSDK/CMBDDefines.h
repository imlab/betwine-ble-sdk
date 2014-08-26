//
//  CMBDDefines.h
//  BetwineBTFlowPrototype
//
//  Created by imlab_DEV on 13-11-29.
//  Copyright (c) 2013年 cc.imlab.prototype. All rights reserved.
//

#ifndef BetwineBTFlowPrototype_CMBDDefines_h
#define BetwineBTFlowPrototype_CMBDDefines_h

// status of connection manager
typedef enum {
    CMBD_CONN_STATUS_NO_CONNECTION,
    CMBD_CONN_STATUS_SCANNING,
    CMBD_CONN_STATUS_CONNECTING, // means trying to connect?
    CMBD_CONN_STATUS_READY,
} CMBD_CONNECTION_STATUS;

typedef enum {
    CMBD_DEVICE_MODE_ALL,
    CMBD_DEVICE_MODE_APP,
    CMBD_DEVICE_MODE_OAD,
} CMBDDeviceMode; // represent the mode in which the device is working


// capabilities of active peripheral (using bit-masking)
typedef enum {
    CMBD_CAP_TYPE_OAD = 1 << 0,
    CMBD_CAP_TYPE_APP = 1 << 1,
    CMBD_CAP_TYPE_PUB = 1 << 2,
} CMBD_CAP_TYPE;

// battery charging state
typedef enum {
    CMBD_BATT_NO_CHARGING,
    CMBD_BATT_CHARGING,
    CMBD_BATT_CHARGING_FULL,
} CMBD_BATT_CHARGING_STATUS;

// connection manager events
#define CMBD_CONN_EVT_NO_CONNECTION @"CMBD.Connection.NoConnection"
#define CMBD_CONN_EVT_START_SCAN @"CMBD.Connection.StartScan"
#define CMBD_CONN_EVT_STOP_SCAN @"CMBD.Connection.StopScan"


#define CMBD_CONN_EVT_PC_SVC_DISCOVER @"CMBD.Service.Discover"
#define CMBD_CONN_EVT_PC_APP_READY @"CMBD.Service.APP.Ready"
#define CMBD_CONN_EVT_PC_OAD_READY @"CMBD.Service.OAD.Ready"


/* This delegate protocol is for different CMBD service module to interact with CMBDBadgeConnectionManager. It should be referenced by the CMBD service managers and ONLY implemented by CMBDBadgeConnectionmManager. */
@protocol CMBDPeripheralServiceStatusDelegate <NSObject>
-(void)badgeAppReady;
-(void)badgeOADReady;
-(void)badgePubReady;
@end



#endif
