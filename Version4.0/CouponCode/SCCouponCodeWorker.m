//
//  SCCouponCodeWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 9/12/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCCouponCodeWorker.h"
#import <SimiCartBundle/SCCartViewController.h>
#import <SimiCartBundle/SCOrderViewControllerPad.h>

#define CART_COUPONCODE_ROW @"CART_COUPONCODE_ROW"
#define ORDER_VIEW_COUPONCODE @"ORDER_VIEW_COUPONCODE"


@implementation SCCouponCodeWorker {
    SimiTextField *cartCouponTextField;
    SimiTextField *orderCouponTextField;
    SCCartViewController *cartVC;
    SCOrderViewController *orderVC;
}
- (id)init {
    if(self == [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initCartCellAfter:) name:InitCartCellAfter object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedCartCellAfter:) name:InitializedCartCellAfter object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderViewControllerInitTableAfter:) name:SCOrderViewControllerInitTableAfter object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderViewControllerInitRightTableAfter:) name:SCOrderViewControllerInitRightTableAfter object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedOrderCellAfter:) name:InitializedOrderCellAfter object:nil];
    }
    return self;
}

- (void)initCartCellAfter: (NSNotification *)noti {
    SimiTable *cartCells = noti.object;
    SimiSection *priceSection = [cartCells getSectionByIdentifier:CART_TOTALS];
    [priceSection addRowWithIdentifier:CART_COUPONCODE_ROW height:64 sortOrder:1000];
}

- (void)initializedCartCellAfter: (NSNotification *)noti {
    SimiSection *section = [noti.userInfo objectForKey:@"section"];
    SimiRow *row = [noti.userInfo objectForKey:@"row"];
    UITableView *cartTableView = [noti.userInfo objectForKey:@"tableView"];
    UITableViewCell *cell = [noti.userInfo objectForKey:@"cell"];
    cartVC = noti.object;
    if([section.identifier isEqualToString:CART_TOTALS]) {
        if([row.identifier isEqualToString:CART_COUPONCODE_ROW]) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGRect frame = CGRectMake(15, 10, CGRectGetWidth(cartTableView.frame) - 30 - 130, 44);
            cartCouponTextField = [[SimiTextField alloc] initWithFrame:frame placeHolder:@"Enter a coupon code" font:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR backgroundColor:COLOR_WITH_HEX(@"#e8e8e8") borderWidth:0 borderColor:[UIColor clearColor] paddingLeft:10];
            cartCouponTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            cartCouponTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cartCouponTextField.delegate = self;
            [cartCouponTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
            
            SimiButton *applyCouponCodeButton = [[SimiButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(cartTableView.frame) - 15 - 120, 10, 120, 44)];
            [applyCouponCodeButton setTitle:SCLocalizedString(@"Apply") forState:UIControlStateNormal];
            [applyCouponCodeButton addTarget:self action:@selector(applyCouponOnCartView:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell addSubview:cartCouponTextField];
            [cell addSubview:applyCouponCodeButton];
        }
        if([[SimiGlobalVar sharedInstance].cart.priceData valueForKey:@"coupon_code"])
        {
            [cartCouponTextField setText:[[SimiGlobalVar sharedInstance].cart.priceData valueForKey:@"coupon_code"]];
        }else
            [cartCouponTextField setText:@""];
    }
}


- (void)didSetCouponCodeOnCartView:(NSNotification *)noti{
    [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"cart_action" userInfo:@{@"action":@"apply_coupon_code",@"coupon_code":cartCouponTextField.text}];
    
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    [cartVC showToastMessage:responder.responseMessage];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [cartVC changeCartData:noti];
    }
    [cartVC stopLoadingData];
    [self removeObserverForNotification:noti];
}

- (void)applyCouponOnCartView:(UIButton*)sender
{
    NSString *couponCode = @"";
    couponCode = cartCouponTextField.text;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSetCouponCodeOnCartView:) name:DidSetCouponCode object:[SimiGlobalVar sharedInstance].cart];
    [[SimiGlobalVar sharedInstance].cart setCouponCode:couponCode];
    [cartVC startLoadingData];
}

- (void)orderViewControllerInitTableAfter:(NSNotification *)noti {
    SimiTable *orderCells = noti.object;
    SimiSection *totalSection = [orderCells getSectionByIdentifier:ORDER_TOTALS_SECTION];
    SimiRow *couponRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_COUPONCODE height:64 sortOrder:1000];
    [totalSection addRow:couponRow];
}

- (void)orderViewControllerInitRightTableAfter:(NSNotification *)noti {
    SimiTable *orderCells = noti.object;
    SimiSection *totalSection = [orderCells getSectionByIdentifier:ORDER_TOTALS_SECTION];
    SimiRow *couponRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_COUPONCODE height:64 sortOrder:1000];
    [totalSection addRow:couponRow];
}

- (void)initializedOrderCellAfter: (NSNotification *)noti {
    UITableViewCell *cell = [noti.userInfo objectForKey:@"cell"];
    UITableView *tableView = [noti.userInfo objectForKey:@"tableView"];
    SimiRow *row = [noti.userInfo objectForKey:@"row"];
    orderVC = noti.object;
    if([row.identifier isEqualToString:ORDER_VIEW_COUPONCODE]){
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGRect frame = CGRectMake(15, 10, CGRectGetWidth(tableView.frame) - 30 - 130, 44);
        orderCouponTextField = [[SimiTextField alloc] initWithFrame:frame placeHolder:@"Enter a coupon code" font:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR backgroundColor:COLOR_WITH_HEX(@"#e8e8e8") borderWidth:0 borderColor:[UIColor clearColor] paddingLeft:10];
        orderCouponTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        orderCouponTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        orderCouponTextField.delegate = self;
        [orderCouponTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        
        SimiButton *applyCouponCodeButton = [[SimiButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(tableView.frame) - 15 - 120, 10, 120, 44)];
        [applyCouponCodeButton setTitle:SCLocalizedString(@"Apply") forState:UIControlStateNormal];
        [applyCouponCodeButton addTarget:self action:@selector(applyCouponOnOrderView:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:orderCouponTextField];
        [cell addSubview:applyCouponCodeButton];
        if([orderVC.totalData valueForKey:@"coupon_code"])
        {
            [orderCouponTextField setText:[orderVC.totalData valueForKey:@"coupon_code"]];
        }else
            [orderCouponTextField setText:@""];
    }
}

- (void)didSetCouponCodeOnOrderView:(NSNotification *)noti {
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    [orderVC showToastMessage:responder.responseMessage];
    [orderVC didGetOrderConfig:noti];
}

- (void)applyCouponOnOrderView:(UIButton*)sender {
    NSString *couponCode = @"";
    couponCode = orderCouponTextField.text;
    [orderVC trackingWithProperties:@{@"action":@"apply_coupon_code",@"coupon_code":couponCode}];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSetCouponCodeOnOrderView:) name:DidSetCouponCode object:nil];
    [orderVC.order setCouponCode:couponCode];
    [orderVC startLoadingData];
}

@end
