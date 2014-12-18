//
//  BTPowerGripAppInterface.m
//  BluetoothXDemo
//
//  Created by imlab_DEV on 14-11-20.
//
//

#import "BTPowerGripAppInterface.h"
#import "BTPowerGripAppDefines.h"

@implementation BTPowerGripAppInterface


#pragma mark -- CMBDPeripheralInterface methods

-(BTPowerGripAppPC*)myConnector
{
    return (BTPowerGripAppPC*)self.connector;
}

-(void)onPCReady:(CMBDPeripheralConnectorFeature)feature {
    switch (feature) {
        case CMBDPeripheralConnectorFeature_PowerGrip_1_0:
        {
            NSLog(@"[BTPowerGripAppInterface] BTPowerGripAppPC v1.0 ready");
            
            [[self myConnector] enableJoystick];
            [[self myConnector] readDeviceInfo];
            
            [self postNotification:CMBD_CONN_EVT_CONNECTED userInfo:@{CMBD_NTF_DICT_KEY_DEVICE_ID:self.bleDevice.deviceId}];
        }
            break;
        default:
            break;
    }
}

-(BOOL)sendReadDeviceInfo
{
    if ([self myConnector].activePeripheral == nil) {
        NSLog(@"[CMBD] device not connected, ignore send read device info command");
        return NO;
    }
    NSLog(@"[CMBD] send read device info");
    
    [[self myConnector] readDeviceInfo];
    
    return YES;
}

-(void)jsUpdate:(Byte)jsValue {
    NSLog(@"[BTPowerGripAppInterface] receive joystick value: %c", jsValue);
    
    [self postNotification:CB_PG_EVT_RECEIVE_JS userInfo:@{CMBD_NTF_PG_DICT_KEY_JS_VALUE:[NSNumber numberWithChar:jsValue]}];
}

-(void)deviceInfoUpdate:(Byte *)bytes
{
    self.bleDevice.productId = [NSString stringWithFormat:@"%02x%02x", bytes[0], bytes[1]];
    self.bleDevice.macAddr = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7]];
    
    NSLog(@"[BTPowerGripAppInterface] Receive product id: %@ mac addr: %@", self.bleDevice.productId, self.bleDevice.macAddr);
    
    [self postNotification:CB_PG_EVT_RECEIVE_DEVICE_INFO userInfo:@{ CMBD_NTF_PG_DICT_KEY_MAC:self.bleDevice.macAddr, CMBD_NTF_PG_DICT_KEY_PROD_ID:self.bleDevice.productId}];
}

@end
