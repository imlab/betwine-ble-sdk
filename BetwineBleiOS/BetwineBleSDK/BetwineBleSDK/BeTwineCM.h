//
//  BeTwineCM.h
//  BeTwineOAD
//
//  Created by kang janine on 13-11-17.
//  Copyright (c) 2013年 leon. All rights reserved.
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
