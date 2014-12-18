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
#import "BTPowerGripAppPC.h"
#import "BTBetwineAppPC.h"
#import "BTBetwineAppInterface.h"
#import "BTCommonUtil.h"

static CMBDBleDeviceManager *_bleDeviceMgr = nil;

@interface CMBDBleDeviceManager ()
@property (nonatomic,strong) BeTwineCM *cm;
@property (nonatomic,strong) NSMutableArray *discoverList;
@property (nonatomic,strong) NSMutableArray *connectedDevices;
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
/* discover methods */
-(BOOL)scanBLEDeviceWithType:(CMBDPeripheralConnectorType)deviceType
{
    [self.discoverList removeAllObjects];
    
    // scan device
    NSString *uuid = [self getBroadcastUUIDByConnectorType:deviceType];
    NSLog(@"[CMBDBleDeviceManager] scan BLE device with type: %d broadcast:%@", deviceType, uuid);
    self.isScanning = YES;
    
    
    NSInteger result = [self.cm scanPeripherals:5 withServices:@[[CBUUID UUIDWithString:uuid]]];
    
    if (result == -1) {
        self.isScanning = false;
        [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_MGR_DISABLED_ERROR object:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_START_SCAN object:self userInfo:nil];
    }
    
    return result == 0;
}

-(BOOL)stopScanningForPeripheral {
    if (self.cm) {
        [self.cm stopScan];
        return true;
    }
    else {
        return false;
    }
}

/* query methods */
-(NSArray*)getConnectedDevicesByType:(CMBDPeripheralConnectorType)deviceType {
    
    
    NSArray *devList = [self getDeviceByType:deviceType fromDeviceList:self.connectedDevices];
    
    NSMutableArray *idList = [NSMutableArray arrayWithCapacity:devList.count];
    for (CMBDBleDevice *device in devList) {
        [idList addObject:device.macAddr];
    }
    
    return idList;
}

-(CMBDPeripheralInterface*)getConnectedInterfaceByDeviceId:(NSString *)deviceId {
    CMBDBleDevice *device = [self getContainDeviceWithDevId:deviceId fromDeviceList:self.connectedDevices];
    
    if (device) {
        return device.interface;
    }
    else {
        return nil;
    }
}


/* connection methods */
-(void)connectDeviceWithDeviceId:(NSString*)devId {
    // if already in connected list, no need to connect again
    CMBDBleDevice *device = [self getContainDeviceWithDevId:devId fromDeviceList:self.connectedDevices];
    
//    if (device) {
//        NSLog(@"[CMBDBleDeviceManager] device %@ already connected!", devId);
//        return;
//    }
    
    // check discover list
    if (device == nil) {
        device = [self getContainDeviceWithDevId:devId fromDeviceList:self.discoverList];
    }
    
    if (device) {
        [self connectDevice:device];
        return;
    }
    
    // unknown device
    NSLog(@"[CMBDBleDeviceManager] cannot connect to unknown device  (devId: %@)", devId);
}

-(void)disconnectDeviceWithDeviceId:(NSString *)devId {
    
    // if already in connected list, no need to connect again
    CMBDBleDevice *device = [self getContainDeviceWithDevId:devId fromDeviceList:self.connectedDevices];
    
    if (device) {
        [self disconnectDevice:device];
    }
}

// private
-(void)connectDevice:(CMBDBleDevice *)dev
{
    if (dev.isConnected) {
        NSLog(@"[CMBDBleDeviceManager] connectDevice: %@ already connected!", dev);
        return;
    }
    
    // move to connected device
    NSLog(@"[CMBDBleDeviceManager] connecting peripheral: %@", dev.peripheral);
    
    [self.cm connectPeripheral:dev.peripheral];
    [self.connectedDevices addObject:dev];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_CONNECTING object:self userInfo:@{CMBD_NTF_DICT_KEY_DEVICE_ID:dev.deviceId}];
    
}

