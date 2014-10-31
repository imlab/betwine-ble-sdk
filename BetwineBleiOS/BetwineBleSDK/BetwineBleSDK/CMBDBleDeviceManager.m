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

#import "CMBDBleDeviceManager.h"
#import "CBUUID+String.h"
#import "CBPeripheral+Compatible.h"
#import "BTBetwineAppPC.h"
#import "BTBetwineAppInterface.h"
#import "CommonUtil.h"

static CMBDBleDeviceManager *_bleDeviceMgr = nil;

@interface CMBDBleDeviceManager ()
@property (nonatomic,strong) BeTwineCM *cm;
@property (nonatomic,strong) NSMutableArray *discoverList;
@property (nonatomic) BOOL isScanning;
@end

@implementation CMBDBleDeviceManager


/* init methods*/
+(CMBDBleDeviceManager*)defaultManager {
    if (!_bleDeviceMgr) {
        _bleDeviceMgr = [[CMBDBleDeviceManager alloc] init];
    }
    return _bleDeviceMgr;
}

-(void)initBleDeviceManager {
    if (!self.cm) {
        NSLog(@"[CMBDBleDeviceManager] initialize central manager...");
        self.cm = [[BeTwineCM alloc] init];
        self.cm.delegate = self;
        [self.cm initCentralManager]; // initialize central manager
        
        self.connectedDevices = [NSMutableArray array];
        self.discoverList = [NSMutableArray array];
        self.isScanning = NO;
    }
}

/* check methods */
-(BOOL)isBluetoothAvailable {
    if (self.cm && self.cm.CM.state == CBCentralManagerStatePoweredOn) {
        return YES;
    }
    else {
        return NO;
    }
}

-(BOOL)isInScanning
{
    return self.isScanning;
}

-(BOOL)isDeviceReady:(CMBDBleDevice*)device {

   return ([self.connectedDevices containsObject:device]  && device.isPCReady);
}


-(BOOL)isDeviceTypeConnected:(CMBDPeripheralConnectorType)deviceType {
    return ([self getDeviceByType:deviceType fromDeviceList:self.connectedDevices] != nil);
}

/* discover methods */
-(BOOL)scanBLEDeviceWithType:(CMBDPeripheralConnectorType)deviceType
{
    // disconnect device if it's connected
    CMBDBleDevice *connectedDevice = [self getConnectedDeviceByType:deviceType];
    if (connectedDevice) {
        [self disconnectDevice:connectedDevice];
    }
    
    [self.discoverList removeAllObjects];
    
    // scan device
    NSString *uuid = [self getBroadcastUUIDByConnectorType:deviceType];
    NSLog(@"[CMBDBleDeviceManager] scan BLE device with type: %d broadcast:%@", deviceType, uuid);
    self.isScanning = YES;
    
    
    NSInteger result = [self.cm scanPeripherals:5 withServices:@[[CBUUID UUIDWithString:uuid]]] == 0;
    
    if (result == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_START_SCAN object:self userInfo:nil];
        
        return true;
    }
    else {
        self.isScanning = NO;
        return false;
    }
}

/* query methods */
-(CMBDBleDevice*)getConnectedDeviceByType:(CMBDPeripheralConnectorType)deviceType {
    return [self getDeviceByType:deviceType fromDeviceList:self.connectedDevices];
}

-(CMBDPeripheralInterface*)getDeviceInterfaceByType:(CMBDPeripheralConnectorType)deviceType
{
    CMBDBleDevice *device = [self getConnectedDeviceByType:deviceType];
    
    if (device) {
        return device.interface;
    }
    else {
        return nil;
    }
}

/* connection methods */
-(void)connectDeviceWithUUIDStr:(NSString*)uuid {
    // check connected list
    CMBDBleDevice *device = [self getContainDeviceWithUUID:uuid fromDeviceList:self.connectedDevices];
    
    if (device) {
        return;
    }
    
    // check discover list
    device = [self getContainDeviceWithUUID:uuid fromDeviceList:self.discoverList];
    if (device) {
        [self connectDevice:device];
        return;
    }
    
    // unknown device
    NSLog(@"[CMBDBleDeviceManager] cannot connect to unknown device  (uuid: %@)", uuid);
}

