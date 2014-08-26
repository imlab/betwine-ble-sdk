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

#import "BTBetwineAppPC.h"

@implementation BTBetwineAppPC
@synthesize activePeripheral;
@synthesize hpChar;
@synthesize stateChar;
@synthesize stepChar;
@synthesize motorChar;
@synthesize timeChar;
@synthesize battChar;
@synthesize oldstepsChar;
@synthesize deviceInfoChar;
@synthesize vibTestChar;

+(NSString*)getBroadcastServiceUUID
{
    return CB_BROADCAST_SVC_UUID_APP;
}

-(id<BTBeTwineAppPCDelegate>)myDelegate
{
    return (id<BTBeTwineAppPCDelegate>)self.delegate;
}

- (void)enableHp {
    if (self.activePeripheral && self.hpChar) {
        [self.activePeripheral setNotifyValue:YES forCharacteristic:hpChar];
    }
}

- (void)disableHp {
    if (self.activePeripheral && hpChar) {
        [self.activePeripheral setNotifyValue:NO forCharacteristic:hpChar];
    }
}

- (void)readHp {
    if (self.activePeripheral && hpChar) {
        [self.activePeripheral readValueForCharacteristic:hpChar];
    }
}

- (void)enablePedometer {
    if (self.activePeripheral && stateChar && stepChar) {
        [self.activePeripheral setNotifyValue:YES forCharacteristic:stateChar];
        [self.activePeripheral setNotifyValue:YES forCharacteristic:stepChar];
    }
}

- (void)disablePedometer {
    if (self.activePeripheral && stateChar && stepChar) {
        [self.activePeripheral setNotifyValue:NO forCharacteristic:stateChar];
        [self.activePeripheral setNotifyValue:NO forCharacteristic:stepChar];
    }
}

- (void)enableTime {
    if (self.activePeripheral && timeChar) {
        [self.activePeripheral setNotifyValue:YES forCharacteristic:timeChar];
    }
}

- (void)disableTime {
    if (self.activePeripheral && timeChar) {
        [self.activePeripheral setNotifyValue:NO forCharacteristic:timeChar];
    }
}

- (void)readPedometer {
    if (self.activePeripheral && stateChar && stepChar) {
        [self.activePeripheral readValueForCharacteristic:stateChar];
        [self.activePeripheral readValueForCharacteristic:stepChar];
    }
}

- (void)setMotor:(Byte)motorValue {
    NSData *d = [[NSData alloc] initWithBytes:&motorValue length:CB_MR_VALUE_LEN];
    
    if (self.activePeripheral && motorChar) {
        [self.activePeripheral writeValue:d forCharacteristic:motorChar type:CBCharacteristicWriteWithResponse];
    }
}

- (void)setTime:(Byte *)time {
    Byte test[CB_TS_VALUE_LEN];
    for (int i = 0; i < CB_TS_VALUE_LEN; i++) {
        test[i] = time[i];
    }
    NSData *d = [[NSData alloc] initWithBytes:&test length:CB_TS_VALUE_LEN];
    
    if (self.activePeripheral && timeChar) {
        [self.activePeripheral writeValue:d forCharacteristic:timeChar type:CBCharacteristicWriteWithResponse];
    }
}

- (void)readTime {
    if (self.activePeripheral && timeChar) {
        [self.activePeripheral readValueForCharacteristic:timeChar];
    }
}

- (void)readBatt {
    if (self.activePeripheral && battChar) {
        [self.activePeripheral readValueForCharacteristic:battChar];
    }
}

- (void)readOldsteps {
    if (self.activePeripheral && oldstepsChar) {
        [self.activePeripheral readValueForCharacteristic:oldstepsChar];
    }
}

-(void)enableDeviceInfo
{
    if (self.activePeripheral && deviceInfoChar) {
        [self.activePeripheral setNotifyValue:YES forCharacteristic:deviceInfoChar];
    }
}

-(void)disableDeviceInfo
{
    
    if (self.activePeripheral && deviceInfoChar) {
        [self.activePeripheral setNotifyValue:NO forCharacteristic:deviceInfoChar];
    }
}

