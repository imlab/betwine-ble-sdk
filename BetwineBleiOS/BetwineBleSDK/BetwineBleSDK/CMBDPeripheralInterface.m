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

#import "CMBDPeripheralInterface.h"
#import "BTBetwineAppInterface.h"

@interface CMBDPeripheralInterface ()
@end

@implementation CMBDPeripheralInterface

-(void)activateWithConnector:(CMBDPeripheralConnector *)connector
{
    self.connector = connector;
    self.connector.delegate = self;

}

-(void)onPCReady:(CMBDPeripheralConnectorFeature)feature
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"[CMBDPeripheralInterface] please define onPCReady() method for %@", self]
                                 userInfo:nil];
}

+(CMBDPeripheralInterface*)interfaceWithType:(CMBDPeripheralConnectorType)deviceType
{
    switch (deviceType) {
        case CMBDConnectorType_Unknown:
        case CMBDConnectorType_BetwineApp:
        {
            return [[BTBetwineAppInterface alloc] init];
        }
            break;
        default:
            break;
    }
    return nil;
}

@end
