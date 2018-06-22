//
//  SCPPadOrderViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 6/18/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPPadOrderViewController.h"
#import "SCPButton.h"

@interface SCPPadOrderViewController ()

@end

@implementation SCPPadOrderViewController
#pragma mark Main Method
-(void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    widthMethodTitle = SCALEVALUE(400);
    widthMethodContent = SCALEVALUE(450);
    cellPaddingLeft = 20;
}

- (void)viewDidAppearBefore:(BOOL)animated{
    if (self.moreContentTableView == nil) {
        self.moreContentTableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * 0.6f, SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
        self.moreContentTableView .backgroundColor = [UIColor clearColor];
        self.moreContentTableView .showsVerticalScrollIndicator = NO;
        self.moreContentTableView .showsHorizontalScrollIndicator = NO;
        self.moreContentTableView .dataSource = self;
        self.moreContentTableView .delegate = self;
        [self.view addSubview:self.moreContentTableView ];
        
        self.contentTableView = [[UITableView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH*0.6f, 0, SCREEN_WIDTH*0.4f , SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
        self.contentTableView.backgroundColor = [UIColor clearColor];
        self.contentTableView.showsHorizontalScrollIndicator = NO;
        self.contentTableView.showsVerticalScrollIndicator = NO;
        self.contentTableView.dataSource = self;
        self.contentTableView.delegate = self;
        [self.view addSubview:self.contentTableView];
        
        self.view.backgroundColor = COLOR_WITH_HEX(@"#f2f2f2");
        self.contentTableView.backgroundColor = [UIColor clearColor];
        self.moreContentTableView.backgroundColor = [UIColor clearColor];
        self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.moreContentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.btnPlaceNow = [[SCPButton alloc] initWithFrame:CGRectMake(20, 20, 472, 50) title:@"PLACE ORDER" titleFont:[UIFont fontWithName:SCP_FONT_SEMIBOLD size:FONT_SIZE_HEADER] cornerRadius:0 borderWidth:0 borderColor:nil];
        [self.btnPlaceNow addTarget:self action:@selector(placeOrder) forControlEvents:UIControlEventTouchUpInside];
        
        [self getOrderConfig];
    }
    if (![self.cart.collectionData count]) {
        // Put back to shopping cart
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

- (void)reloadData{
    [self initMoreCells];
    [self initCells];
}

- (void)createMoreCells{
    if (!didGetStoreConfigData) {
        return;
    }
    if([self.order.billingAddress.modelData count] > 0){
        [self addBillingSectionToCells:self.moreCells];
    }
    if([self.order.shippingAddress.modelData count] > 0){
        [self addShippingSectionToCells:self.moreCells];
    }
    //Add Shipping Method Section
    if(self.order.shippingMethods.count > 0){
        [self addShippingMethodsToCells:self.moreCells];
    }
    
    //Add Payment Method Section
    if(self.order.paymentMethods.count > 0){
        [self addPaymentMethodsToCells:self.moreCells];
    }
    [self endInitMoreCellsWithInfo:@{}];
    for(SimiSection *section in self.moreCells){
        [section sortItems];
    }
    [self.moreContentTableView reloadData];
}

- (SimiSection*)addShipmentDetailToCells:(SimiTable *)cells{
    SimiSection *shipmentDetailSection = [super addShipmentDetailToCells:cells];
    SimiRow *placeNowRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_PLACE height:90 sortOrder:6000];
    [shipmentDetailSection addRow:placeNowRow];
    return shipmentDetailSection;
}

- (void)createCells{
    if (!didGetStoreConfigData) {
        return;
    }
    //Add Shippment Detail section
    [self addShipmentDetailToCells:self.cells];
}

#pragma mark Place Order
- (void)placeOrder{
    [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"Place order button selected" userInfo:@{}];
    if (selectedPaymentModel != nil && ((selectedShippingMedthodModel != nil && self.order.shippingMethods.count > 0) || self.order.shippingMethods == nil || self.order.shippingMethods.count == 0)) {
        if ([self checkTermAndConditions]) {
            [self processingPlaceOrder];
        }
    } else if(selectedShippingMedthodModel == nil && self.order.shippingMethods.count > 0){
        if (self.order.shippingMethods.count > 0 ) {
            // Scroll to shipping methods
            [self initMoreCells];
            [self.moreContentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.moreCells getSectionIndexByIdentifier:ORDER_SHIPMENT_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        if (selectedPaymentModel == nil) {
            [self showAlertWithTitle:@"" message:@"Please choose a shipping method and payment methods"];
        }else{
            [self showAlertWithTitle:@"" message:@"Please choose a shipping method"];
        }
    }else if(selectedPaymentModel == nil){
        if (self.order.paymentMethods.count > 0) {
            [self initMoreCells];
            [self.moreContentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.moreCells getSectionIndexByIdentifier:ORDER_PAYMENT_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        [self showAlertWithTitle:@"" message:@"Please choose a payment method"];
    }
}


#pragma mark TableView Datasource
- (UIView *)moreContentTableViewViewForHeaderInSection:(NSInteger)section{
    SimiSection *simiSection = [self.moreCells objectAtIndex:section];
    float headerPadding = SCALEVALUE(15);
    float headerWidth = CGRectGetWidth(self.moreContentTableView.frame) - 2*headerPadding;
    float titlePaddingX = SCALEVALUE(15);
    float buttonWidth = 44;
    
    UITableViewHeaderFooterView *headerView = [self.moreContentTableView dequeueReusableHeaderFooterViewWithIdentifier:simiSection.identifier];
    if(!headerView){
        headerView = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:simiSection.identifier];
        
        headerView.backgroundColor = [UIColor clearColor];
        headerView.contentView.backgroundColor = [UIColor clearColor];
        UIView *headerContentView = [[UIView alloc] initWithFrame:CGRectMake(headerPadding, 20, headerWidth, 64)];
        headerContentView.backgroundColor = [UIColor whiteColor];
        [headerView.contentView addSubview:headerContentView];
        SimiLabel *headerTitleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titlePaddingX, 18, headerWidth - titlePaddingX - 2*titlePaddingX, 24) andFontName:SCP_FONT_SEMIBOLD andFontSize:FONT_SIZE_HEADER andTextColor:[UIColor blackColor]];
        headerTitleLabel.text = simiSection.header.title;
        [headerContentView addSubview:headerTitleLabel];
        if([simiSection.identifier isEqualToString:ORDER_SHIPPING_ADDRESS_SECTION] || [simiSection.identifier isEqualToString:ORDER_BILLING_ADDRESS_SECTION]) {
            headerTitleLabel.frame = CGRectMake(titlePaddingX, 18, headerWidth - titlePaddingX - buttonWidth, 24);
            UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(headerWidth - buttonWidth, 0, buttonWidth, buttonWidth)];
            editButton.imageEdgeInsets = UIEdgeInsetsMake(15, 10, 10, 15);
            [editButton setImage:[[UIImage imageNamed:@"scp_ic_address_edit"] imageWithColor:SCP_ICON_COLOR] forState:UIControlStateNormal];
            editButton.simiObjectIdentifier = simiSection;
            [editButton addTarget:self action:@selector(editAddress:) forControlEvents:UIControlEventTouchUpInside];
            [headerContentView addSubview:editButton];
        }else if([simiSection.identifier isEqualToString:ORDER_TOTALS_SECTION]){
            headerTitleLabel.frame = CGRectMake(titlePaddingX, 18, headerWidth - titlePaddingX - buttonWidth, 24);
            UIButton *expandShipmentButton = [[UIButton alloc] initWithFrame:CGRectMake(headerWidth - buttonWidth, 0, buttonWidth, buttonWidth)];
            expandShipmentButton.imageEdgeInsets = UIEdgeInsetsMake(15, 10, 10, 15);
            [expandShipmentButton setImage:[[UIImage imageNamed:@"ic_narrow_down"] imageWithColor:SCP_ICON_COLOR] forState:UIControlStateNormal];
            expandShipmentButton.simiObjectIdentifier = simiSection;
            [expandShipmentButton addTarget:self action:@selector(expandShipment:) forControlEvents:UIControlEventTouchUpInside];
            [headerContentView addSubview:expandShipmentButton];
        }
        [SimiGlobalFunction sortViewForRTL:headerContentView andWidth:headerWidth];
    }
    return headerView;
}

- (UIView *)contentTableViewViewForHeaderInSection:(NSInteger)section{
    SimiSection *simiSection = [self.cells objectAtIndex:section];
    float headerPadding = SCALEVALUE(15);
    float headerWidth = CGRectGetWidth(self.contentTableView.frame) - 2*headerPadding;
    float titlePaddingX = SCALEVALUE(15);
    
    UITableViewHeaderFooterView *headerView = [self.contentTableView dequeueReusableHeaderFooterViewWithIdentifier:simiSection.identifier];
    if(!headerView){
        headerView = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:simiSection.identifier];
        
        headerView.backgroundColor = [UIColor clearColor];
        headerView.contentView.backgroundColor = [UIColor clearColor];
        UIView *headerContentView = [[UIView alloc] initWithFrame:CGRectMake(headerPadding, 20, headerWidth, 64)];
        headerContentView.backgroundColor = [UIColor whiteColor];
        [headerView.contentView addSubview:headerContentView];
        SimiLabel *headerTitleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titlePaddingX, 18, headerWidth - titlePaddingX - 2*titlePaddingX, 24) andFontName:SCP_FONT_SEMIBOLD andFontSize:FONT_SIZE_HEADER andTextColor:[UIColor blackColor]];
        headerTitleLabel.text = simiSection.header.title;
        [headerContentView addSubview:headerTitleLabel];
        [SimiGlobalFunction sortViewForRTL:headerContentView andWidth:headerWidth];
    }
    return headerView;
}