-(void)connectDevice:(CMBDBleDevice *)dev
{
    NSLog(@"[CMBDBleDeviceManager] connecting peripheral: %@", dev.peripheral);
    
    [self.cm connectPeripheral:dev.peripheral];
    
    // move to connected device
    if (![self.connectedDevices containsObject:dev]) {
        [self.connectedDevices addObject:dev];
    }
    
//    // 6 seconds connection check
//    [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(connectPeripheralTimeCheck:) userInfo:dev repeats:NO];
}

-(void)disconnectDevice:(CMBDBleDevice*)device {
    device.keepConnection = NO; // actively disconnect should not keep connection
    [self.cm disconnectPeripheral:device.peripheral];
}

-(void)disconnectAllDevices {
    
    for(CMBDBleDevice *d in self.connectedDevices) {
//        d.keepConnection = NO;
        [self disconnectDevice:d];
    }
    
    [self.connectedDevices removeAllObjects];
    [self.discoverList removeAllObjects];
}

#pragma mark -- private methods
-(NSMutableArray*)toCMBDBleDeviceListFromCBPeripheralList:(NSArray*)list
{
    NSMutableArray *bleDeviceList = [NSMutableArray arrayWithCapacity:list.count];
    
    for (CBPeripheral *p in list) {
        CMBDBleDevice *bd = [[CMBDBleDevice alloc]  init];
        NSDictionary *dict = [self.cm getBroadcastDataForPeripheral:p];
        
        [bd initWithPeripheral:p withBroadcastData:dict];
        
        [bleDeviceList addObject:bd];
    }
    
    return bleDeviceList;
}

-(CMBDBleDevice*)getContainDeviceWithUUID:(NSString*)uuid fromDeviceList:(NSArray*)deviceList
{
    for (CMBDBleDevice *item in deviceList) {
        
        if ([[item.peripheral deviceUUIDString] isEqualToString:uuid])
        {
            return item;
        }
    }
    
    return nil;
}

-(CMBDBleDevice*)getContainDevice:(CMBDBleDevice*)device fromDeviceList:(NSArray*)deviceList
{
    for (CMBDBleDevice *item in deviceList) {
        
        if ([[item.peripheral deviceUUIDString] isEqualToString:[device.peripheral deviceUUIDString]]) {
            
            return item;
        }
    }
    
    return nil;
}

-(CMBDBleDevice*)getContainDeviceWithPeriperal:(CBPeripheral*)peripheral fromDeviceList:(NSArray*)deviceList
{
    for (CMBDBleDevice *item in deviceList) {
        
        if ([[item.peripheral deviceUUIDString] isEqualToString:[peripheral deviceUUIDString]]) {
            
            return item;
        }
    }
    
    return nil;
}

-(CMBDBleDevice*)getDeviceByType:(CMBDPeripheralConnectorType)connectorType fromDeviceList:(NSArray*)deviceList
{
    for (CMBDBleDevice *item in deviceList) {
        
        if ([item deviceType] == connectorType) {
            
            return item;
        }
    }
    
    return nil;
}

-(NSString*)getBroadcastUUIDByConnectorType:(CMBDPeripheralConnectorType)connectorType
{
    switch(connectorType) {
        case CMBDConnectorType_Unknown:
        case CMBDConnectorType_BetwineApp:
        {
            return [BTBetwineAppPC getBroadcastServiceUUID];
        }
            break;
    }
    
    return nil;
}

//-(void)connectPeripheralTimeCheck:(NSTimer*)timer
//{
//    CMBDBleDevice *dev = timer.userInfo;
//    
//    // cancel connect if it's not connected after timer fires
//    if (!dev.isConnected) {
//        [self.cm cancelConnectPeripheral:dev.peripheral];
//    }
//}
//
//-(void)connectPeripheralTimerRetry:(NSTimer*)timer
//{
//    CMBDBleDevice *dev = timer.userInfo;
//    [self connectDevice:dev];
//}

