//
//  SCPOrderViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 6/12/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPOrderViewController.h"
#import "SCPGlobalVars.h"

@interface SCPOrderViewController ()

@end

@implementation SCPOrderViewController
- (void)viewDidAppearBefore:(BOOL)animated{
    [super viewDidAppearBefore:animated];
    CGRect frame = CGRectMake(15, 0, CGRectGetWidth(self.view.bounds) - 30, CGRectGetHeight(self.view.frame) - heightPlaceOrder);
    if(self.contentTableView.frame.size.width != frame.size.width){
        self.contentTableView.frame = frame;
        self.contentTableView.estimatedRowHeight = 0;
        self.contentTableView.showsVerticalScrollIndicator = NO;
        [self.contentTableView setContentInset:UIEdgeInsetsMake(0, 0, 20, 0)];
        self.view.backgroundColor = COLOR_WITH_HEX(@"#f2f2f2");
        self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.btnPlaceNow.backgroundColor = SCP_BUTTON_BACKGROUND_COLOR;
        [self.btnPlaceNow setTitleColor:SCP_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
        [self.btnPlaceNow titleLabel].font = [UIFont fontWithName:SCP_FONT_SEMIBOLD size:FONT_SIZE_HEADER];
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
    //Add Shipping Method Section
    if(self.order.shippingMethods.count > 0){
        [self addShippingMethodsToCells:self.cells];
    }
    
    //Add Payment Method Section
    if(self.order.paymentMethods.count > 0){
        [self addPaymentMethodsToCells:self.cells];
    }
//    //Add Shippment Detail section
//    [self addShipmentDetailToCells:self.cells];
}

- (SimiSection*)addBillingSectionToCells:(SimiTable*)cells{
    SimiSection *billingAddressSection = [[SimiSection alloc] initWithIdentifier:ORDER_BILLING_ADDRESS_SECTION];
    billingAddressSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"Billing Address") height:80];
    SimiRow *billingAddressRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_BILLING_ADDRESS];
    [billingAddressSection addRow:billingAddressRow];
    [cells addObject:billingAddressSection];
    return billingAddressSection;
}

- (SimiSection*)addShippingSectionToCells:(SimiTable*)cells{
    SimiSection *shippingAddressSection = [[SimiSection alloc] initWithIdentifier:ORDER_SHIPPING_ADDRESS_SECTION];
    shippingAddressSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"Shipping Address") height:80];
    SimiRow *shippingAddressRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_SHIPPING_ADDRESS];
    [shippingAddressSection addRow:shippingAddressRow];
    [cells addObject:shippingAddressSection];
    return shippingAddressSection;
}

- (SimiSection*)addShippingMethodsToCells:(SimiTable*)cells{
    SimiSection *shipmentSection = [[SimiSection alloc] initWithIdentifier:ORDER_SHIPMENT_SECTION];
    selectedShippingMedthodModel = nil;
    for (int i = 0; i< self.order.shippingMethods.count; i++) {
        SimiShippingMethodModel *shippingMethodModel = [self.order.shippingMethods objectAtIndex:i];
        if (shippingMethodModel.isSelected){
            selectedShippingMedthodModel = shippingMethodModel;
        }
        SimiRow *shipmentRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_SHIPPING_METHOD height:55];
        shipmentRow.model = shippingMethodModel;
        [shipmentSection addRow:shipmentRow];
    }
    shipmentSection.header = [[SimiSectionHeader alloc]initWithTitle:[NSString stringWithFormat:@"%@", SCLocalizedString(@"Shipping Method")] height:80];
    [cells addObject:shipmentSection];
    return shipmentSection;
}

- (SimiSection*)addPaymentMethodsToCells:(SimiTable*)cells{
    SimiSection *paymentSection = [[SimiSection alloc] initWithIdentifier:ORDER_PAYMENT_SECTION];
    selectedPaymentModel = nil;
    for(int i = 0; i < self.order.paymentMethods.count; i++){
        SimiPaymentMethodModel *paymentModel = [self.order.paymentMethods objectAtIndex:i];
        if(paymentModel.isSelected){
            selectedPaymentModel = paymentModel;
        }
        SimiRow *paymentRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_PAYMENT_METHOD height:44];
        paymentRow.model = paymentModel;
        [paymentSection addRow:paymentRow];
    }
    paymentSection.header = [[SimiSectionHeader alloc]initWithTitle:[NSString stringWithFormat:@"%@", SCLocalizedString(@"Payment Method")] height:80];
    [cells addObject:paymentSection];
    return paymentSection;
}


#pragma mark Table View Data Source
- (UIView *)contentTableViewViewForHeaderInSection:(NSInteger)section{
    SimiSection *simiSection = [self.cells objectAtIndex:section];
    float headerWidth = CGRectGetWidth(self.contentTableView.frame);
    float titlePaddingX = 15;
    float buttonWidth = 44;
    float buttonInset = 15;
    
    UITableViewHeaderFooterView *headerView = [self.contentTableView dequeueReusableHeaderFooterViewWithIdentifier:simiSection.identifier];
    if(!headerView){
        headerView = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:simiSection.identifier];
        
        headerView.backgroundColor = [UIColor clearColor];
        headerView.contentView.backgroundColor = [UIColor clearColor];
        UIView *headerContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, headerWidth, 64)];
        headerContentView.backgroundColor = [UIColor whiteColor];
        [headerView.contentView addSubview:headerContentView];
        SimiLabel *headerTitleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titlePaddingX, 18, headerWidth - titlePaddingX - 2*titlePaddingX, 24) andFontName:SCP_FONT_SEMIBOLD andFontSize:FONT_SIZE_HEADER andTextColor:[UIColor blackColor]];
        headerTitleLabel.text = simiSection.header.title;
        [headerContentView addSubview:headerTitleLabel];
        if([simiSection.identifier isEqualToString:ORDER_SHIPPING_ADDRESS_SECTION] || [simiSection.identifier isEqualToString:ORDER_BILLING_ADDRESS_SECTION]) {
            headerTitleLabel.frame = CGRectMake(titlePaddingX, 18, headerWidth - titlePaddingX - buttonWidth, 24);
            UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(headerWidth - buttonWidth, 0, buttonWidth, buttonWidth)];
            editButton.imageEdgeInsets = UIEdgeInsetsMake(buttonInset, buttonInset, buttonInset, buttonInset);
            [editButton setImage:[[UIImage imageNamed:@"scp_ic_address_edit"] imageWithColor:SCP_ICON_COLOR] forState:UIControlStateNormal];
            editButton.simiObjectIdentifier = simiSection;
            [editButton addTarget:self action:@selector(editAddress:) forControlEvents:UIControlEventTouchUpInside];
            [headerContentView addSubview:editButton];
        }
        [SimiGlobalFunction sortViewForRTL:headerContentView andWidth:headerWidth];
    }
    return headerView;
}

- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if([row.identifier isEqualToString:ORDER_VIEW_BILLING_ADDRESS]){
        return [self createBillingAddressCellWithRow:row];
    }else if([row.identifier isEqualToString:ORDER_VIEW_SHIPPING_ADDRESS]){
        return [self createShippingAddressCellWithRow:row];
    }else if([row.identifier isEqualToString:ORDER_VIEW_SHIPPING_METHOD]){
        return [self createShippingMethodCellWithIndexPath:indexPath tableView:self.contentTableView cells:self.cells];
    }else if([row.identifier isEqualToString:ORDER_VIEW_PAYMENT_METHOD]){
        return [self createPaymentMethodCellWithIndex:indexPath tableView:self.contentTableView cells:self.cells];
    }
    else{
        return [self contentTableViewCellForRowAtIndexPath:indexPath];
    }
}
- (SCPOrderAddressTableViewCell *)createBillingAddressCellWithRow:(SimiRow *)row{
    SCPOrderAddressTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:ORDER_VIEW_BILLING_ADDRESS];
    if (cell == nil) {
        cell = [[SCPOrderAddressTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_BILLING_ADDRESS width:CGRectGetWidth(self.contentTableView.frame) type:SCPAddressTypeBilling];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell setAddressModel:self.billingAddress];
    row.height = cell.heightCell;
    return cell;
}
- (SCPOrderAddressTableViewCell *)createShippingAddressCellWithRow:(SimiRow *)row{
    SCPOrderAddressTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:ORDER_VIEW_SHIPPING_ADDRESS];
    if (cell == nil) {
        cell = [[SCPOrderAddressTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_SHIPPING_ADDRESS width:CGRectGetWidth(self.contentTableView.frame) type:SCPAddressTypeShipping];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell setAddressModel:self.shippingAddress];
    row.height = cell.heightCell;
    return cell;
}

- (SCPOrderMethodCell *)createPaymentMethodCellWithIndex:(NSIndexPath*)indexPath tableView:(UITableView *)tableView cells:(SimiTable *)cells{
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    NSString *paymentContent = @"";
    SimiPaymentMethodModel *payment = (SimiPaymentMethodModel*)row.model;
    NSString *identifier = payment.code;
    SCPOrderMethodCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SCPOrderMethodCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (payment.showType == PaymentShowTypeNone) {
        if (payment.content != nil && [payment.code isEqualToString:selectedPaymentModel.code]) {
            paymentContent = payment.content;
        }
    }else if (payment.showType == PaymentShowTypeCreditCard){
        if (payment.isSelected) {
            for (int i = 0; i < creditCards.count; i++) {
                NSDictionary *creditCard = [creditCards objectAtIndex:i];
                if ([[creditCard valueForKey:@"payment_method"] isEqualToString:payment.code]) {
                    if ([[creditCard valueForKey:hasData]boolValue]) {
                        NSString *ccNumberString = [creditCard valueForKey:@"cc_number"];
                        if (ccNumberString.length > 4) {
                            paymentContent = [NSString stringWithFormat:@"****%@", [[creditCard valueForKey:@"cc_number"] substringWithRange:NSMakeRange([[creditCard valueForKey:@"cc_number"] length] - 4, 4)]];
                        }
                    }
                    break;
                }
            }
        }
        cell.isCreditCard = YES;
        cell.creditCartPaymentModel = payment;
        cell.delegate = self;
    }
    [cell setTitle:payment.title andContent:paymentContent andIsSelected:payment.isSelected titleWidth:widthMethodTitle contentWidth:widthMethodContent];
    row.height = cell.heightCell;
    if(row == section.rows.lastObject){
        row.height += 5;
    }
    return cell;
}
- (SCPOrderMethodCell *)createShippingMethodCellWithIndexPath:(NSIndexPath*)indexPath tableView:(UITableView*)tableView cells:(SimiTable*)cells{
    SimiSection *simiSection = [cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    SimiShippingMethodModel *shippingModel = (SimiShippingMethodModel*)simiRow.model;
    NSString *identifier = shippingModel.code;
    SCPOrderMethodCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SCPOrderMethodCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString *title = shippingModel.title;
    NSString *name = shippingModel.name;
    [cell setTitle:title andContent:name andIsSelected:shippingModel.isSelected titleWidth:widthMethodTitle contentWidth:widthMethodContent];
    [cell setPriceWithParams:simiRow.model.modelData];
    simiRow.height = cell.heightCell;
    if(simiRow == simiSection.rows.lastObject){
        simiRow.height += 5;
    }
    return cell;
}
@end
