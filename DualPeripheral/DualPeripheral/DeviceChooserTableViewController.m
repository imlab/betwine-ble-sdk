//
//  DeviceChooserTableViewController.m
//  DualPeripheral
//
//  Created by imlab_DEV on 14-10-30.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#import "DeviceChooserTableViewController.h"
#import "CMBDBleDeviceManager.h"

@implementation DeviceTableCell

@end

@interface DeviceChooserTableViewController ()
@property NSArray *deviceNames;
@property NSArray *deviceIds;
@property (nonatomic) UIButton *footerBtn;
@property NSMutableArray *selected;

@end

@implementation DeviceChooserTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.view.layer.borderColor = [UIColor blackColor].CGColor;
    self.view.layer.borderWidth = 1.0f;
    
    self.footerBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.footerBtn setTitle:@"OK" forState:UIControlStateNormal];
    self.footerBtn.layer.borderColor = [UIColor blackColor].CGColor;
    self.footerBtn.layer.borderWidth = 1.0f;
    
    [self.footerBtn addTarget:self action:@selector(footerBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.selected = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void)loadWithDeviceNames:(NSArray *)deviceNames deviceIds:(NSArray*)deviceIds
{
    self.deviceNames = deviceNames;
    self.deviceIds = deviceIds;
    [self.tableView reloadData];
    
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.view.frame = CGRectMake(0, 0, 240, 54 + (self.deviceNames.count > 6 ? 186 : self.deviceNames.count * 32));
    if( NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 ) {
        self.view.center = CGPointMake(screenSize.width / 2, screenSize.height / 2);
    }
    else {
        self.view.center = CGPointMake(screenSize.height / 2, screenSize.width / 2);
    }
    
}

-(void)connectSelectedDevices
{
    CMBDBleDeviceManager *mgr = [CMBDBleDeviceManager defaultManager];
    for (NSString *deviceId in self.selected) {
        [mgr connectDeviceWithDeviceId:deviceId];
    }
}

-(void)footerBtnClicked
{
    NSLog(@"Connect selected devices: %@", self.selected);
    
    [self connectSelectedDevices];
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceNames ? self.deviceNames.count : 0;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Please select devices...";
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return self.footerBtn;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceCell" forIndexPath:indexPath];
//    CMBDBleDevice *device = [self.devices objectAtIndex:indexPath.row];
    NSString *deviceName = [self.deviceNames objectAtIndex:indexPath.row];
    cell.label.text = [NSString stringWithFormat:@"%@", deviceName];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    [self.selected addObject:[self.deviceIds objectAtIndex:indexPath.row]];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.selected removeObject:[self.deviceIds objectAtIndex:indexPath.row]];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
