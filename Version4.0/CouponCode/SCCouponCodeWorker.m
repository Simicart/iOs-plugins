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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initCartCellAfter:) name:[NSString stringWithFormat:@"%@%@",SCCartViewController_RootEventName,SimiTableViewController_SubKey_InitCells_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedCartCellBefore:) name:[NSString stringWithFormat:@"%@%@",SCCartViewController_RootEventName,SimiTableViewController_SubKey_InitializedCell_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderViewControllerInitTableAfter:) name:[NSString stringWithFormat:@"%@%@",SCOrderViewController_RootEventName,SimiTableViewController_SubKey_InitCells_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderViewControllerInitRightTableAfter:) name:[NSString stringWithFormat:@"%@%@",SCOrderViewController_RootEventName,SimiTableViewController_SubKey_InitMoreCells_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedOrderCellBefore:) name:[NSString stringWithFormat:@"%@%@",SCOrderViewController_RootEventName,SimiTableViewController_SubKey_InitializedCell_End] object:nil];
    }
    return self;
}

- (void)initCartCellAfter: (NSNotification *)noti {
    SimiTable *cartCells = noti.object;
    SimiSection *priceSection = [cartCells getSectionByIdentifier:CART_TOTALS];
    SimiRow *totalRow = [priceSection getRowByIdentifier:CART_TOTALS_ROW];
    [priceSection addRowWithIdentifier:CART_COUPONCODE_ROW height:64 sortOrder:totalRow.sortOrder + 1];
}

- (void)initializedCartCellBefore: (NSNotification *)noti {
    NSIndexPath *indexPath = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    SimiTable *cells = noti.object;
    SimiRow *row = [[cells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    cartVC = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
    UITableView *tableView = cartVC.contentTableView;
    if([section.identifier isEqualToString:CART_TOTALS]) {
        if([row.identifier isEqualToString:CART_COUPONCODE_ROW]) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
            if(!cell){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                CGRect frame = CGRectMake(15, 10, CGRectGetWidth(tableView.frame) - 30 - 130, 44);
                cartCouponTextField = [[SimiTextField alloc] initWithFrame:frame placeHolder:@"Enter a coupon code" font:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR backgroundColor:COLOR_WITH_HEX(@"#e8e8e8") borderWidth:0 borderColor:[UIColor clearColor] paddingLeft:10];
                cartCouponTextField.autocorrectionType = UITextAutocorrectionTypeNo;
                cartCouponTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                cartCouponTextField.delegate = self;
                [cartCouponTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
                
                UIToolbar *couponCodeToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
                couponCodeToolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneEditCouponCode:)]];
                cartCouponTextField.inputAccessoryView = couponCodeToolbar;
                
                SimiButton *applyCouponCodeButton = [[SimiButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(tableView.frame) - 15 - 120, 10, 120, 44)];
                [applyCouponCodeButton setTitle:SCLocalizedString(@"Apply") forState:UIControlStateNormal];
                [applyCouponCodeButton addTarget:self action:@selector(applyCouponOnCartView:) forControlEvents:UIControlEventTouchUpInside];
                
                [cell addSubview:cartCouponTextField];
                [cell addSubview:applyCouponCodeButton];
                [SimiGlobalVar sortViewForRTL:cell andWidth:CGRectGetWidth(tableView.frame)];
                if([[SimiGlobalVar sharedInstance].cart.cartTotal valueForKey:@"coupon_code"])
                {
                    [cartCouponTextField setText:[[SimiGlobalVar sharedInstance].cart.cartTotal valueForKey:@"coupon_code"]];
                }else
                    [cartCouponTextField setText:@""];
                row.tableCell = cell;
                cartVC.isDiscontinue = YES;
            }
        }
    }
}

- (void)didSetCouponCodeOnCartView:(NSNotification *)noti{
    [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"cart_action" userInfo:@{@"action":@"apply_coupon_code",@"coupon_code":cartCouponTextField.text}];
    
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    [cartVC showToastMessage:responder.message];
    if (responder.status == SUCCESS) {
        [cartVC changeCartData:noti];
    }
    [cartVC stopLoadingData];
    [self removeObserverForNotification:noti];
}

