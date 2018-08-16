//
//  OrderWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 2/4/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "OrderWorker.h"
#import "SCCustomizeOrderViewController.h"
#import "SCCustomizeOrderViewControllerPad.h"
#import <SimiCartBundle/SCOrderDetailViewController.h>

@implementation OrderWorker
- (id)init{
    if(self == [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOrderView:) name:SIMI_SHOWORDERREVIEWSCREEN object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderDetailCellForRow:) name:[NSString stringWithFormat:@"%@%@",SCOrderDetailViewController_RootEventName,SimiTableViewController_SubKey_InitializedCell_Begin] object:nil];
    }
    return self;
}
- (void)showOrderView:(NSNotification *)noti{
    SCAppController *appController = noti.object;
    appController.isDiscontinue = YES;
    SCOrderViewController *orderViewController = [SCCustomizeOrderViewController new];
    if (PADDEVICE) {
        orderViewController = [SCCustomizeOrderViewControllerPad new];
    }
    UINavigationController *navi = [noti.userInfo objectForKey:KEYEVENT.APPCONTROLLER.navigation_controller];
    SimiAddressModel *billingAddress = [noti.userInfo objectForKey:KEYEVENT.ORDERVIEWCONTROLLER.billing_address];
    SimiAddressModel *shippingAddress = [noti.userInfo objectForKey:KEYEVENT.ORDERVIEWCONTROLLER.shipping_address];
    orderViewController.billingAddress = billingAddress;
    orderViewController.shippingAddress = shippingAddress;
    orderViewController.cart = GLOBALVAR.cart;
    orderViewController.checkOutType = [[noti.userInfo valueForKey:KEYEVENT.ORDERVIEWCONTROLLER.checkOut_type]integerValue];
    if (orderViewController.checkOutType == CheckOutTypeNewCustomer) {
        orderViewController.addressNewCustomerModel = billingAddress;
    }
    [navi pushViewController:orderViewController animated:YES];
}
- (void)orderDetailCellForRow:(NSNotification *)noti{
    SimiTable *cells = noti.object;
    NSIndexPath *indexPath = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    SCOrderDetailViewController *vc = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if([row.identifier isEqualToString:ORDER_DETAIL_PAYMENT_METHOD]){
        SimiTableViewCell *cell = [vc.contentTableView dequeueReusableCellWithIdentifier:ORDER_DETAIL_PAYMENT_METHOD];
        vc.isDiscontinue = YES;
        if (cell == nil) {
            cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_DETAIL_PAYMENT_METHOD];
            NSString *text = [NSString stringWithFormat:@"%@", [vc.order valueForKey:@"payment_method"]];
            if([vc.order objectForKey:@"po_number"]){
                text = [NSString stringWithFormat:@"%@\n%@: %@",text,SCLocalizedString(@"PURCHASE ORDER NUMBER"),[vc.order objectForKey:@"po_number"]];
            }
            SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(15, 5, CGRectGetWidth(vc.contentTableView.frame) - 30, 44)];
            label.text = text;
            label.numberOfLines = 0;
            [label sizeToFit];
            [cell.contentView addSubview:label];
            cell.heightCell = CGRectGetHeight(label.frame) + 10;
        }
        row.height = cell.heightCell;
        row.tableCell = cell;
    }
}
@end
