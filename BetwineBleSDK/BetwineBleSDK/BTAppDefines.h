//
//  BTAppDefines.h
//  CleverBadge
//
//  Created by imlab_DEV on 14-7-14.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#ifndef CleverBadge_BTAppDefines_h
#define CleverBadge_BTAppDefines_h

/* Peripheral Connector Defines */
#define CB_BROADCAST_SVC_UUID_APP @"aa20"

#define CB_HP_SERVICE_UUID              0xAA10
#define CB_HP_VALUE_UUID                0xAA11
#define CB_HP_VALUE_LEN                 1

#define CB_PM_SERVICE_UUID              0xAA20
#define CB_PM_STATE_UUID                0xAA21
#define CB_PM_VALUE_UUID                0xAA22
#define CB_PM_STATE_LEN                 1
#define CB_PM_VALUE_LEN                 3

#define CB_MR_SERVICE_UUID              0xAA30
#define CB_MR_VALUE_UUID                0xAA31
#define CB_MR_VALUE_LEN                 1
#define CB_MR_TEST_VALUE_UUID           0xAA32
#define CB_MR_TEST_VALUE_LEN            4

#define CB_TS_SERVICE_UUID              0xAA50
#define CB_TS_VALUE_UUID                0xAA51
#define CB_TS_VALUE_LEN                 6

#define CB_BS_SERVICE_UUID              0xAA60
#define CB_BS_VALUE_UUID                0xAA61
#define CB_BS_VALUE_LEN                 1

#define CB_HS_SERVICE_UUID              0xAA70
#define CB_HS_STEPS_UUID                0xAA71
#define CB_HS_VALUE_LEN                 21

#define CB_MAC_SERVICE_UUID             0x180A
#define CB_MAC_VALUE_UUID               0x2A23
#define CB_MAC_VALUE_LEN                8


/* Peripheral Interface Defines */

#define CMBD_EVT_RECEIVE_STEPS @"EVT.StepsUpdate"
#define CMBD_EVT_RECEIVE_ENERGY @"EVT.EnergyUpdate"
#define CMBD_EVT_RECEIVE_TIME @"EVT.BadgeTimeUpdate"
#define CMBD_EVT_RECEIVE_ACT @"EVT.ActivityUpdate"
#define CMBD_EVT_RECEIVE_ALL_STATUS @"EVT.AllStatusUpdate"
#define CMBD_EVT_RECEIVE_HISTORY_STEPS @"EVT.StepsHistoryUpdate"
#define CMBD_EVT_RECEIVE_BATTERY @"EVT.BatteryUpdate"
#define CMBD_EVT_RECEIVE_DEVICE_INFO   @"EVT.DeviceInfoUpdate"
#define CMBD_EVT_RECEIVE_LAST_VIBRATE @"EVT.LastVibrateTime"

#define CMBD_EVT_RECEIVE_ACTIVE_MOVE @"EVT.ActiveMove" // for user to accept task

//typedef enum { // battery charging state
//    CMBD_BATT_NO_CHARGING,
//    CMBD_BATT_CHARGING,
//    CMBD_BATT_CHARGING_FULL,
//} CMBD_BATT_CHARGING_STATUS;

// device system test operation code
#define CB_DEVICE_TEST_RESET 0xE0
#define CB_DEVICE_TEST_HIBERNATE 0xC0
#define CB_DEVICE_TEST_SYS_1 0x80
#define CB_DEVICE_TEST_SYS_2  0x40


#endif
