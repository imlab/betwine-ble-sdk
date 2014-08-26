//
//  BetwineAppInterface.h
//  CleverBadge
//
//  Created by imlab_DEV on 14-7-14.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#import "CMBDPeripheralInterface.h"
#import "BTAppDefines.h"
#import "BTBetwineAppPC.h"
#import "CMBDBleDevice.h"

#define CMBD_LED_TOTAL 6
#define CMBD_HISTORY_STEP_DAYS 7
#define CMBD_ACTIVE_MOVE_STEPS_THRESHOLD 5 // steps for checking active moves
#define CMBD_ACTIVE_MOVE_TIME_THRESHOLD 3.5 // steps for checking active moves

@interface BTBetwineAppInterface : CMBDPeripheralInterface <BTBeTwineAppPCDelegate> {
    NSInteger LEDs[CMBD_LED_TOTAL]; // (including vibrator)
    NSInteger StepHistory[CMBD_HISTORY_STEP_DAYS];
}

@property (nonatomic) NSInteger steps;
@property (nonatomic) NSInteger energy;
@property (nonatomic) NSInteger activity;
@property (nonatomic) NSInteger battery;
@property (nonatomic) NSInteger *leds; // leds[6] (0 is for virbator)
@property (nonatomic) NSInteger *stepHistory; // stepDays[7]
@property (nonatomic) BOOL batteryCharging;
@property (nonatomic) NSInteger lastVibTime; // time format (hour = lastVibTime / 100, minutes = lastVibTime %100)
@property (nonatomic) NSInteger systemTest;
@property (nonatomic) NSInteger systemTime;

-(void)sendBindingVibrate; // vibrate for binding notification
-(BOOL)sendVibrateAndLED;
-(BOOL)sendReadCurrentStatus;
-(BOOL)sendReadStepHistory;
-(BOOL)sendReadBattery;
-(BOOL)sendSetSystemTime:(NSDate*)time BeginTime:(NSInteger)beginTime EndTime:(NSInteger)endTime; // begin time and end time is for normal/night modes switching

-(BOOL)sendEnterOAD; // make device enter OAD mode

// protocol 1.2 methods
-(BOOL)sendReadDeviceInfo;
-(BOOL)sendReadVibTest;
-(BOOL)sendDeviceTestCode:(Byte)testCode;

@end
