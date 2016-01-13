//
//  SCPaypalExpressShippingMethodViewController.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/22/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SCPaypalExpressShippingMethodViewController.h"
#import <SimiCartBundle/SimiShippingModel.h>
#import <SimiCartBundle/SimiFormatter.h>

#define ADDRESS_TABLE_VIEW_HEIGHT 500
#define ROW_HEIGHT 40
#define ROW_MARGIN 5
#define ROW_LEFT_ALIGN 10
#define ADDRESS_CELL_HEIGHT 200
#define BUTTON_WIDTH 250
#define BUTTON_HEIGHT 40
#define BUTTON_DISTANCE_FROM_TOP 5
#define BUTTON_ROUND_CORNER 5.0f
#define PRICE_LABEL_WIDTH 150
#define CHECKBOX_AREA_WIDTH 40

@interface SCPaypalExpressShippingMethodViewController ()


@end

@implementation SCPaypalExpressShippingMethodViewController
{
    UIView * placeOrderView;
    UIButton * placeOrderButton;
    NSIndexPath * checkedData;
}
@synthesize paypalModel, shippingMethodTableView, paypalModelCollection
;

- (void)viewDidLoadAfter {
    [super viewDidLoadAfter];
    
    self.title = SCLocalizedString(@"Shipping Method");
    
    shippingMethodTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    shippingMethodTableView.dataSource = self;
    shippingMethodTableView.delegate = self;
    shippingMethodTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    shippingMethodTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:shippingMethodTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [paypalModelCollection count];
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
    if (indexPath.section < 2) {
        return ROW_HEIGHT;
    }
    return BUTTON_HEIGHT;
}


- (IBAction)placeOrder :(id)sender
{
    [self startLoadingData];
    
    if (paypalModel == nil) {
        paypalModel = [[SCPaypalExpressModel alloc]init];
    }
    
    SimiShippingModel *method = [[SimiShippingModel alloc]init];
    SCPaypalExpressModel *selected;
    if (checkedData == nil) {
        selected = [paypalModelCollection objectAtIndex:0];
    }
    else {
        selected = [paypalModelCollection objectAtIndex:checkedData.row];
    }
    [method setValue:[selected objectForKey:@"s_method_code"] forKey:@"shipping_method"];
    for (NSString * key in selected) {
        [method setValue:[selected objectForKey:key] forKey:key];
    }
    
    [paypalModel placeOrderWithParam:method];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceOrder) name:@"DidPlaceOrder-After" object:nil];
}

- (void)didPlaceOrder
{
    [self stopLoadingData];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
   }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ROW_HEIGHT)];
    if ((checkedData.row != indexPath.row)||(checkedData.section != indexPath.section))
        cell.accessoryType = UITableViewCellAccessoryNone;
    else
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    if (paypalModelCollection!=nil) {
        if (indexPath.section == 0) {
            
            UILabel * methodName = [[UILabel alloc]initWithFrame:CGRectMake(ROW_LEFT_ALIGN, ROW_MARGIN, SCREEN_WIDTH *2/3 , ROW_HEIGHT - 2*ROW_MARGIN)];
            UILabel * methodPrice = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH -  ROW_LEFT_ALIGN - PRICE_LABEL_WIDTH - CHECKBOX_AREA_WIDTH , ROW_MARGIN, PRICE_LABEL_WIDTH , ROW_HEIGHT - 2*ROW_MARGIN)];
            [methodPrice setTextColor:[UIColor redColor]];
            [methodName setText: [(SCPaypalExpressModel *)[paypalModelCollection objectAtIndex:indexPath.row] objectForKey:@"s_method_title"]];
            NSNumber * fee = (NSNumber *)[(SCPaypalExpressModel *)[paypalModelCollection objectAtIndex:indexPath.row] objectForKey:@"s_method_fee"];
            NSString * price = [[SimiFormatter sharedInstance] priceByLocalizeNumber:fee] ;
            [methodPrice setText:price];
            [methodPrice setTextAlignment:NSTextAlignmentRight];
            
            [cell addSubview:methodName];
            [cell addSubview:methodPrice];
        }
        else {
            if (placeOrderView == nil) {
                placeOrderView = [[UIView alloc]init];
                placeOrderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, BUTTON_WIDTH *2);
                placeOrderButton = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-BUTTON_WIDTH)/2,BUTTON_DISTANCE_FROM_TOP , BUTTON_WIDTH, BUTTON_HEIGHT)];
                [placeOrderButton setBackgroundColor:THEME_COLOR];
                [placeOrderButton setTitle:SCLocalizedString(@"Place Order") forState:UIControlStateNormal];
                [placeOrderButton.layer setCornerRadius:BUTTON_ROUND_CORNER];
                [placeOrderButton addTarget:self action:@selector(placeOrder:) forControlEvents:UIControlEventTouchUpInside];
                [placeOrderView addSubview:placeOrderButton];
                UIButton * hidingButton = [[UIButton alloc]initWithFrame:placeOrderView.frame];
                [hidingButton addTarget:self action:@selector(placeOrder:) forControlEvents:UIControlEventTouchUpInside];
                [placeOrderView addSubview:hidingButton];
            }
            [placeOrderView bringSubviewToFront:placeOrderButton];
            [cell addSubview:placeOrderView];
            [cell setBackgroundColor:[UIColor clearColor]];
        }
    }
    return cell;

}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DidPlaceOrder-After" object:nil];
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        checkedData = indexPath;
        [tableView reloadData];
    }

}


@end
