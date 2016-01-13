//
//  SCOrderViewController.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/18/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <SimiCartBundle/SCOrderFeeCell.h>
#import <SimiCartBundle/SCCartCell.h>
#import <SimiCartBundle/SCShippingViewController.h>
#import <SimiCartBundle/NSObject+SimiObject.h>
#import <SimiCartBundle/SimiResponder.h>
#import <SimiCartBundle/InitWorker.h>
#import <SimiCartBundle/SCTermConditionViewController.h>
#import <SimiCartBundle/SimiCheckbox.h>
#import <SimiCartBundle/UILabelDynamicSize.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>

#import "SCOrderViewController_Theme01.h"
#import "SCLoginViewController_Theme01.h"
#import "SimiGlobalVar+Theme01.h"

#define CUSTOMER_ROLE_SELECTOR 0
#define CUSTOMER_ROLE_GUEST 2
#define CUSTOMER_ROLE_NEW 1
#define CUSTOMER_ROLE_CUSTOMER 0
#define AGREEMENT 4
#define TF_COUPON_CODE 1
#define AFTERPLACEORDER 100

@implementation SCOrderViewController_Theme01

@synthesize orderTable = _orderTable;
@synthesize tableViewOrder, order, shippingAddress, billingAddress, cart, cartPrices, paymentCollection, shippingCollection, selectedShippingMedthod, textFieldCouponCode, selectedPayment, termAndConditions,isSelectBillingAddress;