#pragma mark BeTwineCM delegate methods
-(void)didCentralManagerStatusToUnvailable
{
    NSLog(@"[CMBDBleDeviceManager] CBCentralManager status changed to unavailable");
    
    // Notify Central Manager unavailable
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_EVT_CENTRAL_MGR_BECOME_UNAVAILABLE object:nil];
    
    // reset all device lsit
    [self disconnectAllDevices];
}

- (void)didCentralManagerStatusToAvailable
{
    NSLog(@"[CMBDBleDeviceManager] CBCentralManager status changed to available");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_EVT_CENTRAL_MGR_BECOME_AVAILABLE object:nil];
}

- (void)didCentralStateChange:(CBCentralManagerState)state
{
    NSString *stateStr;
    
    switch (state) {
        case CBCentralManagerStatePoweredOff:
            stateStr = @"CBCentralManagerStatePoweredOff";
            break;
        case CBCentralManagerStateResetting:
            stateStr = @"CBCentralManagerStateResetting";
            break;
        case CBCentralManagerStateUnknown:
            stateStr = @"CBCentralManagerStateUnknown";
            break;
        case CBCentralManagerStateUnsupported:
            stateStr = @"CBCentralManagerStateUnsupported";
            break;
        case CBCentralManagerStateUnauthorized:
            stateStr = @"CBCentralManagerStateUnauthorized";
            break;
        case CBCentralManagerStatePoweredOn:
            stateStr = @"CBCentralManagerStatePoweredOn";
            break;
        default:
            stateStr = @"N/A";
    }
    
    NSLog(@"[CMBDBleDeviceManager] CBCentralManager status: %@", stateStr);
}

- (void)didConnectPeripheral:(CBPeripheral *)p
{
    // check connected list
    CMBDBleDevice *device = [self getContainDeviceWithPeriperal:p fromDeviceList:self.connectedDevices];
    
    if (device) {
        [device onConnected];
        return;
    }
    else {
        // check discover list
        device = [self getContainDeviceWithPeriperal:p fromDeviceList:self.discoverList];
    }
    
    if (device) {
        // add to connected device
        [self.connectedDevices addObject:device];
        
        [device onConnected]; // call back method
        
        return;
    }
    
    NSLog(@"[CMBDBleDeviceManager] ignored connected unknown device: %@", p);
    
    return;
}

- (void)didDisconnectPeripheral:(CBPeripheral *)p
{
    CMBDBleDevice *device = [self getContainDeviceWithPeriperal:p fromDeviceList:self.connectedDevices];
    if (device) {
        NSLog(@"[CMBDBleDeviceManager] peripheral disconnected: %@", p);
        
        [device onDisconnected];
        
        if (!device.keepConnection) {
            // if don't keep connection, disconnect it
            [self.connectedDevices removeObject:device];
            
            // notification to disconnected
            [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_DISCONNECTED object:nil userInfo:@{@"device": device}];
        }
        else {
            // reconnect it
//            [NSTimer scheduledTimerWithTimeInterval:9 target:self selector:@selector(connectPeripheralTimerRetry:) userInfo:device repeats:NO];
            [self connectDevice:device];
        }
    }
    else {
        NSLog(@"[CMBDBleDeviceManager] a device which is not in the connected list, disconnected: %@",  p);
    }
    
}

- (void)didFailToConnectPeripheral:(CBPeripheral *)p
{
    NSLog(@"[CMBDBleDeviceManager] failed to connect peripheral: %@", p);
    
    // usually due to transient reason, connection is not available
    // simply try to reconnect the peripheral?
    CMBDBleDevice *device = [self getContainDeviceWithPeriperal:p fromDeviceList:self.connectedDevices];
    if (!device) {
        device = [self getContainDeviceWithPeriperal:p fromDeviceList:self.discoverList];
    }
    
    if (device) {
        if (device.keepConnection) {
            
            [self connectDevice:device];
            return;
        }
    }
    else {
        NSLog(@"[CMBDBleDeviceManager] failed to connect unknown device: %@", p);
    }
}


