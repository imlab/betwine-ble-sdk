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


/* init methods*/
+(CMBDBleDeviceManager*)defaultManager;
-(void)initBleDeviceManager;

/* check methods */
-(BOOL)isBluetoothAvailable;
-(BOOL)isInScanning;

/* discover methods */
-(BOOL)scanBLEDeviceWithType:(CMBDPeripheralConnectorType)deviceType;
-(BOOL)stopScanningForPeripheral;

/* query methods */
-(NSArray*)getConnectedDevicesByType:(CMBDPeripheralConnectorType)deviceType; // array of device IDs
-(CMBDPeripheralInterface*)getConnectedInterfaceByDeviceId:(NSString*)deviceId;

/* connection methods */
-(void)connectDeviceWithDeviceId:(NSString*)deviceId;
-(void)disconnectDeviceWithDeviceId:(NSString*)deviceId;

/* deprecated */
-(void)disconnectAllDevices;

@end
