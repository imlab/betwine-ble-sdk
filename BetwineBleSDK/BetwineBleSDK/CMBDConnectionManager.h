//
//  CMBDBadgeConnectionManager.h
//  BetwineBTFlowPrototype
//
//  Created by imlab_DEV on 13-11-26.
//  Copyright (c) 2013年 cc.imlab.prototype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BeTwineCM.h"
#import "BeTwineAppPC.h"
#import "CMBDBadgeManager.h"
#import "CMBDOADManager.h"



///* This delegate protocol is use for UI interaction, it is designed only for the view that prompt user the device lists. If other views need te device state change, you should listen to the event notifications. */
//@protocol  CMBDBadgeConnectionManagerDelegate <NSObject>
//
//-(void)deviceListDidRefresh:(NSArray*)deviceList; // use it when displaying device list to user
//
//-(void)didConnectedPeripheral:(CBPeripheral*)peripheral;
//
//@end


/* The main class here */
@interface CMBDBadgeConnectionManager : NSObject <BetwineCMDelegate, CMBDPeripheralServiceStatusDelegate, UIActionSheetDelegate>

@property (nonatomic) CMBD_CONNECTION_STATUS connectionStatus; // check device's scanning/connected/disconnected status
@property (nonatomic) CMBDDeviceMode connectionMode;

+(CMBDBadgeConnectionManager*)defaultManager;

-(void)initConnectionManager; // this method should run after successful login/register

-(BOOL)isCentralManagerAvailable;

/* separate the scanning process and the saved device process */
// this is for scanning purpose when user have no bound devices
-(void)discoverDevices;
-(void)discoverAppDevices;

// for bound badge device, use this method to connect
-(void)connectBoundDevice:(NSString*)deviceUUID;

-(void)disconnectActivePeripheral;


-(BOOL)hasActivePeripheral;
-(BOOL)isActivePeripheralCapableWith:(CMBD_CAP_TYPE)type;

@end
