//
//  ViewController.h
//  DualPeripheral
//
//  Created by imlab_DEV on 14-10-30.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTWAvatarView.h"
#import "BetwineBleSDK.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet BTWAvatarView *avatar1View;
@property (weak, nonatomic) IBOutlet BTWAvatarView *avatar2View;
@property (weak, nonatomic) IBOutlet UILabel *connection1Label;
@property (weak, nonatomic) IBOutlet UILabel *connection2Label;
@property (weak, nonatomic) IBOutlet UILabel *state1Label;
@property (weak, nonatomic) IBOutlet UILabel *energy1Label;
@property (weak, nonatomic) IBOutlet UILabel *steps1Label;
@property (weak, nonatomic) IBOutlet UILabel *state2Label;
@property (weak, nonatomic) IBOutlet UILabel *energy2Label;
@property (weak, nonatomic) IBOutlet UILabel *steps2Label;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bluetoothActivity;


@end

