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

