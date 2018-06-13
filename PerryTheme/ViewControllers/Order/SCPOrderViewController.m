//
//  SCPOrderViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 6/12/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPOrderViewController.h"

@interface SCPOrderViewController ()

@end

@implementation SCPOrderViewController
- (void)viewDidAppearBefore:(BOOL)animated{
    [super viewDidAppearBefore:animated];
    CGRect frame = CGRectMake(SCALEVALUE(15), SCALEVALUE(20), SCREEN_WIDTH - 2*SCALEVALUE(15), CGRectGetHeight(self.view.frame) - heightPlaceOrder);
    if(self.contentTableView.frame.size.width != frame.size.width){
        self.contentTableView.frame = frame;
        [self.contentTableView setContentInset:UIEdgeInsetsMake(0, 0, SCALEVALUE(20), 0)];
        self.view.backgroundColor = COLOR_WITH_HEX(@"#f2f2f2");
        self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)createCells{
    if (!didGetStoreConfigData) {
        return;
    }
    if([self.order.billingAddress.modelData count] > 0){
        [self addBillingSectionToCells:self.cells];
    }
    if([self.order.shippingAddress.modelData count] > 0){
        [self addShippingSectionToCells:self.cells];
    }
//    //Add Shipping Method Section
//    if(self.order.shippingMethods.count > 0){
//        [self addShippingMethodsToCells:self.cells];
//    }
//
//    //Add Payment Method Section
//    if(self.order.paymentMethods.count > 0){
//        [self addPaymentMethodsToCells:self.cells];
//    }
//    //Add Shippment Detail section
//    [self addShipmentDetailToCells:self.cells];
}

- (SimiSection*)addBillingSectionToCells:(SimiTable*)cells{
    SimiSection *billingAddressSection = [[SimiSection alloc] initWithIdentifier:ORDER_BILLING_ADDRESS_SECTION];
    SimiRow *billingAddressRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_BILLING_ADDRESS height:100];
    [billingAddressSection addRow:billingAddressRow];
    [cells addObject:billingAddressSection];
    return billingAddressSection;
}

- (SimiSection*)addShippingSectionToCells:(SimiTable*)cells{
    SimiSection *shippingAddressSection = [[SimiSection alloc] initWithIdentifier:ORDER_SHIPPING_ADDRESS_SECTION];
    SimiRow *shippingAddressRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_SHIPPING_ADDRESS height:100];
    [shippingAddressSection addRow:shippingAddressRow];
    [cells addObject:shippingAddressSection];
    return shippingAddressSection;
}
- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if([row.identifier isEqualToString:ORDER_VIEW_BILLING_ADDRESS]){
        return [self createBillingAddressCellWithRow:row];
    }else if([row.identifier isEqualToString:ORDER_VIEW_SHIPPING_ADDRESS]){
        return [self createShippingAddressCellWithRow:row];
    }else{
        return [self contentTableViewCellForRowAtIndexPath:indexPath];
    }
}
- (SCPAddressTableViewCell *)createBillingAddressCellWithRow:(SimiRow *)row{
    SCPAddressTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:ORDER_VIEW_BILLING_ADDRESS];
    if (cell == nil) {
        cell = [[SCPAddressTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_BILLING_ADDRESS width:CGRectGetWidth(self.contentTableView.frame) type:SCPAddressTypeShipping];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell setAddressModel:self.billingAddress];
    row.height = cell.heightCell;
    return cell;
}
- (SCPAddressTableViewCell *)createShippingAddressCellWithRow:(SimiRow *)row{
    SCPAddressTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:ORDER_VIEW_SHIPPING_ADDRESS];
    if (cell == nil) {
        cell = [[SCPAddressTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_SHIPPING_ADDRESS width:CGRectGetWidth(self.contentTableView.frame) type:SCPAddressTypeShipping];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell setAddressModel:self.shippingAddress];
    row.height = cell.heightCell;
    return cell;
}
- (UIView *)contentTableViewViewForHeaderInSection:(NSInteger)section{
    return nil;
}
@end
