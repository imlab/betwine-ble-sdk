//
//  CMBDBleDevice.h
//  CleverBadge
//
//  Created by imlab_DEV on 14-6-30.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CMBDFrameworkDefines.h"
#import "CMBDPeripheralConnector.h"
#import "CMBDPeripheralInterface.h"

@interface CMBDBleDevice : NSObject

@property (nonatomic,strong) CBPeripheral *peripheral;
@property (nonatomic,strong) NSString *productId; // from advertisement manufacture data
@property (nonatomic,strong) NSString *macAddr; // from advertisement manufacture data
@property (nonatomic,strong) NSDictionary *broadcastData;

@property (nonatomic) BOOL isConnected;
@property (nonatomic) BOOL isPCReady;
@property (nonatomic) BOOL keepConnection; // whether to reconnect while disconnected



/* wrapper for communication with the peripheral */
// don't call them until "isPCReady" is true(or received bleDeviceReady delegate method)
@property (nonatomic,strong) CMBDPeripheralConnector *connector;
@property (nonatomic,strong) CMBDPeripheralInterface *interface;


-(void)initWithPeripheral:(CBPeripheral*)peripheral withBroadcastData:(NSDictionary*)dict; // dict is nullable

/* for device manager to send connection signal to this object */
-(void)onConnected; // setting up communication with device
-(void)onDisconnected; // releasing communication with device

-(CMBDPeripheralConnectorType)deviceType; // check which device it is
-(NSString*)deviceTypeName;
-(NSString*)deviceTypeShortName;
-(NSString*)uuidString;

@end



