//
//  CMBDPeripheralInterface.m
//  CleverBadge
//
//  Created by imlab_DEV on 14-6-30.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#import "CMBDPeripheralInterface.h"
#import "BTBetwineAppInterface.h"

@interface CMBDPeripheralInterface ()
@end

@implementation CMBDPeripheralInterface

-(void)activateWithConnector:(CMBDPeripheralConnector *)connector
{
    self.connector = connector;
    self.connector.delegate = self;

}

-(void)onPCReady:(CMBDPeripheralConnectorFeature)feature
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"[CMBDPeripheralInterface] please define onPCReady() method for %@", self]
                                 userInfo:nil];
}

+(CMBDPeripheralInterface*)interfaceWithType:(CMBDPeripheralConnectorType)deviceType
{
    switch (deviceType) {
        case CMBDConnectorType_Unknown:
        case CMBDConnectorType_BetwineApp:
        {
            return [[BTBetwineAppInterface alloc] init];
        }
            break;
        default:
            break;
    }
    return nil;
}

@end
