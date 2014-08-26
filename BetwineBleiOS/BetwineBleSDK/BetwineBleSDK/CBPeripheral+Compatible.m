//
//  Created by imlab_DEV on 14-1-17.
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
