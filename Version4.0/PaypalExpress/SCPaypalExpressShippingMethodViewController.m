//
//  SCPaypalExpressShippingMethodViewController.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/22/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SCPaypalExpressShippingMethodViewController.h"
#import <SimiCartBundle/SimiFormatter.h>
#import <SimiCartBundle/SCCartViewControllerPad.h>
#import <SimiCartBundle/SCThemeWorker.h>

@interface SCPaypalExpressShippingMethodViewController ()
{
    NSMutableArray *listShippingMethods;
}
@end

@implementation SCPaypalExpressShippingMethodViewController
{
    UIButton * placeOrderButton;
    NSIndexPath * checkedData;
}
@synthesize paypalModel,paypalShippingModel,shippingMethodTableView;


- (void)viewDidLoadBefore
{
    self.navigationItem.title = SCLocalizedString(@"Shipping Method");
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    
}

- (void)viewDidAppearBefore:(BOOL)animated
{
    if (shippingMethodTableView == nil) {
        shippingMethodTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        shippingMethodTableView.dataSource = self;
        shippingMethodTableView.delegate = self;
        shippingMethodTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:shippingMethodTableView];
        [self getShippingMethod];
    }
}

#pragma mark Get Shipping Methods
- (void)getShippingMethod
{
    [self startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetShippingMethods:) name:@"DidGetPaypalCheckoutShippingMethods" object:nil];
    paypalShippingModel = [SCPaypalExpressModel new];
    [paypalShippingModel getShippingMethods];
}

- (void)didGetShippingMethods:(NSNotification *)noti {
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    [self removeObserverForNotification:noti];
    [self stopLoadingData];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        listShippingMethods = [[NSMutableArray alloc]initWithArray:[paypalShippingModel valueForKey:@"methods"]];
        for(int i = 0; i < listShippingMethods.count; i++) {
            SimiModel *shippingMethod = [listShippingMethods objectAtIndex:i];
            if([[shippingMethod objectForKey:@"s_method_selected"] boolValue]) {
                checkedData = [NSIndexPath indexPathForRow:i inSection:0];
            }
        }
        [shippingMethodTableView reloadData];
    } else {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:SCLocalizedString(@"Error") message:responder.responseMessage delegate:self cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(listShippingMethods == nil)
        return 0;
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [listShippingMethods count];
    }
    return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString * title = @"";
    switch (section) {
        case 0:
            title = SCLocalizedString(@"Please select shipping method");
            break;
        default:
            break;
    }
    return title;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    if ((checkedData.row != indexPath.row)||(checkedData.section != indexPath.section))
        cell.accessoryType = UITableViewCellAccessoryNone;
    else
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    if (listShippingMethods != nil) {
        if (indexPath.section == 0) {
            UILabel * methodName = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, CGRectGetWidth(self.view.frame)*2/3, 30)];
            [methodName setFont:[UIFont fontWithName:THEME_FONT_NAME size:14]];
            [methodName setTextColor:THEME_CONTENT_COLOR];
            UILabel * methodPrice = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) -  170 , 5, 120 , 30)];
            [methodPrice setFont:[UIFont fontWithName:THEME_FONT_NAME size:14]];
            [methodPrice setTextColor:THEME_PRICE_COLOR];
            
            SimiModel *shippingMethodModel = [listShippingMethods objectAtIndex:indexPath.row];
            [methodName setText: [NSString stringWithFormat:@"%@",[shippingMethodModel objectForKey:@"s_method_title"]]];
            NSString *fee = [NSString stringWithFormat:@"%@",[shippingMethodModel objectForKey:@"s_method_fee"]];
            NSString * price = [[SimiFormatter sharedInstance] priceWithPrice:fee];
            [methodPrice setText:price];
            [methodPrice setTextAlignment:NSTextAlignmentRight];
            
            [cell addSubview:methodName];
            [cell addSubview:methodPrice];
        }
        else {
            if (placeOrderButton == nil) {
                float cellWidth = SCREEN_WIDTH;
                if (PADDEVICE) {
                    cellWidth = 2*SCREEN_WIDTH/3;
                }
                placeOrderButton = [[UIButton alloc]initWithFrame:CGRectMake(50 , 5 , cellWidth - 100, 40)];
                [placeOrderButton setBackgroundColor:THEME_BUTTON_BACKGROUND_COLOR];
                placeOrderButton.tintColor = THEME_BUTTON_TEXT_COLOR;
                [placeOrderButton setTitle:SCLocalizedString(@"Place Order") forState:UIControlStateNormal];
                [placeOrderButton.layer setCornerRadius:5.0f];
                [placeOrderButton addTarget:self action:@selector(placeOrder:) forControlEvents:UIControlEventTouchUpInside];
            }
            [cell addSubview:placeOrderButton];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
    }
    return cell;

}


#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        checkedData = indexPath;
        [tableView reloadData];
    }
}

#pragma mark Place Order
- (void)placeOrder :(id)sender
{
    [self startLoadingData];
    
    if (paypalModel == nil) {
        paypalModel = [[SCPaypalExpressModel alloc]init];
    }
    
    SCPaypalExpressModel *selected;
    if (checkedData == nil) {
        selected = [listShippingMethods objectAtIndex:0];
    }
    else {
        selected = [listShippingMethods objectAtIndex:checkedData.row];
    }
    SimiModel *method = [SimiModel new];
    [method setValue:@{@"method":[NSString stringWithFormat:@"%@",[selected objectForKey:@"s_method_code"]]}forKey:@"s_method"];
    [paypalModel placeOrderWithParam:method];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceOrder:) name:@"PaypalExpressDidPlaceOrder" object:nil];
}

- (void)didPlaceOrder:(NSNotification *)noti
{
    [self stopLoadingData];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if (PHONEDEVICE) {
        SCCartViewController * cartVC = [[SCThemeWorker sharedInstance].navigationBarPhone cartViewController];
        [cartVC getCart];
    }else
    {
        SCCartViewControllerPad * cartVC = [[SCThemeWorker sharedInstance].navigationBarPad cartViewControllerPad];
        [cartVC getCart];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:SCLocalizedString(@"Thank you for your purchase") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:responder.responseMessage delegate:self cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alert show];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DidCompleteCheckOutWithPaypalExpress" object:paypalModel];
}
@end
