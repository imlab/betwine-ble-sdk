//
//  CMBDPeripheralInterface.h
//  CleverBadge
//
//  Created by imlab_DEV on 14-6-30.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMBDPeripheralConnector.h"

@class CMBDBleDevice;

@interface CMBDPeripheralInterface : NSObject <CMBDPeripheralConnectorDelegate>

@property (nonatomic,assign) CMBDPeripheralConnector *connector;
@property (nonatomic,assign) CMBDBleDevice *bleDevice;

+(CMBDPeripheralInterface*)interfaceWithType:(CMBDPeripheralConnectorType)deviceType;

-(void)activateWithConnector:(CMBDPeripheralConnector*)connector;

@end
