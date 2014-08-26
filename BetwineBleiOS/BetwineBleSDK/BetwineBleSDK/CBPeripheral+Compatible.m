//
//  CBPeripheral+Compatible.m
//  CleverBadge
//
//  Created by imlab_DEV on 14-1-17.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#import "CBPeripheral+Compatible.h"
#import "CBUUID+String.h"

@implementation CBPeripheral (Compatible)

-(NSString*)deviceUUIDString
{
    if( NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 ) {
        return [self.identifier UUIDString];
    }
    else {
        if (self.UUID) {
            return [[CBUUID UUIDWithCFUUID:self.UUID] representativeString];
        } else {
            return @"null";
        }
    }
}

@end
