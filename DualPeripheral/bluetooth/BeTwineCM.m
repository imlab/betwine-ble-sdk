//
//  Created by leon on 13-11-17.
//  Copyright (c) 2013 imlab.cc. All rights reserved.
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

#import "BeTwineCM.h"
#import "CBPeripheral+Compatible.h"
#import "CBUUID+String.h"
#import "CMBDFrameworkDefines.h"

/* internal objects for recognizing retrieved connected devices*/
@interface ConnectedPeripheralsReader:NSObject <CBPeripheralDelegate>
@property (nonatomic,strong) NSMutableDictionary *prodctInfoDict;
@property (nonatomic,strong) NSMutableDictionary *inDiscoverDevices;
@property (nonatomic,assign) BeTwineCM *cm;
+(ConnectedPeripheralsReader*)readerForCM:(BeTwineCM*)cm;
-(void)discoverProductInfoOfDevice:(CBPeripheral*)peripheral;
-(BOOL)isInDiscoverDevices:(CBPeripheral*)perihperal;
-(void)peripheralDidConnected:(CBPeripheral*)peripheral;
@end

@implementation ConnectedPeripheralsReader

-(id)init {
    self = [super init];
    if (self) {
        self.prodctInfoDict = [NSMutableDictionary dictionary];
        self.inDiscoverDevices = [NSMutableDictionary dictionary];
    }
    
    return self;
}

+(ConnectedPeripheralsReader*)readerForCM:(BeTwineCM *)cm {
    ConnectedPeripheralsReader *reader = [[ConnectedPeripheralsReader alloc] init];
    if (reader) {
        reader.cm = cm;
    }
    return reader;
}

-(void)discoverProductInfoOfDevice:(CBPeripheral*)peripheral {
    [self.inDiscoverDevices setObject:peripheral forKey:[peripheral deviceUUIDString]];
    [self.cm connectPeripheral:peripheral];
    
    NSLog(@"[BeTwineCM.ConnectedPeripheralsReader] retrieving product info for peripheral: %@", [peripheral.identifier UUIDString]);
}

-(BOOL)isInDiscoverDevices:(CBPeripheral *)perihperal {
    return [self.inDiscoverDevices objectForKey:[perihperal deviceUUIDString]] != nil;
}

-(void)peripheralDidConnected:(CBPeripheral *)peripheral {
    NSLog(@"[BeTwineCM.ConnectedPeripheralsReader] connected peripheral: %@", [peripheral deviceUUIDString]);
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:CMBD_MAC_SERVICE_UUID]]];
}

-(void)peripheralDidDisconnected:(CBPeripheral*)peripheral {
    [self.inDiscoverDevices removeObjectForKey:[peripheral deviceUUIDString]];
    NSLog(@"[BeTwineCM.ConnectedPeripheralsReader] discconnected peripheral: %@", [peripheral deviceUUIDString]);
}


-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
//    NSLog(@"[BeTwineCM.ConnectedPeripheralsReader] found service: %@", peripheral.services);
    for (CBService *s in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:s];
    }
}


-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
//    NSLog(@"[BeTwineCM.ConnectedPeripheralsReader] found characteristics: %@", service.characteristics);
    for (CBCharacteristic *c in service.characteristics) {
        if ([c.UUID toInt] == CMBD_MAC_CHAR_UUID) {
            [peripheral readValueForCharacteristic:c];
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"[BeTwineCM.ConnectedPeripheralsReader] receive characterstics value: %@", characteristic.value);
    if ([characteristic.UUID toInt] == CMBD_MAC_CHAR_UUID) {
        
        [self.prodctInfoDict setObject:[NSData dataWithData:characteristic.value] forKey:[peripheral deviceUUIDString]];
        
        // disconnect retrieved device(need to disconnect device?)
        [self.cm disconnectPeripheral:peripheral];
    }
}

@end


@interface BeTwineCM ()
@property (nonatomic,strong) NSMutableArray *retrieveUUIDRefs; // this is to handle the retain/release CFUUIDs for iOS 6 bluetooth retrievePeripherals API
@property (nonatomic,strong) NSMutableArray *peripherals;
@property (nonatomic,strong) NSMutableDictionary *broadcastDatas;
@property (nonatomic,strong) ConnectedPeripheralsReader *connectedReader;
@end


