//
//  Created by imlab_DEV on 14-7-14.
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

#import "BTBetwineAppInterface.h"
#import "BTBetwineAppPC.h"
#import "CommonUtil.h"

/* Internal Asynchronous Queue for buffering ble requests while not connected */

#define ASYNC_QUEUE_EFFECTIVE_INTERVAL  30 // buffer interval = 3 mins
#define ASYNC_QUEUE_LENGTH  10

typedef enum {
    CMBDAsyncRequestType_VibrateAndLED,
    CMBDAsyncRequestType_BindingVibrate,
} CMBDAsyncRequestType;

@interface CMBDAsyncRequest : NSObject

@property (nonatomic,strong) NSDate *time;
@property (nonatomic) CMBDAsyncRequestType reqType;
@property (nonatomic) Byte command;

@end

@implementation CMBDAsyncRequest

+(CMBDAsyncRequest*)createAsyncRequestWithType:(CMBDAsyncRequestType)type Command:(Byte)cmd
{
    CMBDAsyncRequest *instance = [[CMBDAsyncRequest alloc] init];
    instance.time = [NSDate date];
    instance.command = cmd;
    instance.reqType = type;
    
    return instance;
}

@end

/* Betwine App Interface */

@interface BTBetwineAppInterface()

@property (nonatomic) BOOL rfSyncState; // need to get all data ready before notification

// rf(reading flags), use to check if all needed data are read
@property (nonatomic) BOOL rfStep;
@property (nonatomic) BOOL rfActivity;
@property (nonatomic) BOOL rfEnergy;

@property (nonatomic, strong) NSMutableArray *badgeAsyncQueue; // array of CMBDAsyncRequest objects
@property (nonatomic,strong) NSString *deviceVersion;

@property (nonatomic) NSInteger activeMoveSteps; // for checking active move
@property (nonatomic,strong) NSDate *activeMoveDate; // for checking active move time

@end

@implementation BTBetwineAppInterface

-(id)init
{
    self = [super init];
    if (self) {
        self.leds = LEDs;
        self.stepHistory = StepHistory;
        self.batteryCharging = NO;
        self.badgeAsyncQueue = [NSMutableArray arrayWithCapacity:ASYNC_QUEUE_LENGTH];
        self.battery = 0xFF; // set full battery value
        self.deviceVersion = nil;
        self.activeMoveDate = [NSDate date];
        
        // sync flag variables init
        self.rfSyncState = NO;
    }
    return self;
}

-(BTBetwineAppPC*)myConnector
{
    return (BTBetwineAppPC*)self.connector;
}

-(void)onPCReady:(CMBDPeripheralConnectorFeature)feature
{
    
    switch (feature) {
        case CMBDPeripheralConnectorFeature_BetwineApp_1_0:
        {
            NSLog(@"[BTBetwineAppInterface] BTBetwineAppPC v1.0 ready");
            
            [[self myConnector] enablePedometer];
            [[self myConnector] enableHp];
            [[self myConnector] enableTime];
            [[self myConnector] readHp];
            [[self myConnector] readPedometer];
            [[self myConnector] readBatt];
            [[self myConnector] readOldsteps];
            
            NSLog(@"[CMBD] Set badge notification enable...");
            
            [self proceedAsyncQueue]; // proceed buffered requests
            
            // notify badge ready
            [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_EVT_DEVICE_APP_READY object:nil];
        }
            break;
            
        case CMBDPeripheralConnectorFeature_BetwinwApp_1_1:
        {
            NSLog(@"[BTBetwineAppInterface] BTBetwineAppPC v1.1 ready");
            
            [[self myConnector] enableDeviceInfo];
            [[self myConnector] enableVibrateTest];
            [[self myConnector] readDeviceInfo];
            [[self myConnector] readVibrateTest];
        }
            break;
        default:
        {
            NSLog(@"[BTBetwineAppInterface] expect BTBetwineAppPC ready but receive feature: %d", feature);
        }
            break;
    }
}