// private
-(void)disconnectDevice:(CMBDBleDevice*)device {
    device.keepConnection = NO; // actively disconnect should not keep connection
    [self.cm disconnectPeripheral:device.peripheral];
}

// deprecated
-(void)disconnectAllDevices {
    
    for(CMBDBleDevice *d in self.connectedDevices) {
        d.keepConnection = NO;
        [self disconnectDevice:d];
    }
    
//    [self.connectedDevices removeAllObjects]; // entries should be removed at delegate call back
    [self.discoverList removeAllObjects];
}

#pragma mark -- private methods
-(NSMutableArray*)toCMBDBleDeviceListFromCBPeripheralList:(NSArray*)list
{
    NSMutableArray *bleDeviceList = [NSMutableArray arrayWithCapacity:list.count];
    
    for (CBPeripheral *p in list) {
        CMBDBleDevice *bd = [[CMBDBleDevice alloc]  init];
        NSData *data = [self.cm getManufacturerDataForPeripheral:p];
        
        [bd initWithPeripheral:p withManufacturerData:data];
        
        [bleDeviceList addObject:bd];
    }
    
    return bleDeviceList;
}

-(CMBDBleDevice*)getContainDeviceWithDevId:(NSString*)devId fromDeviceList:(NSArray*)deviceList
{
    for (CMBDBleDevice *item in deviceList) {
        
        if ([item.deviceId isEqualToString:devId])
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

-(NSArray*)getDeviceByType:(CMBDPeripheralConnectorType)connectorType fromDeviceList:(NSArray*)deviceList
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (CMBDBleDevice *item in deviceList) {
        
        if ([item deviceType] == connectorType) {
            
            [array addObject:item];
        }
    }
    
    return array;
}

-(NSString*)getBroadcastUUIDByConnectorType:(CMBDPeripheralConnectorType)connectorType
{
    switch(connectorType) {
        case CMBDConnectorType_PowerGrip:
        {
            // add PowerGrip App here ...
            return [BTPowerGripAppPC getBroadcastServiceUUID];
            
        }
        case CMBDConnectorType_BetwineApp:
        {
            return [BTBetwineAppPC getBroadcastServiceUUID];
        }
            
        case CMBDConnectorType_Unknown:
            return @"FFF0";
            break;
    }
    
    return nil;
}

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
        device.isConnected = false;
        
        NSLog(@"[CMBDBleDeviceManager] peripheral disconnected: %@ keepConnection: %@", device.macAddr, device.keepConnection ? @"yes":@"no");
        
        // notification to disconnected
        [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_DISCONNECTED object:nil userInfo:@{CMBD_NTF_DICT_KEY_DEVICE_ID: device.deviceId, CMBD_NTF_DICT_KEY_KEEP_CONNECTION:[NSNumber numberWithBool:device.keepConnection]}];
        
        [device onDisconnected];
        
        if (!device.keepConnection) {
            // if don't keep connection, disconnect it
            [self.connectedDevices removeObject:device];
            
        }
        else {
            // reconnect it
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
    
    NSMutableArray *choiceNames = [NSMutableArray arrayWithCapacity:self.discoverList.count];
    NSMutableArray *deviceIds = [NSMutableArray arrayWithCapacity:self.discoverList.count];
    for (CMBDBleDevice *device in self.discoverList) {
        [choiceNames addObject:[NSString stringWithFormat:@"%@(%@)", device.deviceTypeName, device.deviceId]];
        [deviceIds addObject:device.deviceId];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_CONN_EVT_STOP_SCAN object:nil userInfo:@{CMBD_NTF_DICT_KEY_CHOICENAMES:choiceNames, CMBD_NTF_DICT_KEY_DEVICE_ID_LIST:deviceIds}];
}

// for retrieving saved peripherals
-(void)didRetrievedPeripherals:(NSArray*)peripheralList
{
    // .. if there are
}


@end
