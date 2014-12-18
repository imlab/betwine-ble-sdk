//
//  ViewController.m
//  DualPeripheral
//
//  Created by imlab_DEV on 14-10-30.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#import "ViewController.h"
#import "DeviceChooserTableViewController.h"
#import "CMBDBleDeviceManager.h"

@interface ViewController ()
@property NSString *device1;
@property NSString *device2;

@property NSTimer *checkTimer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"[ViewController] I'm loaded!");
    
    [BTWAvatarView loadAnimations];
    [self.avatar1View setAnimationToStatus:BTWAvatarStatus_BREATH];
    [self.avatar2View setAnimationToStatus:BTWAvatarStatus_BREATH];
    
    self.connection1Label.text = @"Not connected";
    self.connection2Label.text = @"Not connected";
    
    [self setPlayer1State:@0];
    [self setPlayer1Energy:@0];
    [self setPlayer1Steps:@0];
    
    [self setPlayer2State:@0];
    [self setPlayer2Energy:@0];
    [self setPlayer2Steps:@0];
    
    [self initBleFunctions];
}

-(void)dealloc
{
    [self deinitBleFunctions];
}

-(void)setPlayer1State:(NSNumber*)state
{
    self.state1Label.text = [NSString stringWithFormat:@"State: %@", state];
    
    switch (state.integerValue) {
        case 0:
            [self.avatar1View setAnimationToStatus:BTWAvatarStatus_TIRED];
            break;
        case 1:
            [self.avatar1View setAnimationToStatus:BTWAvatarStatus_BREATH];
            break;
        case 2:
            [self.avatar1View setAnimationToStatus:BTWAvatarStatus_WALKING];
            break;
        case 3:
            [self.avatar1View setAnimationToStatus:BTWAvatarStatus_RUNNING];
            
        default:
            break;
    }
}

-(void)setPlayer1Energy:(NSNumber*)energy
{
    self.energy1Label.text = [NSString stringWithFormat:@"Energy: %@", energy];
}

-(void)setPlayer1Steps:(NSNumber*)steps
{
    self.steps1Label.text = [NSString stringWithFormat:@"Steps: %@", steps];
}


-(void)setPlayer2State:(NSNumber*)state
{
    self.state2Label.text = [NSString stringWithFormat:@"State: %@", state];
    
    switch (state.integerValue) {
        case 0:
            [self.avatar2View setAnimationToStatus:BTWAvatarStatus_TIRED];
            break;
        case 1:
            [self.avatar2View setAnimationToStatus:BTWAvatarStatus_BREATH];
            break;
        case 2:
            [self.avatar2View setAnimationToStatus:BTWAvatarStatus_WALKING];
            break;
        case 3:
            [self.avatar2View setAnimationToStatus:BTWAvatarStatus_RUNNING];
            
        default:
            break;
    }
}

-(void)setPlayer2Energy:(NSNumber*)energy
{
    self.energy2Label.text = [NSString stringWithFormat:@"Energy: %@", energy];
}

