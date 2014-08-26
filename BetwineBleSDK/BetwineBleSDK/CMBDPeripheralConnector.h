//
//  CMBDPeripheralConnector.h
//  CleverBadge
//
//  Created by imlab_DEV on 14-6-30.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CMBDFrameworkDefines.h"


@protocol CMBDPeripheralConnectorDelegate <NSObject>

-(void)onPCReady:(CMBDPeripheralConnectorFeature)feature;

@end

@interface CMBDPeripheralConnector : NSObject <CBPeripheralDelegate>

@property (nonatomic,assign) CBPeripheral *activePeripheral;
@property (nonatomic,assign) id<CMBDPeripheralConnectorDelegate> delegate;

@property (nonatomic) CMBDPeripheralConnectorType pcMode;
@property (nonatomic) BOOL isPCReady;


+(CMBDPeripheralConnector*)connectorWithType:(CMBDPeripheralConnectorType)deviceType;

- (void)initWithPeripheral:(CBPeripheral *)p; // activate peripheral, discover services and characteristics
- (void)deactivatePeripheral; // remove activate peripheral and characteristics

+ (NSString*)getBroadcastServiceUUID;

@end

