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

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BetwineCMDelegate <NSObject>

- (void)didConnectPeripheral:(CBPeripheral *)p;
- (void)didDisconnectPeripheral:(CBPeripheral *)p;
- (void)didFailToConnectPeripheral:(CBPeripheral *)p;

- (void)didCentralStateChange:(CBCentralManagerState)state;
- (void)didCentralManagerStatusToAvailable;
- (void)didCentralManagerStatusToUnvailable;

- (void)didStopScanWithPeripherals:(NSArray*)peripheralList;

// for retrieving paired peripherals
-(void)didRetrievedPeripherals:(NSArray*)peripheralList;

@end

/*
 BetwineCM is for device discovery and connection handling.
*/
@interface BeTwineCM : NSObject <CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager *CM;
@property (nonatomic, strong) id<BetwineCMDelegate> delegate;
@property (nonatomic,strong) NSTimer *scanTimer;

- (void)initCentralManager;
- (NSInteger)scanPeripherals:(int)timeout withServices:(NSArray*)uuids;
- (void)stopScan;
- (void)connectPeripheral:(CBPeripheral *)p;
- (void)cancelConnectPeripheral:(CBPeripheral *)p;
- (void)disconnectPeripheral:(CBPeripheral *)p;
- (void)disconnectAllPeripherals;

- (void)retrievePeripheralsWithUUIDs:(NSArray*)deviceUUIDs; // array of NSUUID
- (NSDictionary*)getBroadcastDataForPeripheral:(CBPeripheral*)peripheral;

@end
