//
//  SCPaypalExpressAddressReviewViewController.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/22/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SCPaypalExpressAddressReviewViewController.h"

@interface SCPaypalExpressAddressReviewViewController ()
{
    BOOL isBillingAddress;
}
@end

@implementation SCPaypalExpressAddressReviewViewController

@synthesize addressTableView, shippingAddress, billingAddress, paypalModel, updateButton, updateAddressView
;

#pragma mark TableView Datasource

- (void)viewDidLoadBefore
{
    self.navigationItem.title = SCLocalizedString(@"Address Confirmation");
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    
}

- (void)viewDidAppearBefore:(BOOL)animated
{
    if (addressTableView == nil) {
        addressTableView = [[SimiTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        addressTableView.dataSource = self;
        addressTableView.delegate = self;
        addressTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:addressTableView];
        
        [self getAddresses];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (billingAddress == nil) {
        return 0;
    }
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section < 2) {
        UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 25)];
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
        UILabel * name = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 280, 15)];
        [name setTextColor:[UIColor grayColor]];
        name.font = [UIFont systemFontOfSize:14];
        [name setText:title];
        [headerView addSubview:name];
        return headerView;
    }
    else return [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section < 2) {
        return 40;
    }
    return 1;
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
        float padding = 20;
        UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding, 0, SCREEN_WIDTH - padding*3, 120)];
        [addressLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:15]];
        [addressLabel setTextColor:THEME_CONTENT_COLOR];
        [addressLabel setNumberOfLines:0];
        [addressLabel setText:[address formatAddress]];
        [cell addSubview:addressLabel];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 2) {
        if (updateAddressView == nil) {
            updateAddressView = [[UIView alloc]init];
            float cellWidth = SCREEN_WIDTH;
            if (PADDEVICE) {
                cellWidth = 2*SCREEN_WIDTH/3;
            }
            updateAddressView.frame = CGRectMake(0, 0, cellWidth, 40);
            updateButton = [[UIButton alloc]initWithFrame:CGRectMake(50, 0, cellWidth - 100, 40)];
            [updateButton setBackgroundColor:THEME_BUTTON_BACKGROUND_COLOR];
            updateButton.tintColor = THEME_BUTTON_TEXT_COLOR;
            [updateButton setTitle:SCLocalizedString(@"Confirm Address") forState:UIControlStateNormal];
            [updateButton.layer setCornerRadius:5.0f];
            [updateButton addTarget:self action:@selector(updateAddressInformation:) forControlEvents:UIControlEventTouchUpInside];
            [updateAddressView addSubview:updateButton];
            UIButton * hidingButton = [[UIButton alloc]initWithFrame:updateAddressView.frame];
            [hidingButton addTarget:self action:@selector(updateAddressInformation:) forControlEvents:UIControlEventTouchUpInside];
            [updateAddressView addSubview:hidingButton];
        }
        [updateAddressView bringSubviewToFront:updateButton];
        [cell addSubview:updateAddressView];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < 2) {
        SCPaypalExpressAddressEditViewController *nextController = [[SCPaypalExpressAddressEditViewController alloc]init];
        nextController.delegate = self;
        SimiAddressModel *address;
        if (indexPath.section == 0)
        {
            address = billingAddress;
            isBillingAddress = YES;
        }
        else
        {
            address = shippingAddress;
            isBillingAddress = NO;
        }
        
        nextController.address = address;
        nextController.isEditing = YES;
        [self.navigationController pushViewController:nextController animated:YES];
    }
}

#pragma mark Get Address
-(void)getAddresses
{
    [self startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetPaypalAdressInformation:) name:@"DidGetPaypalAdressInformation" object:nil];
    paypalModel = [SCPaypalExpressModel new];
    [paypalModel reviewAddress];
}

- (void)didGetPaypalAdressInformation: (NSNotification *)noti
{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        billingAddress = [SimiAddressModel new];
        [billingAddress addEntriesFromDictionary:[paypalModel objectForKey:@"billing_address"]];
        shippingAddress = [SimiAddressModel new];
        [shippingAddress addEntriesFromDictionary:[paypalModel objectForKey:@"shipping_address"]];
        [addressTableView reloadData];
    }
    else {
        UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"" message:responder.responseMessage delegate:self cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [a show];
    }
}

#pragma mark Update Address Information

- (void)updateAddressInformation :(id)sender
{
    [self startLoadingData];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:shippingAddress forKey:@"s_address"];
    [params setValue:billingAddress forKey:@"b_address"];
    [params setValue:[billingAddress valueForKey:@"customer_password"] forKey:@"customer_password"];
    [params setValue:[billingAddress valueForKey:@"confirm_password"] forKey:@"confirm_password"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paypalDidCompleteReviewAddress:) name:@"DidUpdatePaypalCheckoutAddress" object:nil];
    [paypalModel updateAddressWithParam:params];
}

-(void)paypalDidCompleteReviewAddress:(NSNotification *)noti
{
    
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    [self removeObserverForNotification:noti];
    [self stopLoadingData];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        SCPaypalExpressShippingMethodViewController *shippingMethodViewController = [[SCPaypalExpressShippingMethodViewController alloc]init];
        [self.navigationController pushViewController:shippingMethodViewController animated:NO];
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:responder.responseMessage delegate:self cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alert show];
    }
}
#pragma  mark Edit Adress
- (void)didSaveAddress:(SimiAddressModel *)address
{
    if (isBillingAddress) {
        billingAddress = address;
    }else
        shippingAddress = address;
    [addressTableView reloadData];
}

@end