-(void)readDeviceInfo
{
    if (self.activePeripheral && deviceInfoChar) {
        [self.activePeripheral readValueForCharacteristic:deviceInfoChar];
    }
}

-(void)enableVibrateTest
{
    if (self.activePeripheral && vibTestChar) {
        [self.activePeripheral setNotifyValue:YES forCharacteristic:vibTestChar];
    }
}

-(void)disableVibrateTest
{
    
    if (self.activePeripheral && vibTestChar) {
        [self.activePeripheral setNotifyValue:NO forCharacteristic:vibTestChar];
    }
}

-(void)readVibrateTest
{
    if (self.activePeripheral && vibTestChar) {
        [self.activePeripheral readValueForCharacteristic:vibTestChar];
    }
}

#pragma mark -- device related
- (void)initWithPeripheral:(CBPeripheral *)p {
    hpChar = nil;
    stepChar = nil;
    stateChar = nil;
    motorChar = nil;
    timeChar = nil;
    battChar = nil;
    oldstepsChar = nil;
    deviceInfoChar = nil;
    vibTestChar = nil;
    
    self.pcMode = CMBDConnectorType_BetwineApp;
    
    [super initWithPeripheral:p];
}

-(void)deactivatePeripheral
{
    // release the characteristics
    hpChar = nil;
    stepChar = nil;
    stateChar = nil;
    motorChar = nil;
    timeChar = nil;
    battChar = nil;
    oldstepsChar = nil;
    deviceInfoChar = nil;
    vibTestChar = nil;
    
    [super deactivatePeripheral];
}

