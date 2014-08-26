//
//  CMBDConnectionManager.m
//  BetwineBTFlowPrototype
//
//  Created by imlab_DEV on 13-11-26.
//  Copyright (c) 2013年 cc.imlab.prototype. All rights reserved.
//

#import "CMBDConnectionManager.h"
#import "CBUUID+String.h"
#import "CBPeripheral+Compatible.h"
#import "AppDelegate.h"
#import "CMUTOSUtil.h"
#import "DMDevice.h"
#import "IFApplication.h"

@interface CMBDBadgeConnectionManager ()

@property (nonatomic,retain) BeTwineCM *cm;

@property (nonatomic,retain) CBPeripheral *activePeripheral;
@property (nonatomic) CMBD_CAP_TYPE activeCapability;

@end

CMBDBadgeConnectionManager *_connectionMgr = nil;

@implementation CMBDBadgeConnectionManager

+(CMBDBadgeConnectionManager*)defaultManager
{
    if(!_connectionMgr) {
        _connectionMgr = [[CMBDBadgeConnectionManager alloc] init];
    }
    return _connectionMgr;
}

-(void)initConnectionManager
{
    if(!self.cm) {
        NSLog(@"[CMBDBadgeConnectionManager] initialize central manager...");
        self.cm = [[BeTwineCM alloc] init];
        self.cm.delegate = self;
        [self.cm initCentralManager]; // initialize central manager
        
        self.connectionStatus = CMBD_CONN_STATUS_NO_CONNECTION;
    }
    else {
        NSLog(@"[CMBDBadgeConnectionManager] initialize central manager (already done before)");
    }
}

-(BOOL)isCentralManagerAvailable
{
    return (self.cm.CM.state == CBCentralManagerStatePoweredOn);
}


-(void)discoverDevices
{
    if (self.activePeripheral || self.connectionStatus == CMBD_CONN_STATUS_READY) { // active peripheral check
//        [self disconnectActivePeripheral];
        NSLog(@"[CMBDBadgeConnectionManager] error: active peripheral exists, disconnect it first!");
        return;
    }
    self.connectionMode = CMBD_DEVICE_MODE_ALL;
    self.connectionStatus = CMBD_CONN_STATUS_SCANNING;
    
    // post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_START_SCAN object:nil];
    NSLog(@"[CMBDBadgeConnectionManager] start scanning (all mode)...");
    
    // scan with ALL mode
    NSInteger returnVal = [self.cm scanPeripherals:5 withServices:nil withName:@"betwine"];
    if(returnVal == -1) {
        // start scan failed
        self.connectionStatus = CMBD_CONN_STATUS_NO_CONNECTION;
        
         [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_NO_CONNECTION object:nil];
        
    }
}

-(void)discoverAppDevices
{
    
    if (self.activePeripheral || self.connectionStatus == CMBD_CONN_STATUS_READY) { // active peripheral check
//        [self disconnectActivePeripheral];
        NSLog(@"[CMBDBadgeConnectionManager] error: active peripheral exists, disconnect it first!");
    }
    self.connectionMode = CMBD_DEVICE_MODE_APP;
    self.connectionStatus = CMBD_CONN_STATUS_SCANNING;
    
    // post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_START_SCAN object:nil];
    NSLog(@"[CMBDBadgeConnectionManager] start scanning (app mode)...");
    
     // scan with APP mode
    NSInteger returnVal = [self.cm scanPeripherals:5 withServices:@[[CBUUID UUIDWithString:CB_BROADCAST_SVC_UUID_APP]] withName:@"betwine"];
    
    if(returnVal == -1) {
        // start scan failed
        self.connectionStatus = CMBD_CONN_STATUS_NO_CONNECTION;
        [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_NO_CONNECTION object:self];
        
    }
}