@implementation BeTwineCM

@synthesize CM;
@synthesize peripherals, broadcastDatas, connectedReader;
@synthesize delegate;

- (void)initCentralManager
{
//    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) { // iOS 6
    
        CM = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
//    }
//    else { // for iOS 7 State Preservation and Restoration
//        
//        CM = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{ CBCentralManagerOptionRestoreIdentifierKey:@"BetwineCM"}];
//        
//    };

    self.scanTimer = nil;
    self.peripherals = [NSMutableArray array];
    self.broadcastDatas =[NSMutableDictionary dictionary];
    self.connectedReader = [ConnectedPeripheralsReader readerForCM:self];
}

- (NSInteger)scanPeripherals:(int)timeout withServices:(NSArray *)uuids
{
    if (CM.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"[BeTwineCM] cannot scan peripherals: CBPeripheralManager state not ON!");
        return -1;
    }
    
    if(self.scanTimer && self.scanTimer.isValid) {
        [self.scanTimer invalidate];
        self.scanTimer = nil;
    }
    [peripherals removeAllObjects];
    [broadcastDatas removeAllObjects];
    [connectedReader.prodctInfoDict removeAllObjects];
    
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) { // iOS 6
        [CM retrieveConnectedPeripherals];
    }
    else { // iOS 7
        NSArray *connected = [CM retrieveConnectedPeripheralsWithServices:uuids];
        [self centralManager:self.CM didRetrieveConnectedPeripherals:connected];
    };
    
    if (timeout > 0) {
        self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:(float)timeout target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    }
    
    [CM scanForPeripheralsWithServices:uuids options:nil];
    
    return 0;
}

- (void)scanTimer:(NSTimer *)timer
{
    [CM stopScan];
    [self.delegate didStopScanWithPeripherals:self.peripherals];
}

- (void)stopScan
{
    [self.scanTimer invalidate];
    self.scanTimer = nil;
    [CM stopScan];
    [self.delegate didStopScanWithPeripherals:self.peripherals];
}

- (void)connectPeripheral:(CBPeripheral *)p
{
    [CM connectPeripheral:p options:nil];
}

- (void)cancelConnectPeripheral:(CBPeripheral *)p
{
    [CM cancelPeripheralConnection:p];
}

- (void)disconnectPeripheral:(CBPeripheral *)p
{
    [CM cancelPeripheralConnection:p];
}

- (void)disconnectAllPeripherals
{
    CBPeripheral *disconnectPeripheral;
    for (disconnectPeripheral in peripherals) {
        if (disconnectPeripheral.state == CBPeripheralStateConnected) {
            [CM cancelPeripheralConnection:disconnectPeripheral];
        }
    }
}

- (void)retrievePeripheralsWithUUIDs:(NSArray *)deviceUUIDs
{
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) { // below ios 7
        
        // need a conversion from [NSUUID] to [CFUUIDRef]
        self.retrieveUUIDRefs = [NSMutableArray arrayWithCapacity:deviceUUIDs.count];
        for (NSUUID *uuid in deviceUUIDs) {
            CFUUIDRef cfuuid = CFUUIDCreateFromString(NULL, (CFStringRef)[uuid UUIDString]); // ...possibly memory leak
            [self.retrieveUUIDRefs addObject:(__bridge id)cfuuid];
        }
        
        [CM retrievePeripherals:self.retrieveUUIDRefs];
        
    }
    else { // above ios 7
        
        NSArray *knownUUIDs = [CM retrievePeripheralsWithIdentifiers:deviceUUIDs];
        
        [self.delegate didRetrievedPeripherals:knownUUIDs]; // return it directly
    };
}

-(NSDictionary*)getBroadcastDataForPeripheral:(CBPeripheral *)peripheral
{
    NSString *key;
   
    if( NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1 ) {
        // in iOS 6, use device index for key
        key = [[NSNumber numberWithInteger:[self.peripherals indexOfObject:peripheral]] stringValue];
    }
    else {
        // in iOS 7, use device uuid for key
        key = [peripheral deviceUUIDString];
    }

    return [self.broadcastDatas objectForKey:key];
}

