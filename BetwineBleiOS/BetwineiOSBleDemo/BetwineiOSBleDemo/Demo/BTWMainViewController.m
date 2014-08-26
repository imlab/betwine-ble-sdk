//
//  BTWMainViewController.m
//  BetwineiOSBleDemo
//
//  Created by imlab_DEV on 14-8-25.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#import "BTWMainViewController.h"
#import "BetwineBleSDK/BetwineBleSDK.h"

@interface BTWMainViewController ()
@property (nonatomic) NSInteger scanBtnStatus;
@end

@implementation BTWMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.scanBtnStatus = 0; // not connected
    
    [self.avatarImgView loadAnimations];
    [self.avatarImgView setAnimationToStatus:BTWAvatarStatus_BREATH];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [self registerBluetoothObserver];
}

-(void)viewDidDisappear:(BOOL)animated {
    [self unregisterBluetoothObserver];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)registerBluetoothObserver {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    // connection handling
    [nc addObserver:self selector:@selector(onDeviceConnectionUpdate:) name:CMBD_CONN_EVT_START_SCAN object:nil];
    [nc addObserver:self selector:@selector(onDeviceConnectionUpdate:) name:CMBD_CONN_EVT_STOP_SCAN object:nil];
    [nc addObserver:self selector:@selector(onDeviceConnectionUpdate:) name:CMBD_CONN_EVT_CONNCETED object:nil];
    [nc addObserver:self selector:@selector(onBetwineAppReady) name:CMBD_EVT_DEVICE_APP_READY object:nil];
    [nc addObserver:self selector:@selector(onBetwineDisconnected) name:CMBD_CONN_EVT_DISCONNECTED object:nil];

    
    // date handling
    [nc addObserver:self selector:@selector(receiveActivity) name:CMBD_EVT_RECEIVE_ACT object:nil];
    [nc addObserver:self selector:@selector(receiveSteps) name:CMBD_EVT_RECEIVE_STEPS object:nil];
    [nc addObserver:self selector:@selector(receiveEnergy) name:CMBD_EVT_RECEIVE_ENERGY object:nil];
    [nc addObserver:self selector:@selector(receiveBattery) name:CMBD_EVT_RECEIVE_BATTERY object:nil];
    [nc addObserver:self selector:@selector(receiveAllStatus) name:CMBD_EVT_RECEIVE_ALL_STATUS object:nil];
    [nc addObserver:self selector:@selector(receiveHistorySteps) name:CMBD_EVT_RECEIVE_HISTORY_STEPS object:nil];
    [nc addObserver:self selector:@selector(receiveDeviceInfo) name:CMBD_EVT_RECEIVE_DEVICE_INFO object:nil];
    [nc addObserver:self selector:@selector(receiveTime) name:CMBD_EVT_RECEIVE_TIME object:nil];
    [nc addObserver:self selector:@selector(receiveLastVibrateTime) name:CMBD_EVT_RECEIVE_LAST_VIBRATE object:nil];
    [nc addObserver:self selector:@selector(receiveActiveMove) name:CMBD_EVT_RECEIVE_ACTIVE_MOVE object:nil];
    
}

-(void)unregisterBluetoothObserver {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc removeObserver:self name:CMBD_CONN_EVT_START_SCAN object:nil];
    [nc removeObserver:self name:CMBD_CONN_EVT_STOP_SCAN object:nil];
    [nc removeObserver:self name:CMBD_EVT_DEVICE_APP_READY object:nil];
    
    [nc removeObserver:self name:CMBD_EVT_RECEIVE_ACT object:nil];
    [nc removeObserver:self name:CMBD_EVT_RECEIVE_STEPS object:nil];
    [nc removeObserver:self name:CMBD_EVT_RECEIVE_ENERGY object:nil];
    [nc removeObserver:self name:CMBD_EVT_RECEIVE_BATTERY object:nil];
    [nc removeObserver:self name:CMBD_EVT_RECEIVE_ALL_STATUS object:nil];
    [nc removeObserver:self name:CMBD_EVT_RECEIVE_DEVICE_INFO object:nil];
    [nc removeObserver:self name:CMBD_EVT_RECEIVE_HISTORY_STEPS object:nil];
    [nc removeObserver:self name:CMBD_CONN_EVT_START_SCAN object:nil];
    [nc removeObserver:self name:CMBD_EVT_RECEIVE_LAST_VIBRATE object:nil];
    [nc removeObserver:self name:CMBD_EVT_RECEIVE_ACTIVE_MOVE object:nil];
    
}