#pragma mark Cell for Row At IndexPath
- (UITableViewCell *)moreContentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [self.moreCells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
#pragma mark Billing Address Section
    UITableViewCell *cell;
    if ([simiSection.identifier isEqualToString:ORDER_BILLING_ADDRESS_SECTION]) {
        if(simiRow.identifier == ORDER_VIEW_BILLING_ADDRESS){
            cell = [self createSCPBillingAddressCellWithRow:simiRow tableView:self.moreContentTableView];
        }
    }
#pragma mark Shipping Address Section
    else if ([simiSection.identifier isEqualToString:ORDER_SHIPPING_ADDRESS_SECTION]){
        if(simiRow.identifier == ORDER_VIEW_SHIPPING_ADDRESS){
            cell = [self createSCPShippingAddressCellWithRow:simiRow tableView:self.moreContentTableView];
        }
#pragma mark Payment Section
    }else if ([simiSection.identifier isEqualToString:ORDER_PAYMENT_SECTION])
    {
        if(simiRow.identifier == ORDER_VIEW_PAYMENT_METHOD){
            cell = [self createPaymentMethodCellWithIndex:indexPath tableView:self.moreContentTableView cells:self.moreCells];
        }
#pragma mark Shiment Section
    }else if([simiSection.identifier isEqualToString:ORDER_SHIPMENT_SECTION]){
        if(simiRow.identifier == ORDER_VIEW_SHIPPING_METHOD){
            cell = [self createShippingMethodCellWithIndexPath:indexPath tableView:self.moreContentTableView cells:self.moreCells];
        }
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [self.cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    if([simiSection.identifier isEqualToString:ORDER_TOTALS_SECTION]){
        if(simiRow.identifier == ORDER_VIEW_CART){
            cell = [self createItemCellWithIndexPath:indexPath tableView:self.contentTableView cells:self.cells];
        }else if(simiRow.identifier == ORDER_VIEW_TOTAL){
            SCPOrderFeeCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:ORDER_VIEW_TOTAL];
            if(!cell){
                cell = [[SCPOrderFeeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_TOTAL];
                cell.userInteractionEnabled = NO;
            }
            [(SCPOrderFeeCell *)cell setData:cartPrices andWidthCell:CGRectGetWidth(self.contentTableView.frame)];
            simiRow.height = cell.heightCell;
            return cell;
        }else if(simiRow.identifier == ORDER_VIEW_TERM){
            cell = [self createTermCellWithIndexPath:indexPath tableView:self.contentTableView cells:self.cells];
        }else if(simiRow.identifier == ORDER_VIEW_AGREE_CHECKBOX){
            cell = [self createTermCheckboxCellWithIndexPath:indexPath tableView:self.contentTableView cells:self.cells];
        }else if(simiRow.identifier == ORDER_VIEW_PLACE){
            cell = [self.contentTableView dequeueReusableCellWithIdentifier:ORDER_VIEW_PLACE];
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_PLACE];
                
                self.btnPlaceNow.frame = CGRectMake(20, 20, CGRectGetWidth(self.contentTableView.frame) - 40, 50);
                [cell.contentView addSubview:self.btnPlaceNow];
            }
        }
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)contentTableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [self.cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    if(simiRow.identifier == ORDER_VIEW_TERM){
        SCTermConditionViewController *termView = [[SCTermConditionViewController alloc] init];
        termView.termAndCondition = simiRow.data;
        [self.navigationController pushViewController:termView animated:YES];
    }
}

- (void)moreContentTableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [self.moreCells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    if(simiRow.identifier == ORDER_VIEW_PAYMENT_METHOD){
        [self didSelectPaymentCellWithIndex:indexPath];
    }else if(simiRow.identifier == ORDER_VIEW_SHIPPING_METHOD){
        selectingShippingMedthodModel = [self.order.shippingMethods objectAtIndex:indexPath.row];
        [self saveShippingMethod];
    }
}

- (void)didSelectPaymentCellWithIndex:(NSIndexPath*)indexPath{
    selectingPaymentModel = [self.order.paymentMethods objectAtIndex:indexPath.row];
    if (selectingPaymentModel.showType == PaymentShowTypeCreditCard) {
        NSArray *creditCardTypes = selectingPaymentModel.ccTypes;
        if (creditCardTypes != nil) {
            SCPCreditCardViewController *nextController = [[SCPCreditCardViewController alloc] init];
            nextController.delegate = self;
            for (int i = 0; i < creditCards.count; i++) {
                NSMutableDictionary *creditCard = [creditCards objectAtIndex:i];
                if ([[creditCard valueForKey:@"payment_method"] isEqualToString:[selectingPaymentModel valueForKey:@"payment_method"]]) {
                    if (![[creditCard valueForKey:@"hasData"]boolValue]) {
                        nextController.creditCardList = selectingPaymentModel.ccTypes;
                        nextController.isUseCVV = selectingPaymentModel.useCcv;
                        nextController.isShowName = selectingPaymentModel.isShowName;
                        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:nextController];
                        navi.navigationBar.barTintColor = THEME_COLOR;
                        navi.navigationBar.tintColor = THEME_NAVIGATION_ICON_COLOR;
                        navi.modalPresentationStyle = UIModalPresentationPopover;
                        UIPopoverPresentationController *popover = navi.popoverPresentationController;
                        popover.sourceView = self.view;
                        popover.sourceRect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
                        popover.permittedArrowDirections = 0;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self presentViewController:navi animated:YES completion:nil];
                        });
                        [self reloadData];
                        [self.moreContentTableView deselectRowAtIndexPath:indexPath animated:YES];
                        return;
                    }
                    for (NSString *key in [creditCard allKeys]) {
                        [selectingPaymentModel setValue:[creditCard valueForKey:key] forKey:key];
                    }
                    for (NSString *key in [creditCard allKeys]) {
                        if ([key isEqualToString:@"cc_type"]) {
                            [selectingPaymentModel setValue:[[creditCard valueForKey:key] valueForKey:@"cc_code"] forKey:@"cc_type"];
                        }else
                            [selectingPaymentModel setValue:[creditCard valueForKey:key] forKey:key];
                    }
                    [selectingPaymentModel removeObjectForKey:hasData];
                }
            }
        }
    }
    
    [self savePaymentMethod:selectingPaymentModel];
    [self.moreContentTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)editAddress:(UIButton *)editButton {
    SimiSection *section = (SimiSection *)editButton.simiObjectIdentifier;
    SimiAddressModel* address = self.billingAddress;
    if([section.identifier isEqualToString:ORDER_BILLING_ADDRESS_SECTION]){
        isSelectBillingAddress = YES;
    }else if([section.identifier isEqualToString:ORDER_SHIPPING_ADDRESS_SECTION]){
        isSelectBillingAddress = NO;
    }
    if (GLOBALVAR.isLogin) {
        [[SCAppController sharedInstance]openAddressBookWithNavigationController:self.navigationController moreParams:@{KEYEVENT.APPCONTROLLER.delegate:self, KEYEVENT.APPCONTROLLER.is_showpopover:[NSNumber numberWithBool:YES]}];
        return;
    }else{
        NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithDictionary:@{KEYEVENT.APPCONTROLLER.delegate: self, KEYEVENT.NEWADDRESSVIEWCONTROLLER.address_model:address, KEYEVENT.APPCONTROLLER.is_showpopover:[NSNumber numberWithBool:YES]}];
        if (self.checkOutType == CheckOutTypeNewCustomer && isSelectBillingAddress) {
            [params setValue:[NSNumber numberWithBool:YES] forKey:KEYEVENT.NEWADDRESSVIEWCONTROLLER.is_newcustomer];
        }
        [[SCAppController sharedInstance]openNewAddressWithNavigationController:self.navigationController moreParams:params];
    }
    
}

