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

#import "CMBDBleDevice.h"
#import "CBUUID+String.h"
#import "CBPeripheral+Compatible.h"
#import "BTAppDefines.h"
#import "BTPowerGripAppDefines.h"

@implementation CMBDBleDevice

-(void)initWithPeripheral:(CBPeripheral *)peripheral withManufacturerData:(NSData*)data
{
    self.peripheral = peripheral;
    self.isPCReady = NO;
    self.isConnected = NO;
    self.manufacturerData = data;
    
    if (data) {
        NSLog(@"[CMBDBleDevice] init with peripheral and broadcast data: %@\n%@", peripheral, data);
        
        [self proceedManufacturerData:data];
    }
    else {
        self.deviceId = [peripheral deviceUUIDString]; // set to UUID when no mac Addr presented
        NSLog(@"[CMBDBleDevice] init with peripheral: %@", peripheral);
    }
    
    // after manufacurer data is parse, then determine deviceType
    CMBDPeripheralConnectorType type = [self deviceType];
    self.connector = [CMBDPeripheralConnector connectorWithType:type];
    self.interface = [CMBDPeripheralInterface interfaceWithType:type];
    self.keepConnection = [self keepConnectionForType:type];
}

-(void)onConnected
{
    self.isConnected = YES;
    
    [self.connector initWithPeripheral:self.peripheral];
    [self.interface activateWithConnector:self.connector];
    self.interface.bleDevice = self;
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_CONNECTED object:self userInfo:@{@"device":self}];
}

-(void)onDisconnected
{
    self.isConnected = NO;
    [self.connector deactivatePeripheral];
}

-(BOOL)isSelfInProductIdList:(NSArray*)productIdList {
    for (NSString *prodId in productIdList) {
        if (self.productId && [prodId isEqualToString:self.productId]) {
            return YES;
        }
    }
    
    return NO;
}

-(CMBDPeripheralConnectorType)deviceType
{
    NSLog(@"ProdId: %@ Name: %@", self.productId, self.peripheral.name);
    
    NSString *deviceName = [self.peripheral.name lowercaseString];
    
    if ([deviceName rangeOfString:@"betwine"].location != NSNotFound || [self isSelfInProductIdList:CB_BWAPP_PRODUCT_ID_LIST]) {
        return CMBDConnectorType_BetwineApp;
    }
    
    if ([self isSelfInProductIdList:CB_PG_PRODUCT_ID_LIST]) {
        return CMBDConnectorType_PowerGrip;
    }
    else {
        return CMBDConnectorType_Unknown;
    }
    
}

-(NSString*)deviceTypeName
{
    switch ([self deviceType]) {
        case CMBDConnectorType_BetwineApp:
            return @"BetwineApp";
            break;
        case CMBDConnectorType_PowerGrip:
        {
            return @"PowerGrip";
        }
            break;

        default:
            return @"Unknown";
            break;
    }
}

-(NSString*)deviceTypeShortName
{
    switch ([self deviceType]) {
        case CMBDConnectorType_BetwineApp:
            return @"App";
            break;
        case CMBDConnectorType_PowerGrip:
        {
            return @"Grip";
            // if you have other type of devices that want to proceed, write it here
        }
            break;
        default:
            return @"NA";
            break;
    }
}

-(NSString*)uuidString
{
    return [self.peripheral deviceUUIDString];
}

-(BOOL)keepConnectionForType:(CMBDPeripheralConnectorType)type
{
    
    switch ([self deviceType]) {
        case CMBDConnectorType_BetwineApp:
            return YES;
            break;
        case CMBDConnectorType_PowerGrip:
        {
            return NO;
            break;
        }
        default:
            return NO;
            break;
    }
}

-(void)proceedManufacturerData:(NSData*)data
{
    // by default we consider product info data is presented
    if (data && data.length == 8) {
        Byte *bytes = (Byte*)[data bytes];
        
        self.productId = [NSString stringWithFormat:@"%02x%02x", bytes[0], bytes[1]];
        self.macAddr = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7]];
        self.deviceId = self.macAddr;
    }
}

@end
