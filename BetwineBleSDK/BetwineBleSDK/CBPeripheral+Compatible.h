//
//  CBPeripheral+Compatible.h
//  CleverBadge
//
//  Created by imlab_DEV on 14-1-17.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (Compatible)

-(NSString*)deviceUUIDString;

@end
