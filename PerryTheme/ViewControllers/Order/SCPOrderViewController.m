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
- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    shipmentExpandIndexPaths = [NSMutableArray new];
    isExpandShipment = NO;
}
- (void)configureLogo{
    self.title = @"Order review";
}
- (void)viewDidAppearBefore:(BOOL)animated{
    [super viewDidAppearBefore:animated];
    if(self.btnPlaceNow.backgroundColor != SCP_BUTTON_BACKGROUND_COLOR){
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
    [self addShipmentDetailToCells:self.cells];
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

- (SimiSection *)addShipmentDetailToCells:(SimiTable*)cells{
    SimiSection *shipmentDetailSection = [[SimiSection alloc]initWithIdentifier:ORDER_TOTALS_SECTION];
    shipmentDetailSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"Shipment Details") height:80];
    [cells addObject:shipmentDetailSection];
    NSInteger sectionIndex = [cells indexOfObject:shipmentDetailSection];
    if(self.cart.collectionData.count > 0){
        for(int j=0; j < self.cart.collectionData.count; j++){
            if(isExpandShipment){
                SimiRow *cartItemRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_CART];
                [shipmentDetailSection addRow:cartItemRow];
            }
            if(!shipmentExpandIndexPaths.count)
                [shipmentExpandIndexPaths addObject:[NSIndexPath indexPathForRow:j inSection:sectionIndex]];
        }
    }
    
    cartPrices = [GLOBALVAR convertCartPriceData:self.order.total];
    SimiRow *totalRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_TOTAL];
    [shipmentDetailSection addRow:totalRow];
    
    if(termAndConditions.count > 0){
        for(int m=0; m<termAndConditions.count; m++){
            SimiRow *termRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_TERM height:85];
            termRow.data = [termAndConditions objectAtIndex:m];
            [shipmentDetailSection addRow:termRow];
            SimiRow* checkboxRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_AGREE_CHECKBOX height:40];
            checkboxRow.data = [termAndConditions objectAtIndex:m];
            [shipmentDetailSection addRow:checkboxRow];
        }
    }
    return shipmentDetailSection;
}

