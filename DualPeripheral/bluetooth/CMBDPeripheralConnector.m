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

#import "CMBDPeripheralConnector.h"
#import "BTBetwineAppPC.h"
#import "BTPowerGripAppPC.h"

@interface CMBDPeripheralConnector ()
@end


@implementation CMBDPeripheralConnector

-(void)initWithPeripheral:(CBPeripheral *)p
{
    self.activePeripheral = p;
    self.activePeripheral.delegate = self;
    [self.activePeripheral discoverServices:nil];
    
    self.isPCReady = NO;

}

-(void)deactivatePeripheral
{
    self.isPCReady = NO;
    self.activePeripheral = nil;
}

+ (NSString*)getBroadcastServiceUUID
{
    // need to be overrided
    NSLog(@"[CMBDPeripheralConnector] please define getBroadcastServiceUUID() class method");
    return @"undefined";
}

+(CMBDPeripheralConnector*)connectorWithType:(CMBDPeripheralConnectorType)deviceType
{
    switch (deviceType) {
        case CMBDConnectorType_Unknown:
            NSLog(@"[CMBD] warning: getting a CMBDPeripheralConnector with Unknown device");
        case CMBDConnectorType_BetwineApp:
        {
            return [[BTBetwineAppPC alloc] init];
        }
            break;
        case CMBDConnectorType_PowerGrip:
        {
            return [[BTPowerGripAppPC alloc] init];
        }
//        case OtherType:
//        {
//            // if you want to proceed type of other devices, write it here
//        }
//            break;
        default:
            break;
    }
    return nil;
}

@end
