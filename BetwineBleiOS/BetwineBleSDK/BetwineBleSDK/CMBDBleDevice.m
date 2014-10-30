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

@implementation CMBDBleDevice

-(void)initWithPeripheral:(CBPeripheral *)peripheral withBroadcastData:(NSDictionary *)dict
{
    self.peripheral = peripheral;
    self.isPCReady = NO;
    self.isConnected = NO;
    self.broadcastData = dict;
    
    CMBDPeripheralConnectorType type = [self deviceType];
    self.connector = [CMBDPeripheralConnector connectorWithType:type];
    self.interface = [CMBDPeripheralInterface interfaceWithType:type];
    self.keepConnection = [self keepConnectionForType:type];
    
    if (dict) {
        NSLog(@"[CMBDBleDevice] init with peripheral and broadcast data: %@\n%@", peripheral, dict);
        
        [self proceedBroadcastData:dict withDeviceType:type];
    }
    else {
        NSLog(@"[CMBDBleDevice] init with peripheral: %@", peripheral);
    }
}

-(void)onConnected
{
    self.isConnected = YES;
    
    [self.connector initWithPeripheral:self.peripheral];
    [self.interface activateWithConnector:self.connector];
    self.interface.bleDevice = self;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_CONNECTED object:self];
}

-(void)onDisconnected
{
    self.isConnected = NO;
    [self.connector deactivatePeripheral];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_DISCONNECTED object:self];
}

-(NSString*)getBroadcastUUIDString
{
    NSArray *broadcastUUIDs = [self.broadcastData objectForKey:CBAdvertisementDataServiceUUIDsKey];
    
    if (broadcastUUIDs.count == 0) {
        return nil;
    }
    
    CBUUID *uuid = [broadcastUUIDs objectAtIndex:0];
    
//    IF_BELOW_IOS7({
        return [uuid representativeString];
//    }, {
//        
//        return [uuid UUIDString];
//    })
}

-(CMBDPeripheralConnectorType)deviceType
{
    NSString *deviceName = [self.peripheral.name lowercaseString];
//    NSString *broadcastUUID = [self getBroadcastUUIDString];
    
    if ([deviceName rangeOfString:@"betwine"].location != NSNotFound) {
        return CMBDConnectorType_BetwineApp;
    }
//    if (true) {
//        // if you have other type of devices that want to proceed, write it here
//    }
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
//        case OtherType:
//        {
//            // if you have other type of devices that want to proceed, write it here
//        }
//            break;

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
//        case OtherType:
//        {
//            // if you have other type of devices that want to proceed, write it here
//        }
//            break;
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
//        case OtherType:
//        {
//            // if you have other type of devices that want to proceed, write it here
//        }
//            break;
        default:
            return NO;
            break;
    }
}

-(void)proceedBroadcastData:(NSDictionary*)dict withDeviceType:(CMBDPeripheralConnectorType)deviceType
{
    switch ([self deviceType]) {
        case CMBDConnectorType_BetwineApp:
        {
            NSData *data = [dict objectForKey:CBAdvertisementDataManufacturerDataKey];
            if (data && data.length == 8) {
                Byte *bytes = (Byte*)[data bytes];
                
                self.productId = [NSString stringWithFormat:@"%02x%02x", bytes[0], bytes[1]];
                self.macAddr = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7]];
            }
        }
            break;
//        case OtherType:
//        {
//            // if you have other devices that want to proceed, write it here
//        }
//            break;
        default:
            break;
    }

}

@end