-(void)discoverOADDevices
{
    if (self.activePeripheral || self.connectionStatus == CMBD_CONN_STATUS_READY) { // active peripheral check
//        [self disconnectActivePeripheral];
        NSLog(@"[CMBDBadgeConnectionManager] error: active peripheral exists, disconnect it first! (%@)", self.activePeripheral);
        
        return;
    }
    self.connectionMode = CMBD_DEVICE_MODE_OAD;
    self.connectionStatus = CMBD_CONN_STATUS_SCANNING;
    
    // post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_START_SCAN_OAD object:nil];
    NSLog(@"[CMBDBadgeConnectionManager] start scanning (oad mode)...");

    // scan for 5 seconds
    NSInteger returnVal = [self.cm scanPeripherals:5 withServices:@[[CBUUID UUIDWithString:CB_BROADCAST_SVC_UUID_OAD]] withName:@"betwine"];
    if(returnVal == -1) {
        // start scan failed
        self.connectionStatus = CMBD_CONN_STATUS_NO_CONNECTION;
        [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_NO_CONNECTION object:nil];
        
    }
    
}

-(void)connectBoundDevice:(NSString *)deviceUUID
{
//    self.connectionMode = CMBD_DEVICE_MODE_APP;
    self.connectionStatus = CMBD_CONN_STATUS_CONNECTING;
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:deviceUUID];
    [self.cm retrievePeripheralsWithUUIDs:@[uuid]];
}


-(void)disconnectActivePeripheral
{
    // check if it's connecting/ready
    if(self.activePeripheral &&
       (self.connectionStatus == CMBD_CONN_STATUS_READY || self.connectionStatus == CMBD_CONN_STATUS_CONNECTING)) {
        
        NSLog(@"[CMBDBadgeConnectionManager] disconnecting: %@", self.activePeripheral);

        CBPeripheral *p = self.activePeripheral;
        
        self.activePeripheral = nil;
        self.activeCapability = 0; // reset capabilities
        
        [self.cm disconnectPeripheral:p];
        
    }
    else {
        NSLog(@"[CMBDBadgeConnectionManager] warning: no active peripheral to be disconnected");
    }
}

-(BOOL)hasActivePeripheral
{
    return self.activePeripheral != nil;
}

-(BOOL)isActivePeripheralCapableWith:(CMBD_CAP_TYPE)type
{
    if (self.activePeripheral == nil) {
        return NO;
    }
    
    NSLog(@"[CMBDBadgeConnectionManager] debug: %d, %d, %d", type, self.activeCapability, type & self.activeCapability);
    
    return type & self.activeCapability;
}


// method used by timer
-(void)tryReconnectPeripheral
{
    // only when activePeripheral exists that have reconnect function
    if (self.activePeripheral) {
        NSLog(@"[CMBDBadgeConnetionManager] reconnecting to peripheral: %@", self.activePeripheral);
    
        self.connectionStatus = CMBD_CONN_STATUS_CONNECTING;
        [self.cm connectPeripheral:self.activePeripheral];
    }
    else {
        NSLog(@"[CMBDBadgeConnectionManager] self.activePeripheral is nil, no reconnect available");
    }
}

#pragma mark -- BetwineCMDelegate methods
-(void)didConnectPeripheral:(CBPeripheral *)p
{
    NSLog(@"[CMBDBadgeConnectionManager] connected: %@ current active: %@", p, self.activePeripheral);
    
    if (self.activePeripheral == p) { // no active peripheral before
        
        [self activatePeripheral:p];
    }
    else { // has active peripheral but not the same or nil
        NSLog(@"[CMBDBadgeConnectionManager] replace previous: %@ with new: %@", self.activePeripheral, p);
        
        self.activePeripheral = p;
        [self activatePeripheral:p];
    }
    
}

