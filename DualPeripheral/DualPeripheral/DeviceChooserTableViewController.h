//
//  DeviceChooserTableViewController.h
//  DualPeripheral
//
//  Created by imlab_DEV on 14-10-30.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;

@end


@interface DeviceChooserTableViewController : UITableViewController <UITableViewDataSource, UITableViewDataSource>

-(void)loadWithDeviceNames:(NSArray *)deviceNames deviceIds:(NSArray*)deviceIds;
-(void)connectSelectedDevices;

@end