- (void)applyCouponOnCartView:(UIButton*)sender
{
    NSString *couponCode = @"";
    couponCode = cartCouponTextField.text;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSetCouponCodeOnCartView:) name:Simi_DidApplyCouponCode object:[SimiGlobalVar sharedInstance].cart];
    [[SimiGlobalVar sharedInstance].cart applyCouponCodeWithCode:couponCode];
    [cartVC startLoadingData];
}

- (void)orderViewControllerInitTableAfter:(NSNotification *)noti {
    SimiTable *orderCells = noti.object;
    SimiSection *totalSection = [orderCells getSectionByIdentifier:ORDER_TOTALS_SECTION];
    SimiRow *totalRow = [totalSection getRowByIdentifier:ORDER_VIEW_CART];
    SimiRow *couponRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_COUPONCODE height:64 sortOrder:totalRow.sortOrder + 1];
    [totalSection addRow:couponRow];
}

- (void)orderViewControllerInitRightTableAfter:(NSNotification *)noti {
    SimiTable *orderCells = noti.object;
    SimiSection *totalSection = [orderCells getSectionByIdentifier:ORDER_VIEW_TOTAL];
    SimiRow *couponRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_COUPONCODE height:64 sortOrder:1000];
    [totalSection addRow:couponRow];
}

- (void)initializedOrderCellBefore: (NSNotification *)noti {
    SimiTable *cells = noti.object;
    NSIndexPath *indexPath = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    SimiRow *row = [[cells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    orderVC = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
    UITableView *tableView = orderVC.contentTableView;
    if([row.identifier isEqualToString:ORDER_VIEW_COUPONCODE]){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGRect frame = CGRectMake(15, 10, CGRectGetWidth(tableView.frame) - 30 - 130, 44);
            orderCouponTextField = [[SimiTextField alloc] initWithFrame:frame placeHolder:@"Enter a coupon code" font:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR backgroundColor:COLOR_WITH_HEX(@"#e8e8e8") borderWidth:0 borderColor:[UIColor clearColor] paddingLeft:10];
            orderCouponTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            orderCouponTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            orderCouponTextField.delegate = self;
            [orderCouponTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
            
            UIToolbar *couponCodeToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
            couponCodeToolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneEditCouponCode:)]];
            orderCouponTextField.inputAccessoryView = couponCodeToolbar;
            
            SimiButton *applyCouponCodeButton = [[SimiButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(tableView.frame) - 15 - 120, 10, 120, 44)];
            [applyCouponCodeButton setTitle:SCLocalizedString(@"Apply") forState:UIControlStateNormal];
            [applyCouponCodeButton addTarget:self action:@selector(applyCouponOnOrderView:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell addSubview:orderCouponTextField];
            [cell addSubview:applyCouponCodeButton];
            [SimiGlobalVar sortViewForRTL:cell andWidth:CGRectGetWidth(tableView.frame)];
        }
        if([orderVC.cart.cartTotal valueForKey:@"coupon_code"])
        {
            [orderCouponTextField setText:[orderVC.cart.cartTotal valueForKey:@"coupon_code"]];
        }else
            [orderCouponTextField setText:@""];
        row.tableCell = cell;
        orderVC.isDiscontinue = YES;
    }
}

- (void)doneEditCouponCode: (id)sender {
    if(orderCouponTextField)
        [orderCouponTextField resignFirstResponder];
    if(cartCouponTextField)
        [cartCouponTextField resignFirstResponder];
}

- (void)didSetCouponCodeOnOrderView:(NSNotification *)noti {
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    [orderVC showToastMessage:responder.message];
    [orderVC didGetOrderConfig:noti];
}

- (void)applyCouponOnOrderView:(UIButton*)sender {
    NSString *couponCode = @"";
    couponCode = orderCouponTextField.text;
    [orderVC trackingWithProperties:@{@"action":@"apply_coupon_code",@"coupon_code":couponCode}];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSetCouponCodeOnOrderView:) name:Simi_DidApplyCouponCode object:nil];
    [orderVC.order setCouponCode:couponCode];
    [orderVC startLoadingData];
}

@end