-(void)didDisconnectPeripheral:(CBPeripheral *)p
{
    NSLog(@"[CMBDBadgeConnectionManager] disconnected: %@, activePeripheral: %@ isEqual:%@", p, self.activePeripheral, [p isEqual:self.activePeripheral] ? @"Yes" : @"No");
    
    if ([p isEqual:self.activePeripheral]) { // self.activePeripheral is not released, handle the correct scenario here

        // cannot release it if you want to reconnect it
        
        // reconnect peripheral if it is in a login session
        if ([IFApplication isUserLoggedIn] && [DMDevice getDeviceByUser:[IFApplication getAuthUserId] deviceType:DMDevice_Type_Betwine]) {
            
            [[CMBDBadgeManager defaultManager] peripheralDisconnected:p];
            [[CMBDOADManager defaultManager] peripheralDisconnected:p];
            
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tryReconnectPeripheral) userInfo:nil repeats:NO];
        } else {
            // really deactivate this peripheral
            [[CMBDBadgeManager defaultManager] deactivatePeripheral:p];
            [[CMBDOADManager defaultManager] deactivatePeripheral:p];
            
            // set self activePeripheral to nil
            self.activePeripheral = nil;
            
            // notify all PC's that the device has been disconnected
            self.connectionStatus = CMBD_CONN_STATUS_NO_CONNECTION;
            [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_NO_CONNECTION object:self];
        }
        
    }
    else {
        
        // check if we need to deactivate peripheral in CMBDBadgeManager/CMBDOADManager
        if (self.activePeripheral == nil) {
        
            if ([CMBDBadgeManager defaultManager].appPC.activePeripheral == p) {
                [[CMBDBadgeManager defaultManager] deactivatePeripheral:p];
            }
            if ([CMBDOADManager defaultManager].oadPC.activePeripheral == p) {
                [[CMBDOADManager defaultManager] deactivatePeripheral:p];
            }
            
            // notify all PC's that the device has been disconnected
            self.connectionStatus = CMBD_CONN_STATUS_NO_CONNECTION;
            [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_NO_CONNECTION object:self];
        }
        else {
            NSLog(@"[CMBDBadgeConnectionManager] warning: unknown peripheral disconnected? (%@) current active: %@", p, self.activePeripheral);
        }
    }
}

-(void)didFailToConnectPeripheral:(CBPeripheral *)p
{
    NSLog(@"[CMBDBadgeConnectionManager] failed to connect peripheral: %@", p);
    
    self.connectionStatus = CMBD_CONN_STATUS_NO_CONNECTION;
}

-(void)didStopScanWithPeripherals:(NSArray *)peripheralList
{
    NSLog(@"List: %@", peripheralList);
    
    if (![IFApplication isUserLoggedIn]) {
        NSLog(@"[CMBDBadgeConnectionManager] user not logged in, ignore scan result.");
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_STOP_SCAN object:self];
    NSLog(@"[CMBDBadgeConnectionManager] stop scanning.");
    
    NSArray *foundPeripherals = self.cm.peripherals;
    // check found devices
    if (foundPeripherals.count == 0) {
        // no devices found, set NO CONNECTION ?
        self.connectionStatus = CMBD_CONN_STATUS_NO_CONNECTION;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_NO_CONNECTION object:nil];
    }
    else {
        // found more devices, need to prompt user with a list
        [self promptDeviceChooser];
        
    }
}

-(void)didRetrievedPeripherals:(NSArray *)peripheralList
{
    if (peripheralList.count > 0) { // found device
        
        if (peripheralList.count > 1) {
            NSLog(@"[CMBDBadgeConnectionManager] warning: more than one peripherals is retrieved: %@", peripheralList);
        }
        
        CBPeripheral *p = [peripheralList objectAtIndex:0];
        self.activePeripheral = p;
        NSLog(@"[CMBDBadgeConnectionManager] connecting to known peripheral: %@", p);
        [self.cm connectPeripheral:self.activePeripheral];
    }
    else { // device not found
        NSLog(@"[CMBDBadgeConnectionManager] cannot find the known peripheral(s)");
    }
}

-(void)didCentralStateChange:(CBCentralManagerState)state
{
    CMBDBadgeManager *badgeMgr = [CMBDBadgeManager defaultManager];
    CMBDOADManager *oadMgr = [CMBDOADManager defaultManager];
    
    
    NSLog(@"[CMBDBadgeConnectionManager] central manager state change: %d", state);
    
    // if CBCentralManager is BACK to PowerOn, we'll need to re-initialize the peripherals in PC
    
    NSLog(@"[CMBDBadgeConnectionManager] activePeripheral: %@ appPC.activePeripheral: %@ oadPC.activePeripheral: %@", self.activePeripheral, badgeMgr.appPC.activePeripheral, oadMgr.oadPC.activePeripheral);
    
    
     // need to handle peripheral disconnect/reconnect situation
    if (self.activePeripheral != nil) {
        
        if (state != CBCentralManagerStatePoweredOn) { // disconnect
            
            [badgeMgr peripheralDisconnected:self.activePeripheral];
            [oadMgr peripheralDisconnected:self.activePeripheral];
        }
        else { // reconnect
            
            [self tryReconnectPeripheral];
        }
    }
    
    
}