- (void)didStopScanWithPeripherals:(NSArray*)peripheralList
{
    NSLog(@"[CMBDBleDeviceManager] stop scanning with peripherals: %@", peripheralList);
    [self.discoverList addObjectsFromArray:[self toCMBDBleDeviceListFromCBPeripheralList:peripheralList]];
    
    // if only one found, connect it automatically, else prompt user
    if (self.discoverList.count == 1) {
        [self connectDiscoveredDeviceAtIndex:0];
    }
    else if (self.discoverList.count > 1) {
        [self promptDeviceChooser];
    }
    else {
        // notify stop scanning
        NSDictionary *dict = [NSMutableDictionary dictionaryWithObject:self.discoverList forKey:@"discoverList"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_STOP_SCAN object:nil userInfo:dict];
    }
    
    self.isScanning = NO;
    
}

// for retrieving saved peripherals
-(void)didRetrievedPeripherals:(NSArray*)peripheralList
{
    // .. if there are
}


#pragma mark -- UI prompt
-(void)promptDeviceChooser
{
    NSInteger count = self.discoverList.count;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Choose a device", @"Choose device list in CMBDBadgeConnectionManager")delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    
    for(int i = 0; i < count; i++) {
        CMBDBleDevice *dev = [self.discoverList objectAtIndex:i];
        
        NSString *deviceID = dev.macAddr ? dev.macAddr : [dev.peripheral deviceUUIDString];
        if (deviceID == nil) {
            deviceID = @"NEW";
        }
        
        NSString *btnTitle = [NSString stringWithFormat:@"%@ (%@/%@)", dev.peripheral.name, [deviceID substringFromIndex:deviceID.length > 4 ? deviceID.length - 4 : 0], dev.deviceTypeShortName];
        
        [actionSheet addButtonWithTitle:btnTitle];
    }
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = count;
    
    [actionSheet showInView:[[[UIApplication sharedApplication] delegate] window]];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"[CMBDBadgeConnectionManager] choose device sheet dismiss with button %d", buttonIndex);
    
    NSInteger count = self.discoverList.count;
    
    if (buttonIndex == count) {
        NSLog(@"[CMBDBadgeConnectionManager] did not choose any device");
        
        // notify stop scanning
        NSDictionary *dict = [NSMutableDictionary dictionaryWithObject:self.discoverList forKey:@"discoverList"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_STOP_SCAN object:nil userInfo:dict];
    }
    else {
        
        [self connectDiscoveredDeviceAtIndex:buttonIndex];
//        CMBDBleDevice *dev = [self.discoverList objectAtIndex:buttonIndex];
//        [self connectDevice:dev];
//        
//        // save device for user
//        [DMDevice setDeviceByUser:[IFApplication getAuthUserId]
//                       deviceType:[self getDeviceTypeByConnectorType:dev.deviceType]
//                         deviceId:[dev.peripheral deviceUUIDString]];
//
//        
//        // send poke after bind device
//        BTBetwineAppInterface *btApp = (BTBetwineAppInterface*)dev.interface;
//        [btApp sendBindingVibrate];
    }
}

-(void)connectDiscoveredDeviceAtIndex:(NSInteger)index
{
    CMBDBleDevice *dev = [self.discoverList objectAtIndex:index];
    [self connectDevice:dev];
    
    switch (dev.deviceType) {
        case CMBDConnectorType_BetwineApp:
        {
            NSLog(@"[CMBDBleDeviceManager] connecting Betwine App...");
            
            // send poke after bind device
            BTBetwineAppInterface *btApp = (BTBetwineAppInterface*)dev.interface;
            [btApp sendBindingVibrate];
            
        }
            break;
        case CMBDConnectorType_Unknown:
        default:
            break;
    }

}

@end
