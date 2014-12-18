//
//  BTPowerGripAppDefines.h
//  BluetoothXDemo
//
//  Created by imlab_DEV on 14-11-20.
//
//

#ifndef BluetoothXDemo_BTPowerGripAppDefines_h
#define BluetoothXDemo_BTPowerGripAppDefines_h


/* Peripheral Connector Defines */
#define CB_PG_PRODUCT_ID_LIST @[@"1101"] // if you have more product ID defines

#define CB_BROADCAST_SVC_UUID_POWERGRIP @"AB00"

#define CB_PG_JOYSTICK_SERVICE_UUID              0xAB10
#define CB_PG_JOYSTICK_VALUE_UUID                0xAB11
#define CB_PG_JOYSTICK_VALUE_LEN                 1

#define CB_PG_MAC_SERVICE_UUID             0x180A
#define CB_PG_MAC_VALUE_UUID               0x2A23
#define CB_PG_MAC_VALUE_LEN                8


#define CB_PG_EVT_RECEIVE_JS @"PG.EVT.JoystickUpdate"
#define CB_PG_EVT_RECEIVE_DEVICE_INFO   @"PG.EVT.DeviceInfoUpdate"

#define CMBD_NTF_PG_DICT_KEY_PROD_ID @"prodId"
#define CMBD_NTF_PG_DICT_KEY_MAC @"macAddr"
#define CMBD_NTF_PG_DICT_KEY_JS_VALUE @"jsValue"

#endif
