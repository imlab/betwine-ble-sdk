//
//  Created by imlab_DEV on 14-8-25.
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
