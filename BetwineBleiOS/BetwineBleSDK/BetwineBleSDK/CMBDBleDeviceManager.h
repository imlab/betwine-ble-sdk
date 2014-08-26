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