- (IBAction)scanBtnClicked:(id)sender {
    
    switch (self.scanBtnStatus) {
        case 0:
        {
            // scan device
            [[CMBDBleDeviceManager defaultManager] scanBLEDeviceWithType:CMBDConnectorType_BetwineApp];
        }
            break;
        case 1:
        {
            // scanning or connecting, nothing to be done
        }
            break;
        case 2:
        {
            // disconnect device
            CMBDBleDeviceManager *deviceMgr = [CMBDBleDeviceManager defaultManager];
            CMBDBleDevice *device = [deviceMgr getConnectedDeviceByType:CMBDConnectorType_BetwineApp];
            [deviceMgr disconnectDevice:device];
        }
            break;
        default:
            break;
    }
    
}

- (IBAction)pokeBtnClicked:(id)sender {
    BTBetwineAppInterface *betwineApp = (BTBetwineAppInterface*)[[CMBDBleDeviceManager defaultManager] getDeviceInterfaceByType:CMBDConnectorType_BetwineApp];
    
    betwineApp.leds[0] = YES; // motor on
    betwineApp.leds[1] = self.led1Switch.on;
    betwineApp.leds[2] = self.led2Switch.on;
    betwineApp.leds[3] = self.led3Switch.on;
    betwineApp.leds[4] = self.led4Switch.on;
    betwineApp.leds[5] = self.led5Switch.on;
    
    [betwineApp sendVibrateAndLED];
}