#pragma mark SCAddress Delegate
-(void)selectAddress:(SimiAddressModel *)address
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self trackingWithProperties:@{@"action":@"edited_address"}];
    [super selectAddress:address];
}

#pragma mark New Address Delegate
// Change address with check out new customer and guest
- (void)didSaveAddress:(SimiAddressModel *)address
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self trackingWithProperties:@{@"action":@"edited_address"}];
    [super didSaveAddress:address];
}

#pragma mark Order Method Cell Delegate
- (void)editCreditCard:(SimiPaymentMethodModel*)paymentModel{
    selectingPaymentModel = paymentModel;
    SCCreditCardViewController *nextController = [[SCCreditCardViewController alloc] init];
    nextController.delegate = self;
    for (int i = 0; i < creditCards.count; i++) {
        NSMutableDictionary *creditCard = [creditCards objectAtIndex:i];
        if ([[creditCard valueForKey:@"payment_method"] isEqualToString:paymentModel.code]) {
            if ([[creditCard valueForKey:hasData]boolValue]) {
                nextController.defaultCard = [[NSDictionary alloc]initWithObjectsAndKeys:
                                              [creditCard valueForKey:@"cc_type"],@"cc_type",
                                              [creditCard valueForKey:@"cc_number"],@"cc_number",
                                              [creditCard valueForKey:@"cc_exp_month"], @"cc_exp_month",
                                              [creditCard valueForKey:@"cc_exp_year"], @"cc_exp_year",
                                              [creditCard valueForKey:@"cc_cid"] , @"cc_cid",
                                              [creditCard valueForKey:@"cc_username"] , @"cc_username",nil];
            }
            nextController.creditCardList = paymentModel.ccTypes;
            nextController.isUseCVV = paymentModel.useCcv;
            nextController.isShowName = paymentModel.isShowName;
        }
    }
    //  End Update Credit Card
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:nextController];
    navi.navigationBar.barTintColor = THEME_COLOR;
    navi.navigationBar.tintColor = THEME_NAVIGATION_ICON_COLOR;
    navi.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popover = navi.popoverPresentationController;
    popover.sourceView = self.view;
    popover.sourceRect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
    popover.permittedArrowDirections = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:navi animated:YES completion:nil];
    });
}
@end
