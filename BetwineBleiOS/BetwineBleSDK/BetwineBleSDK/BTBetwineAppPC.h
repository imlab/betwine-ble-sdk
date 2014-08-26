//
//  Created by imlab_DEV on 13-11-26.
//  Copyright (c) 2013 imlab.cc. All rights reserved.
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

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BTAppDefines.h"
#import "CMBDPeripheralConnector.h"

@protocol BTBeTwineAppPCDelegate <CMBDPeripheralConnectorDelegate>

- (void)hpUpdate:(Byte)hpValue;
- (void)stepUpdate:(Byte *)stepValue;
- (void)stateUpdate:(Byte)stepState;
- (void)timeUpdate:(Byte *)timeValue;
- (void)battUpdate:(Byte)battValue;
- (void)oldstepsUpdate:(Byte *)oldstepValues;
- (void)deviceInfoUpdate:(Byte*)deviceValues;
- (void)vibrateTestUpdate:(Byte*)testValues;

@end



@interface BTBetwineAppPC : CMBDPeripheralConnector {
    
}

//@property (nonatomic, assign) id <BTBeTwineAppPCDelegate> delegate; // defined in CMBDPeriphral connector class

@property (nonatomic, strong) CBCharacteristic *hpChar;
@property (nonatomic, strong) CBCharacteristic *stepChar;
@property (nonatomic, strong) CBCharacteristic *stateChar;
@property (nonatomic, strong) CBCharacteristic *motorChar;
@property (nonatomic, strong) CBCharacteristic *timeChar;
@property (nonatomic, strong) CBCharacteristic *battChar;
@property (nonatomic, strong) CBCharacteristic *oldstepsChar;
@property (nonatomic, strong) CBCharacteristic *deviceInfoChar;
@property (nonatomic, strong) CBCharacteristic *vibTestChar;

- (UInt16)CBUUIDToInt:(CBUUID *)UUID;

- (void)enableHp;
- (void)disableHp;
- (void)readHp;
- (void)enablePedometer;
- (void)disablePedometer;
- (void)enableTime;
- (void)disableTime;

- (void)readPedometer;
- (void)setMotor:(Byte)motorValue;
- (void)setTime:(Byte *)time;
- (void)readTime;
- (void)readBatt;
- (void)readOldsteps;

// protocol 1.2 methods
- (void)enableDeviceInfo; // product id, mac address
- (void)disableDeviceInfo;
- (void)readDeviceInfo;
- (void)enableVibrateTest;
- (void)disableVibrateTest;
- (void)readVibrateTest;

@end