-(BOOL)sendSetSystemTime:(NSDate *)time BeginTime:(NSInteger)beginTime EndTime:(NSInteger)endTime
{
    if (self.connector.activePeripheral == nil) {
        NSLog(@"[CMBD] device not connected, ignore Set System Time command");
        return NO;
    }
    
    Byte time_byte[CB_TS_VALUE_LEN];
    
    NSDate *now = [NSDate date];
    NSInteger sysHour = [CommonUtil getHourFromDate:now];
    NSInteger sysMin = [CommonUtil getMinutesFromDate:now];
    NSInteger wakeHour = (beginTime / 100) % 24;
    NSInteger wakeMin = (beginTime % 100) % 60;
    NSInteger sleepHour = (endTime / 100) % 24;
    NSInteger sleepMin = (endTime % 100) % 60;
    
    NSLog(@"[CMBD] send set system time: %d:%02d wakeTime: %d:%02d sleepTime: %d:%02d", (int)sysHour, (int)sysMin, (int)wakeHour, (int)wakeMin, (int)sleepHour, (int)sleepMin);
    
    time_byte[0] = sysMin;
    time_byte[1] = sysHour;
    time_byte[2] = wakeMin;
    time_byte[3] = wakeHour;
    time_byte[4] = sleepMin;
    time_byte[5] = sleepHour;
    
    [[self myConnector] setTime:time_byte];
    
    return YES;
}

#pragma mark device methods
-(BOOL)sendVibrateAndLED
{
    BOOL motorOn = self.leds[0];
    Byte sendValue = 0;
    
    if (motorOn) { // default YES
        sendValue |= 0x20;
    } else {
        sendValue &= ~0x20;
    }
    
    if (self.leds[1]) {
        sendValue |= 0x10;
    } else {
        sendValue &= ~0x10;
    }
    
    if (self.leds[2]) {
        sendValue |= 0x08;
    } else {
        sendValue &= ~0x08;
    }
    
    if (self.leds[3]) {
        sendValue |= 0x04;
    } else {
        sendValue &= ~0x04;
    }
    
    if (self.leds[4]) {
        sendValue |= 0x02;
    } else {
        sendValue &= ~0x02;
    }
    
    if (self.leds[5]) {
        sendValue |= 0x01;
    } else {
        sendValue &= ~0x01;
    }
    
    // check peripheral availability
    if (self.connector.activePeripheral == nil) {
        NSLog(@"[CMBD] device not connected, ignore send VibrateAndLED");
        
        // put the request to async queue
        CMBDAsyncRequest *req = [CMBDAsyncRequest createAsyncRequestWithType:CMBDAsyncRequestType_VibrateAndLED Command:sendValue];
        [self asyncQueueSaveRequest:req];
        
        return NO;
    }
    
    
    NSLog(@"[CMBD] send Vibrate and LED: %x", sendValue);
    [[self myConnector] setMotor:sendValue];
    
    return YES;
}

-(BOOL)sendEnterOAD
{
    if ([self myConnector].activePeripheral == nil) {
        NSLog(@"[CMBD] device not connected, ignore Enter OAD command");
        return NO;
    }
    
    Byte sendValue = CB_DEVICE_TEST_RESET;
    [[self myConnector] setMotor:sendValue];
    
    return YES;
}

-(BOOL)sendReadCurrentStatus
{
    
    if ([self myConnector].activePeripheral == nil) {
        NSLog(@"[CMBD] device not connected, ignore Read Current Status command");
        return NO;
    }
    NSLog(@"[CMBD] send read current status");
    
    self.rfSyncState = YES; // need to sync
    
    // set flags to not read
    self.rfSyncState = self.rfStep = self.rfEnergy = NO;
    
    // send read request
    [[self myConnector] readHp];
    [[self myConnector] readPedometer];
    
    return YES;
}

-(BOOL)sendReadStepHistory
{
    if ([self myConnector].activePeripheral == nil) {
        NSLog(@"[CMBD] device not connected, ignore Read Step History command");
        return NO;
    }
    NSLog(@"[CMBD] send read step history");
    
    // send read request
    [[self myConnector] readOldsteps];
    
    return YES;
}

-(BOOL)sendReadBattery
{
    if ([self myConnector].activePeripheral == nil) {
        NSLog(@"[CMBD] device not connected, ignore Read Battery command");
        return NO;
    }
    NSLog(@"[CMBD] send read battery");
    
    [[self myConnector] readBatt];
    
    return YES;
}

-(BOOL)sendReadDeviceInfo
{
    if ([self myConnector].activePeripheral == nil) {
        NSLog(@"[CMBD] device not connected, ignore send read device info command");
        return NO;
    }
    NSLog(@"[CMBD] send read device info");
    
    [[self myConnector] readDeviceInfo];
    
    return YES;
}

-(BOOL)sendReadVibTest
{
    if ([self myConnector].activePeripheral == nil) {
        NSLog(@"[CMBD] device not connected, ignore send read last vib and test command");
        return NO;
    }
    NSLog(@"[CMBD] send read last vib and test");
    
    [[self myConnector] readVibrateTest];
    
    return YES;
}

-(BOOL)sendDeviceTestCode:(Byte)testCode {
    if ([self myConnector].activePeripheral == nil) {
        NSLog(@"[CMBD] device not connected, ignore send device test command");
        return NO;
    }
    NSLog(@"[CMBD] send  device test code: %02x", testCode);
    
    [[self myConnector] setMotor:testCode];
    
    return YES;
}


