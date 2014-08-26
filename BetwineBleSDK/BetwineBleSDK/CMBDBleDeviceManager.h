//
//  CMBDBleDeviceManager.h
//  CleverBadge
//
//  Created by imlab_DEV on 14-6-30.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeTwineCM.h"
#import "CMBDBleDevice.h"

@interface CMBDBleDeviceManager : NSObject <BetwineCMDelegate, UIActionSheetDelegate>

@property (nonatomic,strong) NSMutableArray *connectedDevices;

/* init methods*/
+(CMBDBleDeviceManager*)defaultManager;
-(void)initBleDeviceManager;

/* check methods */
-(BOOL)isBluetoothAvailable;
-(BOOL)isInScanning;
-(BOOL)isDeviceReady:(CMBDBleDevice*)device;
-(BOOL)isDeviceTypeConnected:(CMBDPeripheralConnectorType)deviceType;

/* discover methods */
-(BOOL)scanBLEDeviceWithType:(CMBDPeripheralConnectorType)deviceType;

/* query methods */
-(CMBDBleDevice*)getConnectedDeviceByType:(CMBDPeripheralConnectorType)deviceType;
-(CMBDPeripheralInterface*)getDeviceInterfaceByType:(CMBDPeripheralConnectorType)deviceType;

/* connection methods */
-(void)connectDeviceWithUUIDStr:(NSString*)uuid;
-(void)connectDevice:(CMBDBleDevice*)device;
-(void)disconnectDevice:(CMBDBleDevice*)device;
-(void)disconnectAllDevices;

@end
