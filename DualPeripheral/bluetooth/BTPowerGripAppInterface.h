//
//  BTPowerGripAppInterface.h
//  BluetoothXDemo
//
//  Created by imlab_DEV on 14-11-20.
//
//

#import "CMBDPeripheralInterface.h"
#import "BTPowerGripAppPC.h"
#import "CMBDBleDevice.h"

@interface BTPowerGripAppInterface : CMBDPeripheralInterface <BTPowerGripAppPCDelegate>

-(BOOL)sendReadDeviceInfo;

@end
