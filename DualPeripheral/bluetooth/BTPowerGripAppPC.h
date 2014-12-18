//
//  BTPowerGripAppPC.h
//  BluetoothXDemo
//
//  Created by imlab_DEV on 14-11-20.
//
//

#import <Foundation/Foundation.h>
#import "CMBDPeripheralConnector.h"
#import "BTPowerGripAppDefines.h"

@protocol BTPowerGripAppPCDelegate <CMBDPeripheralConnectorDelegate>

- (void)jsUpdate:(Byte)jsValue;
- (void)deviceInfoUpdate:(Byte*)deviceValues;

@end


@interface BTPowerGripAppPC : CMBDPeripheralConnector

@property (nonatomic, strong) CBCharacteristic *jsChar; // joystick
@property (nonatomic, strong) CBCharacteristic *deviceInfoChar;


-(void)enableJoystick;
-(void)disableJoystick;

-(void)enableDeviceInfo; // product id, mac address
-(void)disableDeviceInfo;
-(void)readDeviceInfo;


@end
