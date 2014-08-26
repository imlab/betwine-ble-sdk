//
//  BTWMainViewController.h
//  BetwineiOSBleDemo
//
//  Created by imlab_DEV on 14-8-25.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTWAvatarView.h"

@interface BTWMainViewController : UIViewController

@property (weak, nonatomic) IBOutlet BTWAvatarView *avatarImgView;

@property (weak, nonatomic) IBOutlet UILabel *macLabel;
@property (weak, nonatomic) IBOutlet UILabel *productId;

@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UILabel *energyLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;
@property (weak, nonatomic) IBOutlet UILabel *historyStepsLabel;

@property (weak, nonatomic) IBOutlet UISwitch *led1Switch;
@property (weak, nonatomic) IBOutlet UISwitch *led2Switch;
@property (weak, nonatomic) IBOutlet UISwitch *led3Switch;
@property (weak, nonatomic) IBOutlet UISwitch *led4Switch;
@property (weak, nonatomic) IBOutlet UISwitch *led5Switch;

@property (weak, nonatomic) IBOutlet UIButton *pokeBtn;
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
@property (weak, nonatomic) IBOutlet UIButton *setTimeBtn;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;


@end