#pragma mark -- private methods to work with Peripheral Connectors(PCs)
-(void)activatePeripheral:(CBPeripheral*)p
{
    self.connectionStatus = CMBD_CONN_STATUS_CONNECTING;
    
    if([p.name rangeOfString:@"OAD"].location != NSNotFound) {
        // activate OAD mode
        self.activeCapability |= CMBD_CAP_TYPE_OAD;
        
        // let the CMBD Managers to deal the PCs
        [[CMBDOADManager defaultManager] setServiceStatusDelegate:self];
        [[CMBDOADManager defaultManager] initWithPeripheral:p];
    }
    else {
        // activate App mode
        self.activeCapability |= CMBD_CAP_TYPE_APP;
        self.activeCapability |= CMBD_CAP_TYPE_PUB;
        
        // let the CMBD Managers to deal with the PCs
        [[CMBDBadgeManager defaultManager] setServiceStatusDelegate:self];
        [[CMBDBadgeManager defaultManager] initWithPeripheral:p];
    }
    
}

-(void)badgePubReady
{
    NSLog(@"[CMBDBadgeConnectionManager] Betwine public service ready");
    
    self.connectionStatus = CMBD_CONN_STATUS_READY;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_PC_PUB_READY object:nil];
}

-(void)badgeAppReady
{
    NSLog(@"[CMBDBadgeConnectionManager] Betwine app service ready");
    
    self.connectionStatus = CMBD_CONN_STATUS_READY;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_PC_APP_READY object:nil];
}

-(void)badgeOADReady
{
    NSLog(@"[CMBDBadgeConnectionManager] Betwine oad service ready");
    
    self.connectionStatus = CMBD_CONN_STATUS_READY;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_PC_OAD_READY object:nil];
    
}

#pragma mark -- UI prompt
-(void)promptDeviceChooser
{
    NSInteger count = self.cm.peripherals.count;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Choose a device", @"Choose device list in CMBDBadgeConnectionManager")delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    
    for(int i = 0; i < count; i++) {
        CBPeripheral *p = [self.cm.peripherals objectAtIndex:i];
        
        NSString *deviceID = [p deviceUUIDString];
        if (deviceID == nil) {
            deviceID = @"NEW";
        }
        
        NSString *mode = ([p.name rangeOfString:@"OAD"].location != NSNotFound) ? @"OAD" : @"App";

        [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@ (%@/%@)", p.name, [deviceID substringFromIndex:deviceID.length > 4 ? deviceID.length - 4 : 0], mode]];
    }
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = count;
    
    [actionSheet showInView:[[[UIApplication sharedApplication] delegate] window]];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"[CMBDBadgeConnectionManager] choose device sheet dismiss with button %d", buttonIndex);
    
    NSInteger count = self.cm.peripherals.count;
    
    if (buttonIndex == count) {
        self.connectionStatus = CMBD_CONN_STATUS_NO_CONNECTION;
        [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_NO_CONNECTION object:nil];
    }
    else {
        self.activePeripheral = [self.cm.peripherals objectAtIndex:buttonIndex];
        
        if ([self.activePeripheral.name rangeOfString:@"OAD"].location != NSNotFound) {
            self.connectionMode = CMBD_DEVICE_MODE_OAD;
        }
        else {
            self.connectionMode = CMBD_DEVICE_MODE_APP;
            
            // save device for user
            [DMDevice setDeviceByUser:[IFApplication getAuthUserId] deviceType:DMDevice_Type_Betwine deviceId:[self.activePeripheral deviceUUIDString]];
            [[CMBDBadgeManager defaultManager] sendBindingVibrate]; // set a vibrate after it's connected
            
            NSLog(@"[CMBDBadgeConnectionManager] save device for user(%@): %@", [IFApplication getAuthUserId], [self.activePeripheral deviceUUIDString]);
        }
        
        [self.cm connectPeripheral:self.activePeripheral];
    }
}

@end