#pragma mark Table View Data Source
- (UIView *)contentTableViewViewForHeaderInSection:(NSInteger)section{
    SimiSection *simiSection = [self.cells objectAtIndex:section];
    float headerPadding = SCALEVALUE(15);
    float headerWidth = CGRectGetWidth(self.contentTableView.frame) - 2*headerPadding;
    float titlePaddingX = SCALEVALUE(15);
    float buttonWidth = 44;
    
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

- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if([row.identifier isEqualToString:ORDER_VIEW_BILLING_ADDRESS]){
        return [self createSCPBillingAddressCellWithRow:row tableView:self.contentTableView];
    }else if([row.identifier isEqualToString:ORDER_VIEW_SHIPPING_ADDRESS]){
        return [self createSCPShippingAddressCellWithRow:row tableView:self.contentTableView];
    }else if([row.identifier isEqualToString:ORDER_VIEW_SHIPPING_METHOD]){
        return [self createShippingMethodCellWithIndexPath:indexPath tableView:self.contentTableView cells:self.cells];
    }else if([row.identifier isEqualToString:ORDER_VIEW_PAYMENT_METHOD]){
        return [self createPaymentMethodCellWithIndex:indexPath tableView:self.contentTableView cells:self.cells];
    }else if([row.identifier isEqualToString:ORDER_VIEW_CART]){
        return [self createItemCellWithIndexPath:indexPath tableView:self.contentTableView cells:self.cells];
    }else if([row.identifier isEqualToString:ORDER_VIEW_TOTAL]){
        SCPOrderFeeCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:ORDER_VIEW_TOTAL];
        if(!cell){
            cell = [[SCPOrderFeeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_TOTAL];
            cell.userInteractionEnabled = NO;
        }
        [(SCPOrderFeeCell *)cell setData:cartPrices andWidthCell:CGRectGetWidth(self.contentTableView.frame)];
        row.height = cell.heightCell;
        return cell;
    }else if([row.identifier isEqualToString:ORDER_VIEW_TERM]){
        return [self createTermCellWithIndexPath:indexPath tableView:self.contentTableView cells:self.cells];
    }else if([row.identifier isEqualToString:ORDER_VIEW_AGREE_CHECKBOX]){
        return [self createTermCheckboxCellWithIndexPath:indexPath tableView:self.contentTableView cells:self.cells];
    }else{
        return [super contentTableViewCellForRowAtIndexPath:indexPath];
    }
}
- (SCPOrderAddressTableViewCell *)createSCPBillingAddressCellWithRow:(SimiRow *)row tableView:(UITableView *)tableView{
    SCPOrderAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ORDER_VIEW_BILLING_ADDRESS];
    if (cell == nil) {
        float width = CGRectGetWidth(self.contentTableView.frame);
        if(PADDEVICE)
            width = CGRectGetWidth(self.moreContentTableView.frame);
        cell = [[SCPOrderAddressTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_BILLING_ADDRESS width:width type:SCPAddressTypeBilling];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell setAddressModel:self.billingAddress];
    row.height = cell.heightCell;
    return cell;
}
- (SCPOrderAddressTableViewCell *)createSCPShippingAddressCellWithRow:(SimiRow *)row tableView:(UITableView *)tableView{
    SCPOrderAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ORDER_VIEW_SHIPPING_ADDRESS];
    if (cell == nil) {
        float width = CGRectGetWidth(self.contentTableView.frame);
        if(PADDEVICE)
            width = CGRectGetWidth(self.moreContentTableView.frame);
        cell = [[SCPOrderAddressTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_SHIPPING_ADDRESS width:width type:SCPAddressTypeShipping];
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
        cell.isCreditCard = YES;
        cell.creditCartPaymentModel = payment;
        cell.delegate = self;
    }
    float width = CGRectGetWidth(self.contentTableView.frame);
    if(PADDEVICE)
        width = CGRectGetWidth(self.moreContentTableView.frame);
    [cell setTitle:payment.title andContent:paymentContent andIsSelected:payment.isSelected width:width];
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
    float width = CGRectGetWidth(self.contentTableView.frame);
    if(PADDEVICE)
        width = CGRectGetWidth(self.moreContentTableView.frame);
    [cell setTitle:title andContent:name andIsSelected:shippingModel.isSelected width:width];
    [cell setPriceWithParams:simiRow.model.modelData];
    simiRow.height = cell.heightCell;
    if(simiRow == simiSection.rows.lastObject){
        simiRow.height += 5;
    }
    return cell;
}
- (SCPCartCell *)createItemCellWithIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView cells:(SimiTable *)cells{
    SimiSection *simiSection = [cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    SimiQuoteItemModel *item = (SimiQuoteItemModel *)[self.cart.collectionData objectAtIndex:indexPath.row];
    NSString *identifier = [NSString stringWithFormat:@"%@_%@",simiRow.identifier, item.itemId];
    SCPCartCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SCPCartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier quoteItemModel:item useOnOrderPage:YES];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.userInteractionEnabled = NO;
    }
    if(cell.heightCell > simiRow.height){
        simiRow.height = cell.heightCell;
    }
    return cell;
}
- (SimiTableViewCell *)createTermCellWithIndexPath:(NSIndexPath*)indexPath tableView:(UITableView*)tableView cells:(SimiTable*)cells{
    SimiSection *simiSection = [cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    NSString* termIdentifier = [NSString stringWithFormat:@"%@%ld",ORDER_VIEW_TERM,(long)indexPath.row];
    SimiTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:termIdentifier];
    NSDictionary *term = simiRow.data;
    if(cell == nil){
        cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:termIdentifier];
        cell.heightCell = 5;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(tableView.frame) - cellPaddingLeft - 44, cell.heightCell, 44, 44)];
        button.enabled = NO;
        [button setImage:[UIImage imageNamed:@"scp_ic_next"] forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 15, 15)];
        [cell.contentView addSubview:button];
        UILabel* termConditionLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellPaddingLeft, cell.heightCell, CGRectGetWidth(tableView.frame) - 2*cellPaddingLeft - 10, 75)];
        termConditionLabel.attributedText = [[NSAttributedString alloc] initWithData:[[NSString stringWithFormat:@"<span style=\"font-family: %@; font-size: %f\">%@</span>",THEME_FONT_NAME,FONT_SIZE_LARGE,[term objectForKey:@"content"]] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        if(GLOBALVAR.isReverseLanguage){
            termConditionLabel.textAlignment = NSTextAlignmentRight;
        }
        termConditionLabel.numberOfLines = 3;
        [termConditionLabel sizeToFit];
        [cell.contentView addSubview:termConditionLabel];
        cell.heightCell += CGRectGetHeight(termConditionLabel.frame) + 5;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    simiRow.height = cell.heightCell;
    return cell;
}

- (UITableViewCell*)createTermCheckboxCellWithIndexPath:(NSIndexPath*)indexPath tableView:(UITableView*)tableView cells:(SimiTable*)cells{
    SimiSection *simiSection = [cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    NSString* identifier = [NSString stringWithFormat:@"%@%ld",ORDER_VIEW_AGREE_CHECKBOX,(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    NSDictionary *term = simiRow.data;
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        SimiCheckbox* checkbox = [[SimiCheckbox alloc] initWithTitle:SCLocalizedString([term objectForKey:@"title"])];
        [checkbox.titleLabel setFont:[UIFont fontWithName:SCP_FONT_SEMIBOLD size:FONT_SIZE_LARGE]];
        [checkbox.titleLabel setTextColor:[UIColor blackColor]];
        checkbox.strokeColor = [UIColor blackColor];
        checkbox.checkColor = SCP_ICON_HIGHLIGHT_COLOR;
        checkbox.frame = CGRectMake(cellPaddingLeft, 5, CGRectGetWidth(tableView.frame) - 2*cellPaddingLeft, 30);
        if ([GLOBALVAR isReverseLanguage]) {
            [checkbox setFrame: CGRectMake(cellPaddingLeft, 5, CGRectGetWidth(tableView.frame) - 2*cellPaddingLeft, 30)];
            [checkbox.titleLabel setTextAlignment:NSTextAlignmentRight];
            [checkbox setCheckAlignment:M13CheckboxAlignmentRight];
        }
        checkbox.radius = 1.0f;
        checkbox.simiObjectIdentifier = simiRow.data;
        [cell.contentView addSubview:checkbox];
        cell.clipsToBounds = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [checkbox addTarget:self action:@selector(toggleCheckBox:) forControlEvents:UIControlEventValueChanged];
    }
    return cell;
}

- (void)expandShipment:(id)sender{
    UIButton *button = (UIButton *)sender;
    isExpandShipment = !isExpandShipment;
    if(isExpandShipment){
        [button setImage:[UIImage imageNamed:@"ic_narrow_up"] forState:UIControlStateNormal];
    }else{
        [button setImage:[UIImage imageNamed:@"ic_narrow_down"] forState:UIControlStateNormal];
    }
    [self initCells];
    [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.cells getSectionIndexByIdentifier:ORDER_TOTALS_SECTION]] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//    [self.contentTableView beginUpdates];
//    if(isExpandShipment){
//        [self.contentTableView insertRowsAtIndexPaths:shipmentExpandIndexPaths withRowAnimation:UITableViewRowAnimationFade];
//    }else{
//        [self.contentTableView deleteRowsAtIndexPaths:shipmentExpandIndexPaths withRowAnimation:UITableViewRowAnimationFade];
//    }
//    [self.contentTableView endUpdates];
}

- (void)didSelectPaymentCellWithIndex:(NSIndexPath*)indexPath{
    SimiSection *simiSection = [self.cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    selectingPaymentModel = (SimiPaymentMethodModel *)simiRow.model;
    if (selectingPaymentModel.showType == PaymentShowTypeCreditCard) {
        NSArray *creditCardTypes = selectingPaymentModel.ccTypes;
        if (creditCardTypes != nil) {
            SCPCreditCardViewController *nextController = [[SCPCreditCardViewController alloc] init];
            nextController.delegate = self;
            for (int i = 0; i < creditCards.count; i++) {
                NSDictionary *creditCard = [creditCards objectAtIndex:i];
                if ([[creditCard valueForKey:@"payment_method"] isEqualToString:selectingPaymentModel.code]) {
                    if (![[creditCard valueForKey:@"hasData"]boolValue]) {
                        nextController.creditCardList = selectingPaymentModel.ccTypes;
                        nextController.isUseCVV = selectingPaymentModel.useCcv;
                        nextController.isShowName = selectingPaymentModel.isShowName;
                        [self.navigationController pushViewController:nextController animated:YES];
                        return;
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
    [self.contentTableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
