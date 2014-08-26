 //
//  BeTwineAppPC.h
//  BetwineBTFlowPrototype
//
//  Created by imlab_DEV on 13-11-26.
//  Copyright (c) 2013年 cc.imlab.prototype. All rights reserved.
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