- (void)viewDidLoadBefore
{
    self.title = [SCLocalizedString(@"Review Order") uppercaseString];
    if (SIMI_SYSTEM_IOS >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self setToSimiView];
    
    self.tableViewOrder = [[SimiTableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableViewOrder.dataSource = self;
    self.tableViewOrder.delegate = self;
    self.tableViewOrder.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.tableViewOrder];
    self.selectedShippingMedthod = 0;
    self.selectedPayment = -1;
    
    self.isReloadPayment = [NSString stringWithFormat:@"%@",[[[[SimiGlobalVar sharedInstance]store] valueForKey:@"store_config"]valueForKey:@"is_reload_payment_method"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOrderConfig) name:@"DidAddToCart" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidCreate2CheckoutPayment" object:nil userInfo:@{@"orderViewController": self}];
}

- (void)reloadData
{
    _orderTable = nil;
    [self.tableViewOrder reloadData];
}

- (void) setCart:(SimiCartModelCollection *)cart_
{
    cart = cart_;
}

- (void) setCartPrices:(NSMutableArray *)cartPrices_
{
    cartPrices = cartPrices_;
}

- (SimiTable *)orderTable
{
    if (_orderTable) {
        return _orderTable;
    }
    _orderTable = [SimiTable new];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCOrderViewController-InitTableBefore" object:_orderTable];
    //Add Billing and Shipping Addresses Section
    SimiSection *addressSection = [[SimiSection alloc] initWithIdentifier:ORDER_ADDRESS_SECTION];
    addressSection.headerTitle = SCLocalizedString(@"Billing and Shipping Addresses");
    SimiRow *billingAddressRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_BILLING_ADDRESS height:160];
    [addressSection addRow:billingAddressRow];
    if(self.shippingCollection.count > 0){
        SimiRow *shippingAddressRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_SHIPPING_ADDRESS height:160];
        [addressSection addRow:shippingAddressRow];
    }
    [_orderTable addObject:addressSection];
    
    //Add Shipping Method Section
    if(self.shippingCollection.count > 0){
        SimiSection *shipmentSection = [[SimiSection alloc] initWithIdentifier:ORDER_SHIPMENT_SECTION];
        shipmentSection.headerTitle = SCLocalizedString(@"Shipping Method");
        SimiRow *shipmentRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_SHIPPING_METHOD height:40];
        [shipmentSection addRow:shipmentRow];
        [_orderTable addObject:shipmentSection];
    }
    
    
    //Add Payment Method Section
    CGFloat heightRow = 40;
    if(self.paymentCollection.count > 0){
        SimiSection *paymentSection = [[SimiSection alloc] initWithIdentifier:ORDER_PAYMENT_SECTION];
        paymentSection.headerTitle = SCLocalizedString(@"Payment");
        
        for(int i=0; i<self.paymentCollection.count; i++){
            if (i == self.selectedPayment){
                NSString *content = [[self.paymentCollection objectAtIndex:i] valueForKey:@"content"];
                CGSize maxSize = CGSizeMake(300, 9999);
                CGSize neededSize = [content sizeWithFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:15] constrainedToSize:maxSize lineBreakMode:NSLineBreakByTruncatingTail];
                neededSize.height = neededSize.height > 10 ? neededSize.height : 10;
                heightRow = neededSize.height + 50;
            }else{
                heightRow = 40;
            }

            SimiRow *paymentRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_PAYMENT_METHOD height:heightRow];
            [paymentSection addRow:paymentRow];
        }
        [_orderTable addObject:paymentSection];
    }
    
    //Add Shippment Detail section
    SimiSection *shipmentDetailSection = [[SimiSection alloc]initWithIdentifier:ORDER_TOTALS_SECTION];
    shipmentDetailSection.headerTitle = SCLocalizedString(@"Shipment Details");
    if(self.cart.count > 0){
        for(int j=0; j<self.cart.count; j++){
            SimiRow *cartItemRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_CART height:120];
            [shipmentDetailSection addRow:cartItemRow];
        }
    }
    heightRow = 60;
    NSArray * totalV2 = [self.order valueForKey:@"total_v2"];
    if(![self.order valueForKey:@"total_v2"]){
        NSArray *fee= [self.order valueForKey:@"fee"];
        totalV2 = [fee valueForKey:@"v2"];
    }
    if(totalV2.count > 0 ){
        heightRow = 26 * totalV2.count;
    }
    SimiRow *totalRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_TOTAL height:heightRow];
    [shipmentDetailSection addRow:totalRow];
    [_orderTable addObject:shipmentDetailSection];
    
    //Add Coupon Code Section
    SimiSection *couponSection = [[SimiSection alloc] initWithIdentifier:ORDER_COUPON_SECTION];
    couponSection.headerTitle = SCLocalizedString(@"Coupon code");
    SimiRow *couponRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_COUPONCODE height:40];
    [couponSection addRow:couponRow];
    [_orderTable addObject:couponSection];
    
    //Add Term and Conditions Section
    if(self.termAndConditions.count > 0){
        SimiSection *termSection = [[SimiSection alloc] initWithIdentifier:ORDER_TERMS_SECTION];
        termSection.headerTitle = SCLocalizedString(@"Term and conditions");
        for(int m=0; m<self.termAndConditions.count; m++){
            SimiRow *termRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_TERM height:80];
            [termSection addRow:termRow];
        }
        [_orderTable addObject:termSection];
    }

    //Add Place Order Code Section
    SimiSection *placeSection = [[SimiSection alloc] initWithIdentifier:ORDER_BUTTON_SECTION];
    placeSection.headerTitle = @"";
    SimiRow *placeRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_PLACE height:70];
    [placeSection addRow:placeRow];
    [_orderTable addObject:placeSection];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCOrderViewController-InitTableAfter" object:_orderTable];
    return _orderTable;
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.orderTable.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.orderTable objectAtIndex:section] count];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle = @"";
    SimiSection *simiSection = [self.orderTable objectAtIndex:section];
    headerTitle = simiSection.headerTitle;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    if(simiSection.identifier == ORDER_BUTTON_SECTION)
        headerView.backgroundColor = [UIColor clearColor];
    UILabel *headerTitleSection = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width - 20, 30)];
    headerTitleSection.text = headerTitle;
    [headerTitleSection setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:18]];
    [headerTitleSection setTextColor:[UIColor blackColor]];
    //  Liam Update RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [headerTitleSection setTextAlignment:NSTextAlignmentRight];
    }
    //  End RTL
    [headerView addSubview:headerTitleSection];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     SimiSection *simiSection = [self.orderTable objectAtIndex:indexPath.section];
     SimiRow *row = [simiSection.rows objectAtIndex:indexPath.row];
     CGFloat heightRow = row.height;
     return heightRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    SimiSection *simiSection = [self.orderTable objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedOrderCell-Before" object:cell];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return cell;
    }
    
    if ([simiSection.identifier isEqualToString:ORDER_ADDRESS_SECTION]) {
        if(simiRow.identifier == ORDER_VIEW_BILLING_ADDRESS){
            if(cell == nil){
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_BILLING_ADDRESS];
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
            CGFloat heightCell = 13;
            int imageX = 18;
            int addressX = 40;
            int editImageX = 290;
            int addressWidth = 300;
            int addressHeight = 20;
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                imageX = 290;
                addressX = 10;
                addressWidth = 270;
                editImageX = 10;
            }
            if (self.billingAddress != nil) {
                //User Name
                NSString *imgUser = @"theme01_user";
                UIImage *userImage = [[UIImage imageNamed:imgUser] imageWithColor:THEME01_SUB_PART_COLOR];
                UIImageView *userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 5, 13, 13)];
                userImageView.image = userImage;
                NSString *imgEdit = @"theme01_address_edit";
                UIImage *editImage = [[UIImage imageNamed:imgEdit] imageWithColor:THEME01_SUB_PART_COLOR];
                UIImageView *editImageView = [[UIImageView alloc]initWithFrame:CGRectMake(editImageX,  heightCell - 7, 14, 16)];
                editImageView.image = editImage;
                UILabel *userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                userLabel.text = [NSString stringWithFormat:@"%@", [self.billingAddress valueForKey:@"name"]];
                userLabel.textColor = [UIColor blackColor];
                userLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:16.0];
                CGFloat labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                [cell addSubview:userImageView];
                [cell addSubview:editImageView];
                [cell addSubview:userLabel];
                heightCell += labelHeight + 5;
                // User Address
                if([self.billingAddress valueForKey:@"street"]){
                    imgUser = @"theme01_street";
                    userImage = [[UIImage imageNamed:imgUser] imageWithColor:THEME01_SUB_PART_COLOR];
                    userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 5, 12, 16)];
                    userImageView.image = userImage;
                    userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth - 5, addressHeight)];
                    userLabel.text = [NSString stringWithFormat:@"%@", [self.billingAddress valueForKey:@"street"]];
                    if([self.billingAddress valueForKey:@"city"]){
                        userLabel.text = [userLabel.text stringByAppendingString:[NSString stringWithFormat:@", %@", [self.billingAddress valueForKey:@"city"]]];
                    }
                    if([self.billingAddress valueForKey:@"state_name"] &&
                       ![[self.billingAddress valueForKey:@"state_name"] isKindOfClass:[NSNull class]] && [NSString stringWithFormat:@"%@", [self.billingAddress valueForKey:@"state_name"]].length > 0){
                        userLabel.text = [userLabel.text stringByAppendingString:[NSString stringWithFormat:@", %@", [self.billingAddress valueForKey:@"state_name"]]];
                    }
                    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
                        NSRange stringRange = {0, MIN([userLabel.text length], 70)};
                        stringRange = [userLabel.text rangeOfComposedCharacterSequencesForRange:stringRange];
                        userLabel.text = [userLabel.text substringWithRange:stringRange];
                    }
                    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
                        NSRange stringRange = {0, MIN([userLabel.text length], 68)};
                        stringRange = [userLabel.text rangeOfComposedCharacterSequencesForRange:stringRange];
                        userLabel.text = [userLabel.text substringWithRange:stringRange];
                        if([userLabel.text length] > 68){
                            userLabel.text = [userLabel.text stringByAppendingString:@"..."];
                        }
                    }
                    userLabel.textColor = [UIColor blackColor];
                    userLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:16.0];
                    labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                    [userLabel resizLabelToFit];
                    CGRect frame = userLabel.frame;
                    if(frame.size.height > 22){
                        frame.size.height = 40;
                        userLabel.numberOfLines = 2;
                        heightCell += frame.size.height;
                    }else{
                        heightCell += labelHeight;
                    }
                    [cell addSubview:userImageView];
                    [cell addSubview:userLabel];
                }
                UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                addressLabel.text = @"";
                if([self.billingAddress valueForKey:@"zip"]){
                    if(![addressLabel.text isEqualToString:@""])
                        addressLabel.text = [addressLabel.text stringByAppendingString:@", "];
                    addressLabel.text = [addressLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@", [self.billingAddress valueForKey:@"zip"]]];
                }
                if([self.billingAddress valueForKey:@"country_name"]){
                    if(![addressLabel.text isEqualToString:@""])
                        addressLabel.text = [addressLabel.text stringByAppendingString:@", "];
                    addressLabel.text =[addressLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@", [self.billingAddress valueForKey:@"country_name"]]];
                }
                addressLabel.textColor = [UIColor blackColor];
                addressLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:16.0];
                labelHeight = [addressLabel.text sizeWithFont:addressLabel.font].height;
                [cell addSubview:addressLabel];
                heightCell += labelHeight + 5;
                // User Phone
                if([self.billingAddress valueForKey:@"phone"]){
                    imgUser = @"theme01_phone";
                    userImage = [[UIImage imageNamed:imgUser] imageWithColor:THEME01_SUB_PART_COLOR];
                    userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 5, 13, 13)];
                    userImageView.image = userImage;
                    userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                    userLabel.text = [NSString stringWithFormat:@"%@", [self.billingAddress valueForKey:@"phone"]];
                    userLabel.textColor = [UIColor blackColor];
                    userLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:16.0];
                    labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                    [cell addSubview:userImageView];
                    [cell addSubview:userLabel];
                    heightCell += labelHeight + 5;
                }
                // User Email
                if([self.billingAddress valueForKey:@"email"]){
                    imgUser = @"theme01_email";
                    userImage = [[UIImage imageNamed:imgUser] imageWithColor:THEME01_SUB_PART_COLOR];
                    userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 7, 13, 10)];
                    userImageView.image = userImage;
                    userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                    userLabel.text = [NSString stringWithFormat:@"%@", [self.billingAddress valueForKey:@"email"]];
                    userLabel.textColor = [UIColor blackColor];
                    userLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:16.0];
                    labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                    [cell addSubview:userImageView];
                    [cell addSubview:userLabel];
                    heightCell += labelHeight + 5;
                }
            }
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                for (UIView *view in cell.subviews) {
                    if ([view isKindOfClass:[UILabel class]]) {
                        UILabel *label = (UILabel *)view;
                        [label setTextAlignment:NSTextAlignmentRight];
                    }
                }
            }
        }else if(simiRow.identifier == ORDER_VIEW_SHIPPING_ADDRESS){
            if(cell == nil){
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_SHIPPING_ADDRESS];
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
            CGFloat heightCell = 13;
            int imageX = 18;
            int addressX = 40;
            int addressWidth = 280;
            int addressHeight = 20;
            int editImageX = 290;
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                imageX = 290;
                addressX = 10;
                addressWidth = 270;
                editImageX = 10;
            }
            if (self.shippingAddress != nil) {
                //User Name
                NSString *imgUser = @"theme01_user";
                UIImage *userImage = [[UIImage imageNamed:imgUser] imageWithColor:THEME01_SUB_PART_COLOR];
                UIImageView *userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 5, 13, 13)];
                userImageView.image = userImage;
                NSString *imgEdit = @"theme01_address_edit";
                UIImage *editImage = [[UIImage imageNamed:imgEdit] imageWithColor:THEME01_SUB_PART_COLOR];
                UIImageView *editImageView = [[UIImageView alloc]initWithFrame:CGRectMake(editImageX,  heightCell - 7, 14, 16)];
                editImageView.image = editImage;
                UILabel *userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                userLabel.text = [NSString stringWithFormat:@"%@", [self.shippingAddress valueForKey:@"name"]];
                userLabel.textColor = [UIColor blackColor];
                userLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:16.0];
                CGFloat labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                [cell addSubview:userImageView];
                [cell addSubview:editImageView];
                [cell addSubview:userLabel];
                heightCell += labelHeight + 5;
                // User Address
                if([self.shippingAddress valueForKey:@"street"]){
                    imgUser = @"theme01_street";
                    userImage = [[UIImage imageNamed:imgUser] imageWithColor:THEME01_SUB_PART_COLOR];
                    userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 5, 12, 16)];
                    userImageView.image = userImage;
                    userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth - 5, addressHeight)];
                    userLabel.text = [NSString stringWithFormat:@"%@", [self.shippingAddress valueForKey:@"street"]];
                    if([self.shippingAddress valueForKey:@"city"]){
                        userLabel.text = [userLabel.text stringByAppendingString:[NSString stringWithFormat:@", %@", [self.shippingAddress valueForKey:@"city"]]];
                    }
                    if([self.shippingAddress valueForKey:@"state_name"] &&
                       ![[self.shippingAddress valueForKey:@"state_name"] isKindOfClass:[NSNull class]] && [NSString stringWithFormat:@"%@", [self.shippingAddress valueForKey:@"state_name"]].length > 0){
                        userLabel.text = [userLabel.text stringByAppendingString:[NSString stringWithFormat:@", %@", [self.shippingAddress valueForKey:@"state_name"]]];
                    }
                    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
                        NSRange stringRange = {0, MIN([userLabel.text length], 68)};
                        stringRange = [userLabel.text rangeOfComposedCharacterSequencesForRange:stringRange];
                        userLabel.text = [userLabel.text substringWithRange:stringRange];
                        if([userLabel.text length] > 68){
                            userLabel.text = [userLabel.text stringByAppendingString:@"..."];
                        }
                    }
                    userLabel.textColor = [UIColor blackColor];
                    userLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:16.0];
                    labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                    [userLabel resizLabelToFit];
                    CGRect frame = userLabel.frame;
                    if(frame.size.height > 22){
                        frame.size.height = 40;
                        userLabel.numberOfLines = 2;
                        heightCell += frame.size.height;
                    }else{
                        heightCell += labelHeight;
                    }
                    [cell addSubview:userImageView];
                    [cell addSubview:userLabel];
                }
                UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                addressLabel.text = @"";
                if([self.shippingAddress valueForKey:@"zip"]){
                    if(![addressLabel.text isEqualToString:@""])
                        addressLabel.text = [addressLabel.text stringByAppendingString:@", "];
                    addressLabel.text = [addressLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@", [self.shippingAddress valueForKey:@"zip"]]];
                }
                if([self.billingAddress valueForKey:@"country_name"]){
                    if(![addressLabel.text isEqualToString:@""])
                        addressLabel.text = [addressLabel.text stringByAppendingString:@", "];
                    addressLabel.text =[addressLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@", [self.shippingAddress valueForKey:@"country_name"]]];
                }
                addressLabel.textColor = [UIColor blackColor];
                addressLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:16.0];
                labelHeight = [addressLabel.text sizeWithFont:addressLabel.font].height;
                [cell addSubview:addressLabel];
                heightCell += labelHeight + 5;
                // User Phone
                if([self.shippingAddress valueForKey:@"phone"]){
                    imgUser = @"theme01_phone";
                    userImage = [[UIImage imageNamed:imgUser] imageWithColor:THEME01_SUB_PART_COLOR];
                    userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 5, 13, 13)];
                    userImageView.image = userImage;
                    userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                    userLabel.text = [NSString stringWithFormat:@"%@", [self.shippingAddress valueForKey:@"phone"]];
                    userLabel.textColor = [UIColor blackColor];
                    userLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:16.0];
                    labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                    [cell addSubview:userImageView];
                    [cell addSubview:userLabel];
                    heightCell += labelHeight + 5;
                }
                // User Email
                if([self.shippingAddress valueForKey:@"email"]){
                    imgUser = @"theme01_email";
                    userImage = [[UIImage imageNamed:imgUser] imageWithColor:THEME01_SUB_PART_COLOR];
                    userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 7, 13, 10)];
                    userImageView.image = userImage;
                    userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                    userLabel.text = [NSString stringWithFormat:@"%@", [self.shippingAddress valueForKey:@"email"]];
                    userLabel.textColor = [UIColor blackColor];
                    userLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:16.0];
                    labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                    [cell addSubview:userImageView];
                    [cell addSubview:userLabel];
                    heightCell += labelHeight + 5;
                }
            }
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                for (UIView *view in cell.subviews) {
                    if ([view isKindOfClass:[UILabel class]]) {
                        UILabel *label = (UILabel *)view;
                        [label setTextAlignment:NSTextAlignmentRight];
                    }
                }
            }
        }
    }else if ([simiSection.identifier isEqualToString:ORDER_PAYMENT_SECTION])
    {
        if(simiRow.identifier == ORDER_VIEW_PAYMENT_METHOD){
            NSString *PaymentShowTypeSDKCell = [NSString stringWithFormat:@"PaymentShowTypeSDKCell_%d",(int)indexPath.row];
            NSString *PaymentShowTypeNoneCell = [NSString stringWithFormat:@"PaymentShowTypeNoneCell_%d",(int)indexPath.row];
            NSString *PaymentShowTypeCreditCardCell = [NSString stringWithFormat:@"PaymentShowTypeCreditCardCell_%d",(int)indexPath.row];
            SimiModel *payment = [self.paymentCollection objectAtIndex:indexPath.row];
            
            NSString *paymentTitle = @"";
            UILabel *lblContentPayment = [[UILabel alloc]initWithFrame:CGRectMake(40, 30, 260, 20)];
            [lblContentPayment setFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:12]];
            
            if ([[payment valueForKey:@"show_type"] integerValue] == PaymentShowTypeNone) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PaymentShowTypeNoneCell];
                paymentTitle = [payment valueForKey:@"title"];
                if (![[payment valueForKey:@"content"] isKindOfClass:[NSNull class]] && indexPath.row == self.selectedPayment) {
                    lblContentPayment.text = [payment valueForKey:@"content"];
                    [cell addSubview:lblContentPayment];
                    [lblContentPayment  resizLabelToFit];
                    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                        [lblContentPayment setTextAlignment:NSTextAlignmentRight];
                    }
                }
            }else if ([[payment valueForKey:@"show_type"] integerValue] == PaymentShowTypeCreditCard){
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PaymentShowTypeCreditCardCell];
                paymentTitle = [payment valueForKey:@"title"];
                if (indexPath.row == self.selectedPayment) {
                    //  Liam Update Credit Card
                    for (int i = 0; i < self.creditCards.count; i++) {
                        SimiModel *creditCard = [self.creditCards objectAtIndex:i];
                        if ([[creditCard valueForKey:@"payment_method"] isEqualToString:[payment valueForKey:@"payment_method"]]) {
                            if ([[creditCard valueForKey:hasData]boolValue]) {
                                lblContentPayment.text = [NSString stringWithFormat:@"****%@", [[creditCard valueForKey:@"card_number"] substringWithRange:NSMakeRange([[creditCard valueForKey:@"card_number"] length] - 4, 4)]];
                                [cell addSubview:lblContentPayment];
                                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                                    [lblContentPayment setTextAlignment:NSTextAlignmentRight];
                                }
                            }
                            break;
                        }
                    }
                    //  End Update Credit Card
                }
            }else{
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PaymentShowTypeSDKCell];
                paymentTitle = [payment valueForKey:@"title"];
            }
            
            NSString *optionImageName = @"";
            if(self.selectedPayment != indexPath.row){
                optionImageName = @"theme1_option_round";
            }else{
                optionImageName = @"theme1_option_round_checked";
            }
            UILabel *paymentTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 5, 260, 30)];
            paymentTitleLabel.text = paymentTitle;
            paymentTitleLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:16.0];
            paymentTitleLabel.textColor = [UIColor blackColor];
            [cell addSubview:paymentTitleLabel];
            cell.accessoryType = UITableViewCellAccessoryNone;
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [paymentTitleLabel setTextAlignment:NSTextAlignmentRight];
            }
            
            
            UIImage *optionImage = [[UIImage imageNamed:optionImageName] imageWithColor:THEME01_SUB_PART_COLOR];
            UIImageView *optionImageView = [[UIImageView alloc]initWithFrame:CGRectMake(18, 15, 12, 12)];
            optionImageView.image = optionImage;
            cell.textLabel.text = @" ";
            [optionImageView removeFromSuperview];
            [cell addSubview:optionImageView];
        }
    }else if([simiSection.identifier isEqualToString:ORDER_TOTALS_SECTION])
    {
        if(simiRow.identifier == ORDER_VIEW_CART){
            //Init cell
            SimiCartModel *item = [self.cart objectAtIndex:indexPath.row];
            NSString *CartCellIdentifier = [NSString stringWithFormat:@"%@_%@", ORDER_VIEW_CART, [item valueForKey:@"cart_item_id"]];
            cell = [tableView dequeueReusableCellWithIdentifier:CartCellIdentifier];
            if (cell == nil) {
                UINib *nib = [UINib nibWithNibName:@"SCCartCell" bundle:nil];
                [tableView registerNib:nib forCellReuseIdentifier:CartCellIdentifier];
                cell = [tableView dequeueReusableCellWithIdentifier:CartCellIdentifier];
                if ([item valueForKeyPath:@"cart_item_name"] == nil) {
                    NSString *cartItemName = [item valueForKeyPath:@"product_name"];
                    for (NSDictionary *option in [item valueForKeyPath:@"options"]) {
                        cartItemName = [NSString stringWithFormat:@"%@, %@", cartItemName, [option valueForKeyPath:@"option_value"]];
                    }
                    [item setValue:cartItemName forKeyPath:@"cart_item_name"];
                }
                [(SCCartCell*)cell setName:[item valueForKey:@"product_name"]];
                [(SCCartCell*)cell setPrice:[item valueForKey:@"product_price"]];
                [(SCCartCell*)cell setQty:[NSString stringWithFormat:@"%@", [item valueForKey:@"product_qty"]]];
                NSString *imagePath = [item valueForKey:@"product_image"];
                [(SCCartCell*)cell setImagePath:imagePath];
                ((SCCartCell*)cell).qtyTextField.userInteractionEnabled = NO;
                ((SCCartCell*)cell).qtyTextField.backgroundColor = [UIColor clearColor];
                [((SCCartCell*)cell).deleteButton removeFromSuperview];
                
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                cell.userInteractionEnabled = NO;
            }
            //Set cell data
        }else if(simiRow.identifier == ORDER_VIEW_TOTAL){
            
            cell = [[SCOrderFeeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_TOTAL];
            [(SCOrderFeeCell *)cell setData:self.cartPrices];
            cell.userInteractionEnabled = NO;
        }
    }else if([simiSection.identifier isEqualToString:ORDER_SHIPMENT_SECTION])
    {
        if(simiRow.identifier == ORDER_VIEW_SHIPPING_METHOD){
            cell = [tableView dequeueReusableCellWithIdentifier:ORDER_VIEW_SHIPPING_METHOD];
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ORDER_VIEW_SHIPPING_METHOD];
            }
            cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", SCLocalizedString(@"Shipping Method"), [[self.shippingCollection objectAtIndex:self.selectedShippingMedthod] valueForKey:@"s_method_title"]];
            NSString *methodName = [[self.shippingCollection objectAtIndex:self.selectedShippingMedthod] valueForKey:@"s_method_name"];
            if (![methodName isKindOfClass:[NSNull class]]) {
                if (methodName.length > 0){
                    cell.detailTextLabel.text = [[self.shippingCollection objectAtIndex:self.selectedShippingMedthod] valueForKey:@"s_method_name"];
                }
            }
            [cell.textLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_BOLD size:16]];
            [cell.textLabel setTextColor:[UIColor blackColor]];
            [cell.detailTextLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_BOLD size:16]];
            [cell.detailTextLabel setTextColor:[UIColor blackColor]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }else if ([simiSection.identifier isEqualToString:ORDER_COUPON_SECTION])
    {
        if(simiRow.identifier == ORDER_VIEW_COUPONCODE){
            cell = [tableView dequeueReusableCellWithIdentifier:ORDER_VIEW_COUPONCODE];
            if (cell == nil) {
                cell =  [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_COUPONCODE];
                if (self.textFieldCouponCode == nil) {
                    self.textFieldCouponCode = [[UITextField alloc]initWithFrame: cell.bounds];
                    CGRect frame = self.textFieldCouponCode.frame;
                    frame.origin.x = 15;
                    frame.size.width = cell.frame.size.width - 30;
                    self.textFieldCouponCode.frame = frame;
                    self.textFieldCouponCode.placeholder = SCLocalizedString(@"Enter a coupon code");
                    self.textFieldCouponCode.autocorrectionType = UITextAutocorrectionTypeNo;
                    self.textFieldCouponCode.delegate = self;
                    [self.textFieldCouponCode setClearButtonMode:UITextFieldViewModeUnlessEditing];
                    self.textFieldCouponCode.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    SimiToolbar *toolBar = [[SimiToolbar alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH, 40)];
                    toolBar.delegate = self;
                    self.textFieldCouponCode.inputAccessoryView.backgroundColor = [UIColor blackColor];
                    self.textFieldCouponCode.inputAccessoryView = toolBar;
                    [self.textFieldCouponCode setFont:[UIFont fontWithName:THEME01_FONT_NAME_BOLD size:16]];
                    [self.textFieldCouponCode setTextColor:[UIColor blackColor]];
                    
                    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                        [self.textFieldCouponCode setTextAlignment:NSTextAlignmentRight];
                    }
                }
                [cell addSubview:self.textFieldCouponCode];
            }
            if (![[[self.order valueForKey:@"fee"] valueForKey:@"coupon_code"] isKindOfClass:[NSNull class]]){
                self.textFieldCouponCode.text = [[self.order valueForKey:@"fee"] valueForKey:@"coupon_code"];
            }
        }
    }else if([simiSection.identifier isEqualToString:ORDER_TERMS_SECTION])
    {
        if(simiRow.identifier == ORDER_VIEW_TERM){
            if([self.termAndConditions count] > 0){
                if(cell == nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_TERM];
                }
                cell.accessoryType = UITableViewCellAccessoryNone;
                NSDictionary *term = [self.termAndConditions objectAtIndex:indexPath.row];
                if([term objectForKey:@"name"]){
                    UILabel *termLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 7, CGRectGetWidth(self.view.frame) - 30, 30)];
                    termLabel.text = [[term objectForKey:@"name"] stringByAppendingString:@"..."];
                    [termLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:16]];
                    [termLabel setTextColor:[UIColor blackColor]];
                    [termLabel resizLabelToFit];
                    termLabel.numberOfLines = 2;
                    CGFloat labelWidth = [termLabel.text sizeWithFont:termLabel.font].width;
                    CGFloat labelHeight = [termLabel.text sizeWithFont:termLabel.font].height;
                    int imgMoreX = labelWidth + 13;
                    int imgMoreY = labelHeight - 1;
                    if(labelWidth > CGRectGetWidth(self.view.frame) - 37){
                        imgMoreX = labelWidth - CGRectGetWidth(self.view.frame) + 40;
                        imgMoreY += labelHeight - 1;
                    }
                    NSString *imgMore = @"theme1_viewmore";
                    UIImage *moreImage = [UIImage imageNamed:imgMore];
                    UIImageView *moreImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imgMoreX, imgMoreY, 5, 5)];
                    moreImageView.image = moreImage;
                    [cell addSubview:termLabel];
                    [cell addSubview:moreImageView];
                }
                SimiCheckbox *checkbox = [[SimiCheckbox alloc] initWithTitle:[term objectForKey:@"title"]];
                [checkbox.titleLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_BOLD size:16]];
                [checkbox.titleLabel setTextColor:[UIColor blackColor]];
                checkbox.strokeColor = [UIColor orangeColor];
                checkbox.frame = CGRectMake(10, 45, SCREEN_WIDTH - 30, 35);
                if ([[term objectForKey:@"checked"] boolValue]) {
                    [checkbox setCheckState:M13CheckboxStateChecked];
                }
                checkbox.tag = indexPath.row;
                [cell addSubview:checkbox];
                [checkbox addTarget:self action:@selector(toggleCheckBox:) forControlEvents:UIControlEventValueChanged];
            }
        }
    }else if([simiSection.identifier isEqualToString:ORDER_BUTTON_SECTION])
    {
        if(simiRow.identifier == ORDER_VIEW_PLACE){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PlaceOrderCell"];
            CGRect frame = cell.frame;
            frame.origin.x = 10;
            frame.origin.y = 10;
            frame.size.width = cell.frame.size.width - 20;
            frame.size.height = 40;
            UIButton *button = [[UIButton alloc] initWithFrame: frame];
            [button setBackgroundColor:THEME_COLOR];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:18];
            [button.layer setCornerRadius:5.0f];
            [button.layer setMasksToBounds:YES];
            [button setAdjustsImageWhenHighlighted:YES];
            [button setAdjustsImageWhenDisabled:YES];
            [button setTitle:SCLocalizedString(@"Place Now") forState:UIControlStateNormal];
            [button addTarget:self action:@selector(placeOrder) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    if (cell == nil) {
        cell = [UITableViewCell new];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedOrderCell-After" object:simiRow userInfo:@{@"tableView": tableView, @"indexPath": indexPath, @"cell": cell}];
    return cell;
}

- (void)toggleCheckBox:(SimiCheckbox *)sender
{
    NSMutableDictionary *term = [self.termAndConditions objectAtIndex:sender.tag];
    if ([sender checkState] == M13CheckboxStateChecked) {
        [term setValue:[NSNumber numberWithBool:YES] forKey:@"checked"];
    } else {
        [term removeObjectForKey:@"checked"];
    }
    [self.termAndConditions replaceObjectAtIndex:sender.tag withObject:term];
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [self.orderTable objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectOrderCellAtIndexPath" object:simiSection userInfo:@{@"tableView": tableView, @"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    
    if(simiRow.identifier == ORDER_VIEW_BILLING_ADDRESS){
        self.isSelectBillingAddress = YES;
        SCAddressViewController *nextController = [[SCAddressViewController alloc]init];
        [nextController setDelegate:self];
        [nextController setIsGetOrderAddress:YES];
        [self.navigationController pushViewController:nextController animated:YES];
    }if(simiRow.identifier == ORDER_VIEW_SHIPPING_ADDRESS){
        self.isSelectBillingAddress = NO;
        SCAddressViewController *nextController = [[SCAddressViewController alloc]init];
        [nextController setDelegate:self];
        [nextController setIsGetOrderAddress:YES];
        [self.navigationController pushViewController:nextController animated:YES];
    }else if(simiRow.identifier == ORDER_VIEW_PAYMENT_METHOD){
        self.selectedPayment  = indexPath.row;
        SimiModel *payment = [self.paymentCollection objectAtIndex:self.selectedPayment];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectPaymentMethod" object:payment userInfo:@{@"payment": payment}];
        if ([[payment valueForKey:@"show_type"] integerValue] == PaymentShowTypeCreditCard) {
            NSArray *creditCardTypes = [payment valueForKey:@"cc_types"];
            if (creditCardTypes != nil) {
                //   Liam Update Credit Card
                SCCreditCardViewController *nextController = [[SCCreditCardViewController alloc] init];
                nextController.delegate = self;
                for (int i = 0; i < self.creditCards.count; i++) {
                    SimiModel *creditCard = [self.creditCards objectAtIndex:i];
                    if ([[creditCard valueForKey:@"payment_method"] isEqualToString:[payment valueForKey:@"payment_method"]]) {
                        if ([[creditCard valueForKey:hasData]boolValue]) {
                            nextController.defaultCard = [[NSDictionary alloc]initWithObjectsAndKeys:
                                                          [creditCard valueForKey:@"card_type"],@"card_type",
                                                          [creditCard valueForKey:@"card_number"],@"card_number",
                                                          [creditCard valueForKey:@"expired_month"], @"expired_month",
                                                          [creditCard valueForKey:@"expired_year"], @"expired_year",
                                                          [creditCard valueForKey:@"cc_id"] , @"cc_id", nil];
                        }
                        nextController.creditCardList = [payment valueForKey:@"cc_types"];
                        nextController.isUseCVV = [[payment valueForKey:@"useccv"] boolValue];
                    }
                }
                //  End Update Credit Card
                [self.navigationController pushViewController:nextController animated:YES];
            }
        }else if ([[payment valueForKey:@"show_type"] integerValue] == PaymentShowTypeSDK){
            
        }else{
            //hainh
            if([self.isReloadPayment isEqualToString:@"1"]){
                [self savePaymentMethod:payment];
            }
        }
        _orderTable = nil;
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:[self.orderTable getSectionIndexByIdentifier:ORDER_PAYMENT_SECTION]] withRowAnimation:UITableViewRowAnimationNone];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else if(simiRow.identifier == ORDER_VIEW_SHIPPING_METHOD){
        SCShippingViewController *nextController = [[SCShippingViewController alloc]init];
        [nextController setMethodCollection: self.shippingCollection];
        [nextController setSelectedMethodRow:self.selectedShippingMedthod];
         nextController.delegate = self;
        [self.navigationController pushViewController:nextController animated:YES];
    }else if(simiRow.identifier == ORDER_VIEW_TERM){
        // Show term and condition
        SCTermConditionViewController *termView = [[SCTermConditionViewController alloc] init];
        termView.termAndCondition = [self.termAndConditions objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:termView animated:YES];
    }
}

#pragma mark SCShipping Delegate
- (void)didSelectShippingMethodAtIndex:(NSInteger)index{
    self.isSavingShippingMethod = YES;
    self.selectedShippingMedthod = index;
    SimiShippingModel *method = (SimiShippingModel *)[self.shippingCollection objectAtIndex:self.selectedShippingMedthod];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSaveShippingMethod:) name:@"DidSaveShippingMethod" object:self.order];
    [self startLoadingData];
    [self.order selectShippingMethod:method];
}