- (UInt16)CBUUIDToInt:(CBUUID *)UUID {
    char iu[16];
    [UUID.data getBytes:iu];
    return ((iu[0] << 8) | iu[1]);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"[BTBetwineAppPC] didDiscoverCharacteristicsForService: service(%@)\n", service.UUID);
    
    UInt16 serviceUUID = [self CBUUIDToInt:service.UUID];
    
    BOOL chFound = NO; // this flag limits the service check and delegate method to AppPC related services
    BOOL chFound_1_1 = NO; // for version 1.1 check
    
    if (!error) {
        switch (serviceUUID) {
            case CB_HP_SERVICE_UUID:
            {
                CBCharacteristic *c;
                for (c in service.characteristics) {
                    if ([self CBUUIDToInt:c.UUID] == CB_HP_VALUE_UUID) {
                        hpChar = c;
                        chFound = YES;
                    }
                }
                break;
            }
                
            case CB_PM_SERVICE_UUID:
            {
                CBCharacteristic *c;
                for (c in service.characteristics) {
                    if ([self CBUUIDToInt:c.UUID] == CB_PM_STATE_UUID) {
                        stateChar = c;
                        chFound = YES;
                    }
                    
                    if ([self CBUUIDToInt:c.UUID] == CB_PM_VALUE_UUID) {
                        stepChar = c;
                        chFound = YES;
                    }
                }
                break;
            }
                
            case CB_MR_SERVICE_UUID:
            {
                CBCharacteristic *c;
                for (c in service.characteristics) {
                    if ([self CBUUIDToInt:c.UUID] == CB_MR_VALUE_UUID) {
                        motorChar = c;
                        chFound = YES;
                    }
                    
                    if ([self CBUUIDToInt:c.UUID] == CB_MR_TEST_VALUE_UUID) {
                        vibTestChar = c;
                        chFound_1_1 = YES;
                    }
                }
                break;
            }
                
            case CB_TS_SERVICE_UUID:
            {
                CBCharacteristic *c;
                for (c in service.characteristics) {
                    if ([self CBUUIDToInt:c.UUID] == CB_TS_VALUE_UUID) {
                        timeChar = c;
                        chFound = YES;
                    }
                }
                break;
            }
                
            case CB_BS_SERVICE_UUID:
            {
                CBCharacteristic *c;
                for (c in service.characteristics) {
                    if ([self CBUUIDToInt:c.UUID] == CB_BS_VALUE_UUID) {
                        battChar = c;
                        chFound = YES;
                    }
                }
                break;
            }
                
            case CB_HS_SERVICE_UUID:
            {
                CBCharacteristic *c;
                for (c in service.characteristics) {
                    if ([self CBUUIDToInt:c.UUID] == CB_HS_STEPS_UUID) {
                        oldstepsChar = c;
                        chFound = YES;
                    }
                }
                break;
            }
                
            case CB_MAC_SERVICE_UUID:
            {
                CBCharacteristic *c;
                for (c in service.characteristics) {
                    if ([self CBUUIDToInt:c.UUID] == CB_MAC_VALUE_UUID) {
                        deviceInfoChar = c;
                        chFound_1_1 = YES;
                    }
                }
                break;
            }
                
            default:
                break;
        }
        
        // -- cannot add new characterisitcs check here...
        if (hpChar && stepChar && stateChar && motorChar && timeChar && battChar && oldstepsChar && chFound) {            self.isPCReady = YES;
            [[self myDelegate] onPCReady:CMBDPeripheralConnectorFeature_BetwineApp_1_0];
        }
        if (deviceInfoChar && vibTestChar && chFound_1_1) {
            [[self myDelegate] onPCReady:CMBDPeripheralConnectorFeature_BetwinwApp_1_1];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    CBService *s;
    
    hpChar = nil;
    stepChar = nil;
    stateChar = nil;
    motorChar = nil;
    timeChar = nil;
    battChar = nil;
    oldstepsChar = nil;
    deviceInfoChar = nil;
    vibTestChar = nil;
    
    for (s in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:s];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    UInt16 characteristicUUID = [self CBUUIDToInt:characteristic.UUID];
    
    if (!error) {
        switch (characteristicUUID) {
            case CB_HP_VALUE_UUID:
            {
                Byte hpValue;
                [characteristic.value getBytes:&hpValue length:CB_HP_VALUE_LEN];
                if (peripheral == activePeripheral) {
                    [[self myDelegate] hpUpdate:hpValue];
                }
                break;
            }
                
            case CB_PM_STATE_UUID:
            {
                Byte pmState;
                [characteristic.value getBytes:&pmState length:CB_PM_STATE_LEN];
                if (peripheral == activePeripheral) {
                    [[self myDelegate] stateUpdate:pmState];
                }
                break;
            }
                
            case CB_PM_VALUE_UUID:
            {
                Byte pmValue[CB_PM_VALUE_LEN];
                [characteristic.value getBytes:&pmValue length:CB_PM_VALUE_LEN];
                if (peripheral == activePeripheral) {
                    [[self myDelegate] stepUpdate:pmValue];
                }
                break;
            }
                
            case CB_TS_VALUE_UUID:
            {
                Byte tsValue[CB_TS_VALUE_LEN];
                [characteristic.value getBytes:&tsValue length:CB_TS_VALUE_LEN];
                if (peripheral == activePeripheral) {
                    [[self myDelegate] timeUpdate:tsValue];
                }
                break;
            }
                
            case CB_BS_VALUE_UUID:
            {
                Byte btValue;
                [characteristic.value getBytes:&btValue length:CB_BS_VALUE_LEN];
                if (peripheral == activePeripheral) {
                    [[self myDelegate] battUpdate:btValue];
                }
                break;
            }
                
            case CB_HS_STEPS_UUID:
            {
                Byte oldsteps[CB_HS_VALUE_LEN];
                [characteristic.value getBytes:&oldsteps length:CB_HS_VALUE_LEN];
                if (peripheral == activePeripheral) {
                    [[self myDelegate] oldstepsUpdate:oldsteps];
                }
                break;
            }
                
            case CB_MAC_VALUE_UUID:
            {
                Byte devInfo[CB_MAC_VALUE_LEN];
                [characteristic.value getBytes:&devInfo length:CB_MAC_VALUE_LEN];
                if (peripheral == activePeripheral) {
                    [[self myDelegate] deviceInfoUpdate:devInfo];
                }
                break;
            }
                
            case CB_MR_TEST_VALUE_UUID:
            {
                Byte vibTestValue[CB_MR_TEST_VALUE_LEN];
                [characteristic.value getBytes:&vibTestValue length:CB_MR_TEST_VALUE_LEN];
                
                if (peripheral == activePeripheral) {
                    [[self myDelegate] vibrateTestUpdate:vibTestValue];
                }
                break;
            }
                
            default:
                break;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral {
    
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    
}



@end
