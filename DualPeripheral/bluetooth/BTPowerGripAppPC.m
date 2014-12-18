//
//  BTPowerGripAppPC.m
//  BluetoothXDemo
//
//  Created by imlab_DEV on 14-11-20.
//
//

#import "BTPowerGripAppPC.h"
#import "CBUUID+String.h"

@implementation BTPowerGripAppPC
@synthesize activePeripheral;
@synthesize jsChar, deviceInfoChar;

-(id<BTPowerGripAppPCDelegate>)myDelegate
{
    return (id<BTPowerGripAppPCDelegate>)self.delegate;
}


#pragma mark -- CMBDPeripheralConnectorDelegate methods
+(NSString*)getBroadcastServiceUUID
{
    return CB_BROADCAST_SVC_UUID_POWERGRIP;
}

- (void)initWithPeripheral:(CBPeripheral *)p {
    jsChar = nil;
    deviceInfoChar = nil;
    
    self.pcMode = CMBDConnectorType_PowerGrip;
    
    [super initWithPeripheral:p];
}

-(void)deactivatePeripheral
{
    // release the characteristics
    jsChar = nil;
    deviceInfoChar = nil;
    
    [super deactivatePeripheral];
}

#pragma mark -- BTPowerGripPC methods

-(void)enableJoystick
{
    if (self.activePeripheral && jsChar) {
        [self.activePeripheral setNotifyValue:YES forCharacteristic:jsChar];
    }
}

-(void)disableJoystick
{
    
    if (self.activePeripheral && jsChar) {
        [self.activePeripheral setNotifyValue:NO forCharacteristic:jsChar];
    }
}

-(void)enableDeviceInfo
{
    if (self.activePeripheral && deviceInfoChar) {
        [self.activePeripheral setNotifyValue:YES forCharacteristic:deviceInfoChar];
    }
}

-(void)disableDeviceInfo
{
    
    if (self.activePeripheral && deviceInfoChar) {
        [self.activePeripheral setNotifyValue:NO forCharacteristic:deviceInfoChar];
    }
}

-(void)readDeviceInfo
{
    if (self.activePeripheral && deviceInfoChar) {
        [self.activePeripheral readValueForCharacteristic:deviceInfoChar];
    }
    else {
        NSLog(@"[CMBD] read device info characteristic not ready, ignored");
    }
}


#pragma mark -- CBPeripheralDelegate methods

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"[BTPowerGripAppPC] didDiscoverCharacteristicsForService: service(%@)\n", service.UUID);
    
    UInt16 serviceUUID = [service.UUID toInt];
    
    BOOL chFound = NO; // this flag limits the service check and delegate method to AppPC related services
    
    if (!error) {
        switch (serviceUUID) {
            case CB_PG_JOYSTICK_SERVICE_UUID:
            {
                CBCharacteristic *c;
                for (c in service.characteristics) {
                    if ([c.UUID toInt] == CB_PG_JOYSTICK_VALUE_UUID) {
                        jsChar = c;
                        chFound = YES;
                    }
                }
                break;
            }
            case CB_PG_MAC_SERVICE_UUID:
            {
                CBCharacteristic *c;
                for (c in service.characteristics) {
                    if ([c.UUID toInt] == CB_PG_MAC_VALUE_UUID) {
                        deviceInfoChar = c;
                        chFound = YES;
                    }
                }
                break;
            }
            default:
                break;
        }
        
        // -- cannot add new characterisitcs check here...
        if (jsChar && deviceInfoChar && chFound) {
            self.isPCReady = YES;
            [[self myDelegate] onPCReady:CMBDPeripheralConnectorFeature_PowerGrip_1_0];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    CBService *s;
    
    jsChar = nil;
    deviceInfoChar = nil;
    
    for (s in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:s];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    UInt16 characteristicUUID = [characteristic.UUID toInt];
    
    if (!error) {
        switch (characteristicUUID) {
            case CB_PG_JOYSTICK_VALUE_UUID:
            {
                Byte jsValue;
                [characteristic.value getBytes:&jsValue length:CB_PG_JOYSTICK_VALUE_LEN];
                if (peripheral == activePeripheral) {
                    [[self myDelegate] jsUpdate:jsValue];
                }
                break;
            }
                
            case CB_PG_MAC_VALUE_UUID:
            {
                Byte devInfo[CB_PG_MAC_VALUE_LEN];
                [characteristic.value getBytes:&devInfo length:CB_PG_MAC_VALUE_LEN];
                if (peripheral == activePeripheral) {
                    [[self myDelegate] deviceInfoUpdate:devInfo];
                }
                break;
            }
                
            default:
                break;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral {
    
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    
}

@end
