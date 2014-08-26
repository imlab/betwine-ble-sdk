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

#import "BTWAvatarView.h"



@interface BTWAvatarView ()
@property (nonatomic, strong) NSArray *animations;
@end

@implementation BTWAvatarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)loadAnimations {
    NSArray *animationNames = @[@"breath", @"walking", @"running", @"tired"];
    NSMutableArray *animations = [NSMutableArray arrayWithCapacity:animationNames.count];
    
    
    for (NSString *name in animationNames) {
        
        NSArray *frames = [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:[NSString stringWithFormat:@"avatar/%@", name]];

//        NSLog(@"[BTWAvatarView] loading avatar files: %@", frames);
        
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:frames.count];
        
        for (NSString *path in frames) {
            
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            [images addObject:image];
        }
        
        [animations addObject:images];
    }
    
    self.animations = animations;
}

-(void)setAnimationToStatus:(BTWAvatarStatus)status {
    
    NSArray *anim = [self.animations objectAtIndex:(NSUInteger)status];
    
    [self stopAnimating];
    self.image = [anim objectAtIndex:0];

    self.animationImages = anim;
    self.animationDuration = 2;
    self.animationRepeatCount = 0;
    
    [self startAnimating];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
