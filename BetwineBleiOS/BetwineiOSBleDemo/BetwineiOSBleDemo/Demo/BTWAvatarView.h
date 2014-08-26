//
//  BTWAvatarView.h
//  BetwineiOSBleDemo
//
//  Created by imlab_DEV on 14-8-25.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BTWAvatarStatus_BREATH = 0,
    BTWAvatarStatus_WALKING = 1,
    BTWAvatarStatus_RUNNING = 2,
    BTWAvatarStatus_TIRED = 3,
} BTWAvatarStatus;

@interface BTWAvatarView : UIImageView

- (void)loadAnimations;
- (void)setAnimationToStatus:(BTWAvatarStatus)status;

@end
