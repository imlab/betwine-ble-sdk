//
//  CMBDPeripheralConnector.m
//  CleverBadge
//
//  Created by imlab_DEV on 14-6-30.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#import "CMBDPeripheralConnector.h"
#import "BTBetwineAppPC.h"

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
        case CMBDConnectorType_BetwineApp:
        {
            return [[BTBetwineAppPC alloc] init];
        }
            break;
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