#pragma mark -- data delegate method
-(int)stepFromBytes:(Byte*)bytes
{
    int step_int = bytes[2];
    step_int = step_int << 8;
    step_int |= bytes[1];
    step_int = step_int << 8;
    step_int |= bytes[0];
    
    return step_int;
}

- (void)stepUpdate:(Byte *)stepValue
{
    NSInteger oldsteps = self.steps;
    self.steps = [self stepFromBytes:stepValue];
    
    self.rfStep = YES;
    
    NSLog(@"[CMBD] Receive steps: %ld", (long)self.steps);
    
    if (self.steps != oldsteps) { // steps update
        [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_EVT_RECEIVE_STEPS object:self];
    }
    
    // active move check
    NSDate *now = [NSDate date];
    
    if (self.steps < self.activeMoveSteps || self.activeMoveSteps == 0 ||
        [CommonUtil differenceFromDate:now toDate:self.activeMoveDate] > CMBD_ACTIVE_MOVE_TIME_THRESHOLD * 3) {
        // initiate state
        NSLog(@"[CMBD] initiate active  steps: %d", self.activeMoveSteps);
        self.activeMoveSteps = self.steps;
        self.activeMoveDate = now;
    }
    else if (self.steps - self.activeMoveSteps >= CMBD_ACTIVE_MOVE_STEPS_THRESHOLD) {
        NSDate *oldTime = self.activeMoveDate;
        self.activeMoveSteps = self.steps;
        self.activeMoveDate = now;
        
        if ([CommonUtil differenceFromDate:now toDate:oldTime] <= CMBD_ACTIVE_MOVE_TIME_THRESHOLD) {
            // confirm active move
            [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_EVT_RECEIVE_ACTIVE_MOVE object:nil];
        }
        
        NSLog(@"[CMBD] set active steps: %d", self.activeMoveSteps);
    }
    
    [self checkSyncStateUpdate];
}

- (void)stateUpdate:(Byte)stepState
{
    self.activity = stepState;
    
    //    switch (stepState) {
    //        case 0:
    //            // still
    //            break;
    //
    //        case 1:
    //            // walk
    //            break;
    //
    //        case 2:
    //            // slow run
    //            break;
    //
    //        case 3:
    //            // run
    //            break;
    //
    //        default:
    //            break;
    //    }
    
    
    self.rfActivity = YES;
    
    NSLog(@"[CMBD] Receive state: %d", self.activity);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_EVT_RECEIVE_ACT object:self];
    
    [self checkSyncStateUpdate];
}

- (void)hpUpdate:(Byte)hpValue
{
    self.energy = hpValue;
    
    self.rfEnergy = YES;
    
    NSLog(@"[CMBD] Receive energy: %d", self.energy);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_EVT_RECEIVE_ENERGY object:self];
    
    [self checkSyncStateUpdate];
}

- (void)oldstepsUpdate:(Byte *)oldstepValues
{
    NSMutableString *strBuf = [NSMutableString string];
    // set self steps
    for (int i = 0; i < CMBD_HISTORY_STEP_DAYS; i++) {
        self.stepHistory[i] = oldstepValues[3*i + 2];
        self.stepHistory[i] = self.stepHistory[i] << 8;
        self.stepHistory[i] |= oldstepValues[3*i + 1];
        self.stepHistory[i] = self.stepHistory[i] << 8;
        self.stepHistory[i] |= oldstepValues[3*i];
        
        if(self.stepHistory[i] == 0xFFFFFF) { // N/A step history,
            self.stepHistory[i] = 0;
        } else {
            self.stepHistory[i] = MIN(self.stepHistory[i], 199999); // MAX daily step 199999
        }
        
        [strBuf appendFormat:@" %d", self.stepHistory[i]];
        if(i == CMBD_HISTORY_STEP_DAYS - 1) {
            [strBuf appendString:@","];
        }
    }
    
    NSLog(@"[CMBD] Receive history steps: %@", strBuf);
    
    // fire history update event
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_EVT_RECEIVE_HISTORY_STEPS object:self];
}

-(void)battUpdate:(Byte)battValue
{
    self.battery = battValue & 0x7F;
    self.batteryCharging = battValue & 0x80;
    
    NSLog(@"[CMBD] Receive battery level: %d charging: %@", self.battery, self.batteryCharging ? @"yes": @"no");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_EVT_RECEIVE_BATTERY object:nil];
}

