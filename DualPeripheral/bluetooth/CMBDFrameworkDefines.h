//
//  Created by imlab_DEV on 14-6-30.
//  Copyright (c) 2014 imlab.cc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#ifndef CleverBadge_CMBDFrameworkDefines_h
#define CleverBadge_CMBDFrameworkDefines_h


typedef enum {
    CMBDConnectorType_Unknown,
    CMBDConnectorType_BetwineApp,
    CMBDConnectorType_PowerGrip,
} CMBDPeripheralConnectorType;

typedef enum {
    CMBDPeripheralConnectorFeature_BetwineApp_1_0,
    CMBDPeripheralConnectorFeature_BetwinwApp_1_1,
    CMBDPeripheralConnectorFeature_PowerGrip_1_0,
} CMBDPeripheralConnectorFeature; // for onPCReady delegate method

#define CMBD_MAC_SERVICE_UUID             @"180A"
#define CMBD_MAC_CHAR_UUID               0x2A23
#define CMBD_MAC_VALUE_LEN                8


#define CMBD_NTF_DICT_KEY_DEVICE_ID @"deviceId"         // in iOS, deviceId is designed to be device UUID
#define CMBD_NTF_DICT_KEY_KEEP_CONNECTION @"keepConn"
#define CMBD_NTF_DICT_KEY_CHOICENAMES @"choiceNames"
#define CMBD_NTF_DICT_KEY_DEVICE_ID_LIST @"deviceIdList"      // in iOS, deviceId is device UUID

#define CMBD_EVT_CENTRAL_MGR_BECOME_AVAILABLE @"CMBD.CentralManager.Available"
#define CMBD_EVT_CENTRAL_MGR_BECOME_UNAVAILABLE @"CMBD.CentralManager.Unavailable"

#define CMBD_CONN_EVT_MGR_DISABLED_ERROR @"CMBD.Connection.Manager.Disabled"
#define CMBD_CONN_EVT_START_SCAN @"CMBD.Connection.StartScan"
#define CMBD_CONN_EVT_STOP_SCAN @"CMBD.Connection.StopScan"

#define CMBD_CONN_EVT_CONNECTED @"CMBD.Connectino.Connected"
#define CMBD_CONN_EVT_DISCONNECTED @"CMBD.Connection.Disconnected"
#define CMBD_CONN_EVT_CONNECTING @"CMBD.Connection.Connecting"

#endif
