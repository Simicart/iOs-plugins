//
//  SCPaypalExpressAddressReviewViewController.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/22/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SCPaypalExpressAddressReviewViewController.h"
#import "SCPaypalExpressAddressEditViewController.h"

#define ADDRESS_TABLE_VIEW_HEIGHT 500
#define SECTION_HEIGHT 50
#define ROW_HEIGHT 150
#define ADDRESS_CELL_HEIGHT 200
#define BUTTON_WIDTH 250
#define BUTTON_HEIGHT 40
#define BUTTON_DISTANCE_FROM_TOP 0
#define BUTTON_ROUND_CORNER 5.0f
#define HEADER_HEIGHT 25
#define HEADER_LABEL_DISTANCE_FROM_TOP 5
#define HEADER_LABEL_HEIGHT 15
#define HEADER_LABEL_HORIZONTAL_ALIGN 20

@interface SCPaypalExpressAddressReviewViewController ()

@end

@implementation SCPaypalExpressAddressReviewViewController
{
    UIButton * updateButton;
    UIView * updateAddressView;
}

@synthesize addressTableView, shippingAddress, billingAddress, paypalModelCollection, paypalModel
;

- (void)viewDidLoadAfter {
    [super viewDidLoadAfter];
    self.title = SCLocalizedString(@"Address Confirmation");
    addressTableView = [[SimiTableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStyleGrouped];
    addressTableView.dataSource = self;
    addressTableView.delegate = self;
    addressTableView.frame = CGRectMake(0, 15, SCREEN_WIDTH, SCREEN_HEIGHT);
    addressTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:addressTableView];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [addressTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section < 2) {
        UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, HEADER_HEIGHT)];
        NSString * title = @"";
        switch (section) {
            case 0:
                title = SCLocalizedString(@"Billing Address");
                break;
            case 1:
                title = SCLocalizedString(@"Shipping Address");
                break;
            default:
                break;
        }
        UILabel * name = [[UILabel alloc]initWithFrame:CGRectMake(HEADER_LABEL_HORIZONTAL_ALIGN, HEADER_LABEL_DISTANCE_FROM_TOP, SCREEN_WIDTH - HEADER_LABEL_HORIZONTAL_ALIGN *2, HEADER_LABEL_HEIGHT )];
        [name setTextColor:[UIColor grayColor]];
        name.font = [UIFont systemFontOfSize:14];
        [name setText:title];
        [headerView addSubview:name];
        return headerView;
    }
    else return [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    if (section<2) {
        return HEADER_HEIGHT;
    }
    return 1;
}
 /*

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString * title = @"";
    switch (section) {
        case 0:
            title = SCLocalizedString(@"Billing Address");
            break;
        case 1:
            title = SCLocalizedString(@"Shipping Address");
            break;
        default:
            break;
    }
    return title;
}

*/

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (IBAction)updateAddressInformation :(id)sender
{
    [self startLoadingData];
    if (paypalModel == nil) {
        paypalModel = [[SCPaypalExpressModel alloc] init];
    }
    if (paypalModelCollection == nil) {
        paypalModelCollection = [[SCPaypalExpressModelCollection alloc] init];
    }
    if (shippingAddress != nil && billingAddress != nil) {
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:shippingAddress forKey:@"shippingAddress"];
        [params setValue:billingAddress forKey:@"billingAddress"];
        [params setValue:[billingAddress valueForKey:@"customer_password"] forKey:@"customer_password"];
        [params setValue:[billingAddress valueForKey:@"confirm_password"] forKey:@"confirm_password"];
        [paypalModelCollection updateAddressWithParam:params];
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddressCell"];
    
    if (indexPath.section < 2) {
        SimiAddressModel *address;
        if (indexPath.section == 0)
            address = billingAddress;
        else
            address = shippingAddress;
        
        cell.textLabel.text = [address formatAddress];
        CGSize labelSize = [cell.textLabel.text sizeWithFont:cell.textLabel.font
                                           constrainedToSize:cell.textLabel.frame.size
                                               lineBreakMode:cell.textLabel.lineBreakMode];
        cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, 320.0f, labelSize.height);
        cell.textLabel.numberOfLines = 0;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 2) {
        if (updateAddressView == nil) {
            updateAddressView = [[UIView alloc]init];
            updateAddressView.frame = CGRectMake(0, 0, SCREEN_WIDTH, BUTTON_HEIGHT + BUTTON_DISTANCE_FROM_TOP *2);
            updateButton = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-BUTTON_WIDTH)/2,BUTTON_DISTANCE_FROM_TOP , BUTTON_WIDTH, BUTTON_HEIGHT)];
            [updateButton setBackgroundColor:THEME_COLOR];
            [updateButton setTitle:SCLocalizedString(@"Confirm Address") forState:UIControlStateNormal];
            [updateButton.layer setCornerRadius:BUTTON_ROUND_CORNER];
            [updateButton addTarget:self action:@selector(updateAddressInformation:) forControlEvents:UIControlEventTouchUpInside];
            [updateAddressView addSubview:updateButton];
            UIButton * hidingButton = [[UIButton alloc]initWithFrame:updateAddressView.frame];
            [hidingButton addTarget:self action:@selector(updateAddressInformation:) forControlEvents:UIControlEventTouchUpInside];
            [updateAddressView addSubview:hidingButton];
        }
        [updateAddressView bringSubviewToFront:updateButton];
        [cell addSubview:updateAddressView];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.frame = CGRectMake(0, 0, SCREEN_WIDTH, BUTTON_HEIGHT + BUTTON_DISTANCE_FROM_TOP);
    }
    
    return cell;
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section < 2) {
        SCPaypalExpressAddressEditViewController *nextController = [[SCPaypalExpressAddressEditViewController alloc]init];
        SimiAddressModel *address;
        if (indexPath.section == 0)
            address = billingAddress;
        else
            address = shippingAddress;
        
        nextController.address = address;
        nextController.isEditing = YES;
        [self.navigationController pushViewController:nextController animated:YES];
        UIBarButtonItem *button = [[UIBarButtonItem alloc]initWithTitle:SCLocalizedString(@"Save") style:UIBarButtonItemStyleDone target:self action:@selector(saveAddress)];
        self.navigationItem.rightBarButtonItem = button;
    }
}



@end