-(NSData*)getManufacturerDataForPeripheral:(CBPeripheral *)periphperal {
    NSData *data = nil;
    NSDictionary *dict = [self getBroadcastDataForPeripheral:periphperal];
    if (dict != nil) {
        data = [dict objectForKey:CBAdvertisementDataManufacturerDataKey];
    }
    
    if (data == nil) {
        data = [self.connectedReader.prodctInfoDict objectForKey:[periphperal deviceUUIDString]];
    }
    
    return data;
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSArray *serviceUUIDs = [advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
    
//    if ([[peripheral.name lowercaseString] rangeOfString:@"betwine"].location != NSNotFound) {
    
        if (![peripherals containsObject:peripheral]) {
            NSLog(@"[BetwineCM] Found device: %@ broadcastData: %@", peripheral, advertisementData);
            
            [peripherals addObject:peripheral];
            
            if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) {
                // iOS 6, use index to get the advertisement data
                [broadcastDatas setObject:advertisementData forKey:[[NSNumber numberWithInteger:broadcastDatas.count] stringValue]];
            }
            else {
                // iOS 7, use device uuid to get the advertisement data
                [broadcastDatas setObject:advertisementData forKey:[peripheral deviceUUIDString]];
            };
        }
//    }
//    else {
//        NSLog(@"[BetwineCM] Found other devices: %@ service: %@", peripheral, [serviceUUIDs objectAtIndex:0]);
//    }
}

#pragma mark -- for retrieve known peripherals
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripheralList
{
    // believe this is iOS 6 only
    [self.delegate didRetrievedPeripherals:peripheralList];
    
    // release the query uuid refs
    for (int i = 0; i < self.retrieveUUIDRefs.count; i++) {
        CFUUIDRef cfuuid = (__bridge CFUUIDRef)[self.retrieveUUIDRefs objectAtIndex:i];
        CFRelease(cfuuid);
    }
    self.retrieveUUIDRefs = nil;
    
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)connectedPeripherals
{
    
    for (CBPeripheral *p in connectedPeripherals) {
        
        if (![peripherals containsObject:p]) {
            NSLog(@"[BetwineCM] Retrieved connected device: %@", p);
            
            [self.connectedReader discoverProductInfoOfDevice:p];
            
            [self.peripherals addObject:p];
        }
    }
    
}

#pragma mark -- central manager state handling
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [delegate didCentralStateChange:central.state];
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
        case CBCentralManagerStateResetting:
        case CBCentralManagerStateUnknown:
        case CBCentralManagerStateUnsupported:
        case CBCentralManagerStateUnauthorized:
        {
            [delegate didCentralManagerStatusToUnvailable];
        }
            break;
        case CBCentralManagerStatePoweredOn:
        {
            [delegate didCentralManagerStatusToAvailable];
        }
            break;
        default:
            break;
    }
}


#pragma mark -- connection handling

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if ([self.connectedReader isInDiscoverDevices:peripheral]) { // for internal product info discover
        [self.connectedReader peripheralDidConnected:peripheral];
    }
    else {
        [delegate didConnectPeripheral:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if ([self.connectedReader isInDiscoverDevices:peripheral]) { // for internal product info discover
        [self.connectedReader peripheralDidDisconnected:peripheral];
    }
    else {
        [delegate didDisconnectPeripheral:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [delegate didFailToConnectPeripheral:peripheral];
}

#pragma mark -- for state preservation and restoration(iOS 7+ only)
// for those didn't opt-in preservation and restoration, the first responding method is "centralManagerDidUpdateState:" instead of "centralManager:willRestoreState:"
-(void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)state
{
    NSArray *restorePeripherals = state[CBCentralManagerRestoredStatePeripheralsKey];
    NSLog(@"[CMBDBadgeManager] state restoration for peripherals: %@", restorePeripherals);
    
    // don't know what to do here...
}

@end
