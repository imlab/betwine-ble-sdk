//
//  BTWViewController.m
//  BetwineiOSBleDemo
//
//  Created by imlab_DEV on 14-8-20.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#import "BTWViewController.h"
#import "BetwineBleSDK/BetwineBleSDK.h"

@interface BTWViewController ()

@end

@implementation BTWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

-(void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterMainView) name:CMBD_EVT_CENTRAL_MGR_BECOME_AVAILABLE object:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CMBD_EVT_CENTRAL_MGR_BECOME_AVAILABLE object:nil];
}

-(void)enterMainView {
    [self performSegueWithIdentifier:@"enterMainView" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
