//
//  CMBDFrameworkDefines.h
//  CleverBadge
//
//  Created by imlab_DEV on 14-6-30.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#ifndef CleverBadge_CMBDFrameworkDefines_h
#define CleverBadge_CMBDFrameworkDefines_h


typedef enum {
    CMBDConnectorType_Unknown,
    CMBDConnectorType_BetwineApp,
} CMBDPeripheralConnectorType;

typedef enum {
    CMBDPeripheralConnectorFeature_BetwineApp_1_0,
    CMBDPeripheralConnectorFeature_BetwinwApp_1_1,
} CMBDPeripheralConnectorFeature; // for onPCReady delegate method

#define CMBD_EVT_CENTRAL_MGR_BECOME_AVAILABLE @"CMBD.CentralManager.Available"
#define CMBD_EVT_CENTRAL_MGR_BECOME_UNAVAILABLE @"CMBD.CentralManager.Unavailable"

#define CMBD_EVT_DEVICE_APP_READY @"CMBD.Device.App.Ready"

#define CMBD_CONN_EVT_START_SCAN @"CMBD.Connection.StartScan"
#define CMBD_CONN_EVT_STOP_SCAN @"CMBD.Connection.StopScan"

#define CMBD_CONN_EVT_CONNCETED @"CMBD.Connectino.Connected"
#define CMBD_CONN_EVT_DISCONNECTED @"CMBD.Connection.Disconnected"
#define CMBD_CONN_EVT_CANCEL @"CMBD.Connection.Cancel"

#endif