-(void)setPlayer2Steps:(NSNumber*)steps
{
    self.steps2Label.text = [NSString stringWithFormat:@"Steps: %@", steps];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated {
    [self.checkTimer setFireDate:[NSDate distantFuture]];
}

- (IBAction)scanBetwineBtnClicked:(id)sender {
    // scan device
    [[CMBDBleDeviceManager defaultManager] scanBLEDeviceWithType:CMBDConnectorType_BetwineApp];
}

- (IBAction)scanGripBtnClicked:(id)sender {
    [[CMBDBleDeviceManager defaultManager] scanBLEDeviceWithType:CMBDConnectorType_PowerGrip];
}

- (IBAction)disconnectBtnClicked:(id)sender {
    [[CMBDBleDeviceManager defaultManager] disconnectAllDevices];
}


/* device related */
-(void)initBleFunctions {
    // add notification observers
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleStartScan:) name:CMBD_CONN_EVT_START_SCAN object:nil];
    [nc addObserver:self selector:@selector(handleStopScan:) name:CMBD_CONN_EVT_STOP_SCAN object:nil];
    [nc addObserver:self selector:@selector(handleConnected:) name:CMBD_CONN_EVT_CONNECTING object:nil];
    [nc addObserver:self selector:@selector(handleDisconnected:) name:CMBD_CONN_EVT_DISCONNECTED object:nil];
    [nc addObserver:self selector:@selector(handleDeviceReady:) name:CMBD_CONN_EVT_CONNECTED object:nil];
    
    [nc addObserver:self selector:@selector(receiveActivity:) name:CMBD_EVT_RECEIVE_ACT object:nil];
    [nc addObserver:self selector:@selector(receiveEnergy:) name:CMBD_EVT_RECEIVE_ENERGY object:nil];
    [nc addObserver:self selector:@selector(receiveSteps:) name:CMBD_EVT_RECEIVE_STEPS object:nil];
    
    [nc addObserver:self selector:@selector(receiveGripJSValue:) name:CB_PG_EVT_RECEIVE_JS object:nil];
    
    self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkConnection) userInfo:nil repeats:true];
    
   [self checkConnection];
}