- (IBAction)setTimeBtnClicked:(id)sender {
    BTBetwineAppInterface *betwineApp = (BTBetwineAppInterface*)[[CMBDBleDeviceManager defaultManager] getDeviceInterfaceByType:CMBDConnectorType_BetwineApp];
    
    // set system time to badge, and the sitting idle check period from 8:30 to 21:30 (8:30am ~ 9:30pm)
    NSDate *now = [NSDate date];
    [betwineApp sendSetSystemTime:now BeginTime:830 EndTime:2130];
    
    // alert messages
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:now];
    [[[UIAlertView alloc] initWithTitle:@"Set System Time" message:[NSString stringWithFormat:@"Betwine device time has been set to %02d:%02d. Idle check period: %02d:%02d ~ %02d:%02d", components.hour, components.minute, 8, 30, 21, 30] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

-(void)onBetwineAppReady {
    BTBetwineAppInterface *betwineApp = (BTBetwineAppInterface*)[[CMBDBleDeviceManager defaultManager] getDeviceInterfaceByType:CMBDConnectorType_BetwineApp];
    
    [betwineApp sendReadCurrentStatus];
    [betwineApp sendReadDeviceInfo];
    [betwineApp sendReadBattery];
    [betwineApp sendReadStepHistory];
    
    self.scanBtn.enabled = YES;
    [self.scanBtn setTitle:@"Disconnect" forState:UIControlStateNormal];
    self.scanBtnStatus = 2; // connected
    
    self.statusLabel.text = [NSString stringWithFormat:@"Device: %@", betwineApp.bleDevice.uuidString];
    self.setTimeBtn.enabled = YES; // enable set time button
}

-(void)onBetwineDisconnected {
    self.scanBtn.enabled = YES;
    [self.scanBtn setTitle:@"Scan" forState:UIControlStateNormal];
    self.scanBtnStatus = 0; // not connected
    
    // reset fields
    self.setTimeBtn.enabled = NO;
    self.macLabel.text = @"MAC address: N/A";
    self.productId.text = @"Product Id: N/A";
    self.activityLabel.text = @"Activity: N/A";
    self.stepsLabel.text = @"Steps: N/A";
    self.energyLabel.text = @"Energy: N/A";
    self.batteryLabel.text = @"Battery: N/A";
    self.historyStepsLabel.text = @"day 0: N/A\nday 1: N/A\nday 2: N/A\nday 3: N/A\nday 4: N/A\nday 5: N/A\nday 6: N/A";
    self.statusLabel.text = @"Device: N/A";
    [self.avatarImgView setAnimationToStatus:BTWAvatarStatus_BREATH];
    
}

-(void)onDeviceConnectionUpdate:(NSNotification*)notification {
    if ([notification.name isEqualToString:CMBD_CONN_EVT_START_SCAN]) {
        self.scanBtn.enabled = NO;
        [self.scanBtn setTitle:@"Scanning...(wait 5s)" forState:UIControlStateNormal];
        self.scanBtnStatus = 1; // scanning or connecting
    }
    else if ([notification.name isEqualToString:CMBD_CONN_EVT_CONNCETED]) {
        self.scanBtn.enabled = NO;
        [self.scanBtn setTitle:@"Connecting..." forState:UIControlStateNormal];
        self.scanBtnStatus = 1; // scanning or connecting
    }
    else if ([notification.name isEqualToString:CMBD_CONN_EVT_STOP_SCAN]) {
        self.scanBtn.enabled = YES;
        [self.scanBtn setTitle:@"Scan" forState:UIControlStateNormal];
        self.scanBtnStatus = 0; // not connected
    }
}

-(void)receiveSteps {
    BTBetwineAppInterface *betwineApp = (BTBetwineAppInterface*)[[CMBDBleDeviceManager defaultManager] getDeviceInterfaceByType:CMBDConnectorType_BetwineApp];
    
    if (betwineApp) {
        self.stepsLabel.text = [NSString stringWithFormat:@"Steps: %d", (int)betwineApp.steps];
    }
}

-(void)receiveActivity {
    
    BTBetwineAppInterface *betwineApp = (BTBetwineAppInterface*)[[CMBDBleDeviceManager defaultManager] getDeviceInterfaceByType:CMBDConnectorType_BetwineApp];
    
    if (betwineApp) {
        self.activityLabel.text = [NSString stringWithFormat:@"Activity: %d", (int)betwineApp.activity];
        
        if (betwineApp.activity <= 0) {
            
            BTWAvatarStatus status = betwineApp.energy > 3 ? BTWAvatarStatus_BREATH : BTWAvatarStatus_TIRED;
            
            [self.avatarImgView setAnimationToStatus:status];
        }
        else if (betwineApp.activity == 1) {
            
            [self.avatarImgView setAnimationToStatus:BTWAvatarStatus_WALKING];
        }
        else if (betwineApp.activity >= 2) {
            
            [self.avatarImgView setAnimationToStatus:BTWAvatarStatus_RUNNING];
        }
        
        
    }
}

-(void)receiveEnergy {
    
    BTBetwineAppInterface *betwineApp = (BTBetwineAppInterface*)[[CMBDBleDeviceManager defaultManager] getDeviceInterfaceByType:CMBDConnectorType_BetwineApp];
    
    if (betwineApp) {
        self.energyLabel.text = [NSString stringWithFormat:@"Energy: %d", (int)betwineApp.energy];
    }
}

-(void)receiveAllStatus {
    // including energy, steps, activity
    // ... it's not really needed since we already observer energy, steps, activity update separately
}

-(void)receiveHistorySteps {
    
    BTBetwineAppInterface *betwineApp = (BTBetwineAppInterface*)[[CMBDBleDeviceManager defaultManager] getDeviceInterfaceByType:CMBDConnectorType_BetwineApp];
    
    // history steps
    NSInteger *steps = betwineApp.stepHistory;
    NSString *historyStepText = [NSString stringWithFormat:@"day 0: %d\nday 1: %d\nday 2: %d\nday 3: %d\nday 4: %d\nday 5: %d\nday 6:%d", (int)steps[0], (int)steps[1], (int)steps[2], (int)steps[3], (int)steps[4], (int)steps[5], (int)steps[6]];
    
    self.historyStepsLabel.text = historyStepText;
}


-(void)receiveBattery {
    
    BTBetwineAppInterface *betwineApp = (BTBetwineAppInterface*)[[CMBDBleDeviceManager defaultManager] getDeviceInterfaceByType:CMBDConnectorType_BetwineApp];
    
    if (betwineApp) {
        self.batteryLabel.text = [NSString stringWithFormat:@"Battery: %d %@", (int)betwineApp.battery, betwineApp.batteryCharging ? @"(Charging)" : @"(Not Charging)"];
    }
}

-(void)receiveDeviceInfo {
    
    BTBetwineAppInterface *betwineApp = (BTBetwineAppInterface*)[[CMBDBleDeviceManager defaultManager] getDeviceInterfaceByType:CMBDConnectorType_BetwineApp];
    
    if (betwineApp) {
        self.macLabel.text = [NSString stringWithFormat:@"MAC address: %@", betwineApp.bleDevice.macAddr];
        self.productId.text = [NSString stringWithFormat:@"Product Id: %@", betwineApp.bleDevice.productId];
    }
}

-(void)receiveActiveMove {
    // it is used for detect user's acceptance move (for example, to accept a task)
    NSLog(@"[Main] -- user active move detected!");
}


-(void)receiveTime {
    BTBetwineAppInterface *betwineApp = (BTBetwineAppInterface*)[[CMBDBleDeviceManager defaultManager] getDeviceInterfaceByType:CMBDConnectorType_BetwineApp];
    
    NSLog(@"[Main] -- receive device time: %02d:%02d", (int)betwineApp.systemTime / 100, (int)betwineApp.systemTime % 100);
}

-(void)receiveLastVibrateTime {
    
    BTBetwineAppInterface *betwineApp = (BTBetwineAppInterface*)[[CMBDBleDeviceManager defaultManager] getDeviceInterfaceByType:CMBDConnectorType_BetwineApp];
    
    NSLog(@"[Main] -- receive last vib time: %02d:%02d", (int)betwineApp.systemTime / 100, (int)betwineApp.systemTime % 100);
}

@end