#pragma mark Place Order
- (void)placeOrder{
    if (self.selectedPayment >= 0) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        if ([self.termAndConditions count]) {
            self.accept = NO;
            for (NSDictionary *term in self.termAndConditions) {
                if (![[term objectForKey:@"checked"] boolValue]) {
                    // Scroll to term and condition
                    [self.tableViewOrder scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.orderTable getSectionIndexByIdentifier:ORDER_TERMS_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    [self.tableViewOrder deselectRowAtIndexPath:[self.tableViewOrder indexPathForSelectedRow] animated:YES];
                    // Show alert
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Please agree to all the terms and conditions before placing the order.") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil];
                    [alertView show];
                    return;
                }
            }
            self.accept = YES;
        }
        if (self.accept) {
            [params setValue:@"1" forKey:@"condition"];
        }else{
            [params setValue:@"0" forKey:@"condition"];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder" object:self.order];
        [params setValue:[[self.paymentCollection objectAtIndex:self.selectedPayment] valueForKey:@"payment_method"] forKey:@"payment_method"];
        
        // Liam Update Credit Card
        SimiModel *payment = [self.paymentCollection objectAtIndex:self.selectedPayment];
        for (int i = 0; i < self.creditCards.count; i++) {
            SimiModel *creditCard = [self.creditCards objectAtIndex:i];
            if ([[creditCard valueForKey:@"payment_method"] isEqualToString:[payment valueForKey:@"payment_method"]]) {
                for (NSString *key in [creditCard allKeys]) {
                    [params setValue:[creditCard valueForKey:key] forKey:key];
                }
                break;
            }
        }
        [params removeObjectForKey:hasData];
        //  End Update Credit Card
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SCOrderViewController-BeforePlaceOrder" object:self userInfo:@{@"order":self.order,@"payment":payment}];
        if (self.isDiscontinue) {
            self.isDiscontinue = NO;
            return;
        }
        [self startLoadingData];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [self.order placeOrderWithParams:params];
        self.tabBarController.tabBar.userInteractionEnabled = NO;
    }else{
        // Scroll to payment
        [self.tableViewOrder scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.orderTable getSectionIndexByIdentifier:ORDER_PAYMENT_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [self.tableViewOrder deselectRowAtIndexPath:[self.tableViewOrder indexPathForSelectedRow] animated:YES];
        // Show alert
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Please choose a payment method") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)keyboardWasShown
{
    UIEdgeInsets contentInsets = self.tableViewOrder.contentInset;
    contentInsets.bottom = 270;
    self.tableViewOrder.contentInset = contentInsets;
    self.tableViewOrder.scrollIndicatorInsets = contentInsets;
}

- (void)hideKeyboard{
    UIEdgeInsets contentInsets = self.tableViewOrder.contentInset;
    contentInsets.bottom = 0;
    self.tableViewOrder.contentInset = contentInsets;
    self.tableViewOrder.scrollIndicatorInsets = contentInsets;
}

@end