-(void)timeUpdate:(Byte *)timeValue
{
    NSInteger minute = timeValue[0] % 60;
    NSInteger hour = timeValue[1] % 24;
    
    NSLog(@"[CMBD] Receive time: %02d:%02d", hour, minute);
    
    self.systemTime = hour * 100 + minute; // in hhMM format
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_EVT_RECEIVE_TIME object:nil];
}

-(void)deviceInfoUpdate:(Byte *)bytes
{
    self.bleDevice.productId = [NSString stringWithFormat:@"%02x%02x", bytes[0], bytes[1]];
    self.bleDevice.macAddr = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7]];

    NSLog(@"[CMBD] Receive product id: %@ mac addr: %@", self.bleDevice.productId, self.bleDevice.macAddr);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_EVT_RECEIVE_DEVICE_INFO object:nil];
}

-(void)vibrateTestUpdate:(Byte *)testValues
{
    NSInteger minute = testValues[0];
    NSInteger hour = testValues[1];
    
    self.lastVibTime = hour * 100 + minute;
    self.systemTest = testValues[2] << 8 | testValues[3];
    
    NSLog(@"[CMBD] Receive last vib time: %d test result: %04x", self.lastVibTime, self.systemTest);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_EVT_RECEIVE_LAST_VIBRATE object:nil];
}

#pragma mark -- event handling methods
-(void)checkSyncStateUpdate
{
    if(self.rfSyncState) {
        
        if(self.rfStep && self.rfActivity && self.rfEnergy) {
            // fire state update event
            [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_EVT_RECEIVE_ALL_STATUS object:self];
            
            self.rfSyncState = NO;
        }
    }
    else {
        // fire state update event
        [[NSNotificationCenter defaultCenter] postNotificationName:CMBD_EVT_RECEIVE_ALL_STATUS object:self];
    }
}


#pragma mark -- Asynchronous BLE Request Queue
/* save a request in the queue */
-(void)asyncQueueSaveRequest:(CMBDAsyncRequest*)request
{
    
    if (self.badgeAsyncQueue.count < ASYNC_QUEUE_LENGTH) {
        
        [self.badgeAsyncQueue addObject:request];
    }
    else {
        NSLog(@"[BTBetwineAppInterface] warning: Badge Async Queue is full. Discard the oldest one to insert...");
        
        [self.badgeAsyncQueue removeObjectAtIndex:0];
        [self.badgeAsyncQueue addObject:request];
    }
    
    NSLog(@"[BTBetwineAppInterface] request saved in badge async queue. queue count: %d", self.badgeAsyncQueue.count);
}
/* proceed the queued requests; execute  */
-(void)proceedAsyncQueue
{
    NSLog(@"[BTBetwineAppInterface] proceed async queue: %d items", self.badgeAsyncQueue.count);
    
    NSDate *now = [NSDate date];
    NSInteger pokeCnt = 0;
    NSInteger bindCnt = 0;
    NSInteger otherCnt = 0;
    // count different requests
    for (CMBDAsyncRequest *req in self.badgeAsyncQueue) {
        
        if (req.reqType == CMBDAsyncRequestType_VibrateAndLED) {
            
            if ([now timeIntervalSinceDate:req.time] < ASYNC_QUEUE_EFFECTIVE_INTERVAL) {
                pokeCnt++;
            }
        }
        else if (req.reqType == CMBDAsyncRequestType_BindingVibrate) {
            bindCnt++;
        }
        else { // if there's other commands, use other counts
            otherCnt++;
        }
    }
    
    if (otherCnt > 0) {
        NSLog(@"[BTBetwineAppInterface] warning: there is unknown request type in async queue");
    }
    
    // proceed poke commands
    // -- suppose you have user profile here
    
    pokeCnt = (pokeCnt > 5) ? 5 : pokeCnt;
    self.leds[0] = YES;
    for (int i = 1; i <= 5; i++) {
//        self.leds[i] = (i <= [profile.energy integerValue]); // this should
        self.leds[i] = true;
    }
    
    for (int i = 0; i < pokeCnt; i++) {
        [self sendVibrateAndLED];
    }
    
    // proceed other commands if there are...
    if (bindCnt > 0) {
        for (int i=0; i <= 5; i++) {
            self.leds[i] = YES;
        }
        
        [self sendVibrateAndLED];
    }
    
    // clean async queue
    [self.badgeAsyncQueue removeAllObjects];
}

/* a special async request that is used for device binding */
-(void)sendBindingVibrate
{
    CMBDAsyncRequest *req = [CMBDAsyncRequest createAsyncRequestWithType:CMBDAsyncRequestType_BindingVibrate Command:0xFF];
    
    [self asyncQueueSaveRequest:req];
}



@end