-(void)deinitBleFunctions {
    // remove notification observers
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

-(void)checkConnection {
    CMBDBleDeviceManager *mgr = [CMBDBleDeviceManager defaultManager];
    
    if (mgr.isInScanning || self.device1 || self.device2) {
        return; // skip check if in scanning
    }
    
    // scan device
    [mgr scanBLEDeviceWithType:CMBDConnectorType_BetwineApp];
}


-(void)handleStartScan:(NSNotification*)notification {
    [self.bluetoothActivity startAnimating];
    
}

-(void)handleStopScan:(NSNotification*)notification {
    [self.bluetoothActivity stopAnimating];
    
    NSDictionary *dict = notification.userInfo;
    NSArray *deviceNames = [dict objectForKey:CMBD_NTF_DICT_KEY_CHOICENAMES];
    NSArray *deviceIds = [dict objectForKey:CMBD_NTF_DICT_KEY_DEVICE_ID_LIST];
    NSLog(@"discover devices: %@", deviceIds);
    
    if (deviceIds.count == 1) {
        [[CMBDBleDeviceManager defaultManager] connectDeviceWithDeviceId:[deviceIds objectAtIndex:0]];
    }
    else if (deviceIds.count > 1) {
        [self loadDeviceChooser:deviceNames deviceIds:deviceIds];
    }
    else {
        // no device found.
    }
}

-(void)handleConnected:(NSNotification*)notification {
    NSDictionary *dict = notification.userInfo;
    NSString *deviceId = [dict objectForKey:CMBD_NTF_DICT_KEY_DEVICE_ID];
    
    @synchronized(self) {
        if (self.device1 == nil) {
            self.device1 = deviceId;
            self.connection1Label.text = @"Connecting...";
            NSLog(@"Device 1: %@", deviceId);
        }
        else if (self.device2 == nil) {
            self.device2 = deviceId;
            self.connection2Label.text = @"Connecting...";
            NSLog(@"Device 2: %@", deviceId);
        }
        else {
            NSLog(@"[ViewController] warning: more than 2 devices connected!");
        }
    }
}

-(void)handleDisconnected:(NSNotification*)notification {
    NSDictionary *dict = notification.userInfo;
    NSString *deviceId = [dict objectForKey:CMBD_NTF_DICT_KEY_DEVICE_ID];
    
    if (deviceId == nil) {
        NSLog(@"[ViewController] error: null device is disconnected!");
    }
    
    if (self.device1 && [self.device1 isEqualToString:deviceId]) {
        self.device1 = nil;
        self.connection1Label.text = @"Disconnected";
    }
    else if (self.device2 && [self.device2 isEqualToString:deviceId]) {
        self.device2 = nil;
        self.connection2Label.text = @"Disconnected";
    }
    else {
        NSLog(@"[ViewController] error: unknown device disconnected!");
    }
    
}

-(void)handleDeviceReady:(NSNotification*)notification {
    
    NSDictionary *dict = notification.userInfo;
    NSString *deviceId = [dict objectForKey:CMBD_NTF_DICT_KEY_DEVICE_ID];
    
    if (deviceId == self.device1) {
        self.connection1Label.text = @"Connected";
    }
    else if (deviceId == self.device2) {
        self.connection2Label.text = @"Connected";
    }
    else {
        NSLog(@"[ViewController] error: unknown device redy");
    }
}

-(void)receiveActivity:(NSNotification*)notification {
    NSDictionary *dict = notification.userInfo;
    NSString *deviceId = [dict objectForKey:CMBD_NTF_DICT_KEY_DEVICE_ID];
    NSNumber *activity = [dict objectForKey:CMBD_NTF_BW_DICT_KEY_ACTIVITY];
    NSLog(@"activity from device: %@", deviceId);
    
    if (deviceId == self.device1) {
        [self setPlayer1State:activity];
    }
    else if (deviceId == self.device2) {
        [self setPlayer2State:activity];
    }
    else {
        NSLog(@"[ViewController] receive unknown device activity");
    }
}

-(void)receiveGripJSValue:(NSNotification*)notification {
    NSDictionary *dict = notification.userInfo;
    NSString *deviceId = [dict objectForKey:CMBD_NTF_DICT_KEY_DEVICE_ID];
    NSNumber *jsValue = [dict objectForKey:CMBD_NTF_PG_DICT_KEY_JS_VALUE];
    
    if (deviceId == self.device1) {
        [self setPlayer1State:(jsValue.charValue == '1' ? @2 : @0)];
    }
    else if (deviceId == self.device2) {
        [self setPlayer2State:(jsValue.charValue == '1' ? @2 : @0)];
    }
    else {
        NSLog(@"[ViewController] receive unknown device activity");
    }
}

-(void)receiveSteps:(NSNotification*)notification {
    NSDictionary *dict = notification.userInfo;
    NSString *deviceId = [dict objectForKey:CMBD_NTF_DICT_KEY_DEVICE_ID];
    NSNumber *steps = [dict objectForKey:CMBD_NTF_BW_DICT_KEY_STEPS];
    NSLog(@"steps from device: %@", deviceId);
    
    if (deviceId == self.device1) {
        [self setPlayer1Steps:steps];
    }
    else if (deviceId == self.device2) {
        [self setPlayer2Steps:steps];
    }
    else {
        NSLog(@"[ViewController] receive unknown device steps");
    }
}

-(void)receiveEnergy:(NSNotification*)notification {
    NSDictionary *dict = notification.userInfo;
    NSString *deviceId = [dict objectForKey:CMBD_NTF_DICT_KEY_DEVICE_ID];
    NSNumber *energy = [dict objectForKey:CMBD_NTF_BW_DICT_KEY_ENERGY];
    NSLog(@"energy from device: %@", deviceId);
    
    if (deviceId == self.device1) {
        [self setPlayer1Energy:energy];
    }
    else if (deviceId == self.device2) {
        [self setPlayer2Energy:energy];
        
    }
    else {
        NSLog(@"[ViewController] receive unknown device energy");
    }
}

-(void)loadDeviceChooser:(NSArray*)deviceNames deviceIds:(NSArray*)deviceIds {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"DeviceChooserTableViewController" bundle:[NSBundle  mainBundle]];
    DeviceChooserTableViewController *chooserVC = [storyBoard instantiateViewControllerWithIdentifier:@"deviceTable"];
    [chooserVC loadWithDeviceNames:deviceNames deviceIds:deviceIds];
    
    [self.view addSubview:chooserVC.view];
    [self addChildViewController:chooserVC];
}

@end
