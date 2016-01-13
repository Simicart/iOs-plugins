//
//  ZThemeOrderViewControllerPad.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 6/1/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeOrderViewControllerPad.h"

#import <SimiCartBundle/SCOrderFeeCell.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>

#import "ZThemeWorker.h"


static int TF_COUPON_CODE = 1;
static int AGREEMENT = 4;
static int AFTERPLACEORDER = 100;


@interface ZThemeOrderViewControllerPad ()
{
    BOOL accept;
    BOOL isSelectBillingAddress;
}

@end

@implementation ZThemeOrderViewControllerPad

@synthesize tableViewOrder, order = _order, numberOfRowInSection, numberOfSection;
@synthesize shippingAddress = _shippingAddress;
@synthesize billingAddress = _billingAddress, cart = _cart;
@synthesize cartPrices = _cartPrices, paymentCollection = _paymentCollection;
@synthesize isRequestOrderConfig = _isRequestOrderConfig, shippingCollection = _shippingCollection, selectedShippingMedthod = _selectedShippingMedthod;
@synthesize textFieldCouponCode = _textFieldCouponCode, creditCardAuthorize, creditCardSaved, selectedPayment = _selectedPayment;
@synthesize termAndConditions = _termAndConditions, heightRow = _heightRow, isSavingShippingMethod, accept;
@synthesize isSelectBillingAddress;

#pragma mark Main Method
-(void)viewDidLoadBefore
{
    [self setToSimiView];
    [self getOrderConfig];
    _selectedPayment = -1;
    self.isReloadPayment = [NSString stringWithFormat:@"%@",[[[[SimiGlobalVar sharedInstance]store] valueForKey:@"store_config"]valueForKey:@"is_reload_payment_method"]];
    self.title = [SCLocalizedString(@"Review Order") uppercaseString];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    if (_tableLeft == nil) {
        _tableLeft = [[UITableView alloc]initWithFrame:CGRectMake(0, 80, 500, 670) style:UITableViewStyleGrouped];
        _tableLeft.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableLeft.showsVerticalScrollIndicator = NO;
        _tableLeft.showsHorizontalScrollIndicator = NO;
        _tableLeft.dataSource = self;
        _tableLeft.delegate = self;
        _tableLeft.tag = 1000;
        [self.view addSubview:_tableLeft];
        _tableLeft.hidden = YES;
    }
    
    if (_tableRight == nil) {
        _tableRight = [[UITableView alloc]initWithFrame:CGRectMake(524, 80, 500, 670) style:UITableViewStyleGrouped];
        _tableRight.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableRight.showsHorizontalScrollIndicator = NO;
        _tableRight.showsVerticalScrollIndicator = NO;
        _tableRight.dataSource = self;
        _tableRight.delegate = self;
        _tableRight.tag = 2000;
        [self.view addSubview:_tableRight];
        _tableRight.hidden = YES;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configOrderTableLeft
{
    _orderTableLeft = [SimiTable new];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCOrderViewController-InitLeftTableBefore" object:_orderTableLeft];
    [_orderTableLeft addSectionWithIdentifier:ORDER_ADDRESS_SECTION];
    [_orderTableLeft addSectionWithIdentifier:ORDER_PAYMENT_SECTION];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCOrderViewController-InitLeftTableAfter" object:_orderTableLeft];
}


- (void)configOrderTableRight
{
    _orderTableRight = [SimiTable new];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCOrderViewController-InitRightTableBefore" object:_orderTableRight];
    [_orderTableRight addSectionWithIdentifier:ORDER_TOTALS_SECTION];
    [_orderTableRight addSectionWithIdentifier:ORDER_SHIPMENT_SECTION];
    [_orderTableRight addSectionWithIdentifier:ORDER_COUPON_SECTION];
    [_orderTableRight addSectionWithIdentifier:ORDER_TERMS_SECTION];
    [_orderTableRight addSectionWithIdentifier:ORDER_BUTTON_SECTION];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCOrderViewController-InitRightTableAfter" object:_orderTableRight];
}

#pragma mark TableView Datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedOrderCell-Before" object:cell];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return cell;
    }
    
    SimiSection *simiSection;
    if (tableView.tag == 1000) {
        if (self.orderTableLeft) {
            simiSection = (SimiSection*)[self.orderTableLeft objectAtIndex:indexPath.section];
            if ([simiSection.identifier isEqualToString:ORDER_ADDRESS_SECTION]) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddressCell"];
                cell.accessoryType = UITableViewCellAccessoryNone;
                if (self.shippingCollection.count > 0) {
                    switch (indexPath.row) {
                        case 0:{
                            CGFloat heightCell = 15;
                            int imageX = 18;
                            int addressX = 60;
                            int addressWidth = 400;
                            int addressHeight = 30;
                            int editImageX = 410;
                            //  Liam Update RTL
                            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                                imageX = 470;
                                addressX = 50;
                                addressWidth = 400;
                                editImageX = 15;
                            }
                            //  End RTL
                            if (_billingAddress != nil) {
                                //User Name
                                NSString *imgUser = @"Ztheme_user";
                                UIImage *userImage = [[UIImage imageNamed:imgUser] imageWithColor:ZTHEME_SUB_PART_COLOR];
                                UIImageView *userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 6, 18, 18)];
                                userImageView.image = userImage;
                                NSString *imgEdit = @"Ztheme_address_edit";
                                UIImage *editImage = [[UIImage imageNamed:imgEdit]imageWithColor:ZTHEME_SUB_PART_COLOR];
                                UIImageView *editImageView = [[UIImageView alloc]initWithFrame:CGRectMake(editImageX,  heightCell, 23, 23)];
                                editImageView.image = editImage;
                                UILabel *userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                                userLabel.text = [NSString stringWithFormat:@"%@", [_billingAddress valueForKey:@"name"]];
                                userLabel.textColor = [UIColor blackColor];
                                userLabel.font = [UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:18.0];
                                CGFloat labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                                [cell addSubview:userImageView];
                                [cell addSubview:editImageView];
                                [cell addSubview:userLabel];
                                heightCell += labelHeight + 5;
                                // User Address
                                if([_billingAddress valueForKey:@"street"]){
                                    imgUser = @"Ztheme_street";
                                    userImage = [[UIImage imageNamed:imgUser] imageWithColor:ZTHEME_SUB_PART_COLOR];
                                    userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 3.5, 16, 23)];
                                    userImageView.image = userImage;
                                    userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                                    userLabel.text = [NSString stringWithFormat:@"%@", [_billingAddress valueForKey:@"street"]];
                                    if([_billingAddress valueForKey:@"city"]){
                                        userLabel.text = [userLabel.text stringByAppendingString:[NSString stringWithFormat:@", %@", [_billingAddress valueForKey:@"city"]]];
                                    }
                                    if([_billingAddress valueForKey:@"state_name"] &&
                                       ![[_billingAddress valueForKey:@"state_name"] isKindOfClass:[NSNull class]] && [NSString stringWithFormat:@"%@", [_billingAddress valueForKey:@"state_name"]].length > 0){
                                        userLabel.text = [userLabel.text stringByAppendingString:[NSString stringWithFormat:@", %@", [_billingAddress valueForKey:@"state_name"]]];
                                    }
                                    userLabel.textColor = [UIColor blackColor];
                                    userLabel.font = [UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:18.0];
                                    labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                                    [userLabel resizLabelToFit];
                                    CGRect frame = userLabel.frame;
                                    if(frame.size.height > 30){
                                        frame.size.height = 60;
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
                                if([_billingAddress valueForKey:@"zip"]){
                                    if(![addressLabel.text isEqualToString:@""])
                                        addressLabel.text = [addressLabel.text stringByAppendingString:@", "];
                                    addressLabel.text = [addressLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@", [_billingAddress valueForKey:@"zip"]]];
                                }
                                if([_billingAddress valueForKey:@"country_name"]){
                                    if(![addressLabel.text isEqualToString:@""])
                                        addressLabel.text = [addressLabel.text stringByAppendingString:@", "];
                                    addressLabel.text =[addressLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@", [_billingAddress valueForKey:@"country_name"]]];
                                }
                                addressLabel.textColor = [UIColor blackColor];
                                addressLabel.font = [UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:18.0];
                                labelHeight = [addressLabel.text sizeWithFont:addressLabel.font].height;
                                [cell addSubview:addressLabel];
                                heightCell += labelHeight + 5;
                                // User Phone
                                if([_billingAddress valueForKey:@"phone"]){
                                    imgUser = @"Ztheme_phone";
                                    userImage = [[UIImage imageNamed:imgUser] imageWithColor:ZTHEME_SUB_PART_COLOR];
                                    userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 6, 18, 18)];
                                    userImageView.image = userImage;
                                    userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                                    userLabel.text = [NSString stringWithFormat:@"%@", [_billingAddress valueForKey:@"phone"]];
                                    userLabel.textColor = [UIColor blackColor];
                                    userLabel.font = [UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:18.0];
                                    labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                                    [cell addSubview:userImageView];
                                    [cell addSubview:userLabel];
                                    heightCell += labelHeight + 5;
                                }
                                // User Email
                                if([_billingAddress valueForKey:@"email"]){
                                    imgUser = @"Ztheme_email";
                                    userImage = [[UIImage imageNamed:imgUser] imageWithColor:ZTHEME_SUB_PART_COLOR];
                                    userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 9, 18, 11)];
                                    userImageView.image = userImage;
                                    userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                                    userLabel.text = [NSString stringWithFormat:@"%@", [_billingAddress valueForKey:@"email"]];
                                    userLabel.textColor = [UIColor blackColor];
                                    userLabel.font = [UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:18.0];
                                    labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                                    [cell addSubview:userImageView];
                                    [cell addSubview:userLabel];
                                    heightCell += labelHeight + 5;
                                }
                            }
                            //  Liam Update RTL
                            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                                for (UIView *view in cell.subviews) {
                                    if ([view isKindOfClass:[UILabel class]]) {
                                        UILabel *label = (UILabel *)view;
                                        [label setTextAlignment:NSTextAlignmentRight];
                                    }
                                }
                            }
                            //  End RTL
                        }
                            break;
                        case 1:{
                            CGFloat heightCell = 15;
                            int imageX = 18;
                            int addressX = 60;
                            int addressWidth = 400;
                            int addressHeight = 30;
                            int editImageX = 410;
                            //  Liam Update RTL
                            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                                imageX = 470;
                                addressX = 50;
                                addressWidth = 400;
                                editImageX = 15;
                            }
                            //  End RTL
                            if (_shippingAddress != nil) {
                                //User Name
                                NSString *imgUser = @"Ztheme_user";
                                UIImage *userImage = [[UIImage imageNamed:imgUser] imageWithColor:ZTHEME_SUB_PART_COLOR];
                                UIImageView *userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 6, 18, 18)];
                                userImageView.image = userImage;
                                NSString *imgEdit = @"Ztheme_address_edit";
                                UIImage *editImage = [[UIImage imageNamed:imgEdit] imageWithColor:ZTHEME_SUB_PART_COLOR];
                                UIImageView *editImageView = [[UIImageView alloc]initWithFrame:CGRectMake(editImageX,  heightCell, 23, 23)];
                                editImageView.image = editImage;
                                UILabel *userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                                userLabel.text = [NSString stringWithFormat:@"%@", [_shippingAddress valueForKey:@"name"]];
                                userLabel.textColor = [UIColor blackColor];
                                userLabel.font = [UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:18.0];
                                CGFloat labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                                [cell addSubview:userImageView];
                                [cell addSubview:editImageView];
                                [cell addSubview:userLabel];
                                heightCell += labelHeight + 5;
                                // User Address
                                if([_shippingAddress valueForKey:@"street"]){
                                    imgUser = @"Ztheme_street";
                                    userImage = [[UIImage imageNamed:imgUser] imageWithColor:ZTHEME_SUB_PART_COLOR];
                                    userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 3.5, 16, 23)];
                                    userImageView.image = userImage;
                                    userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                                    userLabel.text = [NSString stringWithFormat:@"%@", [_shippingAddress valueForKey:@"street"]];
                                    if([_shippingAddress valueForKey:@"city"]){
                                        userLabel.text = [userLabel.text stringByAppendingString:[NSString stringWithFormat:@", %@", [_shippingAddress valueForKey:@"city"]]];
                                    }
                                    if([_shippingAddress valueForKey:@"state_name"] &&
                                       ![[_shippingAddress valueForKey:@"state_name"] isKindOfClass:[NSNull class]] && [NSString stringWithFormat:@"%@", [_shippingAddress valueForKey:@"state_name"]].length > 0){
                                        userLabel.text = [userLabel.text stringByAppendingString:[NSString stringWithFormat:@", %@", [_shippingAddress valueForKey:@"state_name"]]];
                                    }
                                    userLabel.textColor = [UIColor blackColor];
                                    userLabel.font = [UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:18.0];
                                    labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                                    [userLabel resizLabelToFit];
                                    CGRect frame = userLabel.frame;
                                    if(frame.size.height > 30){
                                        frame.size.height = 60;
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
                                if([_shippingAddress valueForKey:@"zip"]){
                                    if(![addressLabel.text isEqualToString:@""])
                                        addressLabel.text = [addressLabel.text stringByAppendingString:@", "];
                                    addressLabel.text = [addressLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@", [_shippingAddress valueForKey:@"zip"]]];
                                }
                                if([_billingAddress valueForKey:@"country_name"]){
                                    if(![addressLabel.text isEqualToString:@""])
                                        addressLabel.text = [addressLabel.text stringByAppendingString:@", "];
                                    addressLabel.text =[addressLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@", [_shippingAddress valueForKey:@"country_name"]]];
                                }
                                addressLabel.textColor = [UIColor blackColor];
                                addressLabel.font = [UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:18.0];
                                labelHeight = [addressLabel.text sizeWithFont:addressLabel.font].height;
                                [cell addSubview:addressLabel];
                                heightCell += labelHeight + 5;
                                // User Phone
                                if([_shippingAddress valueForKey:@"phone"]){
                                    imgUser = @"Ztheme_phone";
                                    userImage = [[UIImage imageNamed:imgUser] imageWithColor:ZTHEME_SUB_PART_COLOR];
                                    userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 6, 18, 18)];
                                    userImageView.image = userImage;
                                    userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                                    userLabel.text = [NSString stringWithFormat:@"%@", [_shippingAddress valueForKey:@"phone"]];
                                    userLabel.textColor = [UIColor blackColor];
                                    userLabel.font = [UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:18.0];
                                    labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                                    [cell addSubview:userImageView];
                                    [cell addSubview:userLabel];
                                    heightCell += labelHeight + 5;
                                }
                                // User Email
                                if([_shippingAddress valueForKey:@"email"]){
                                    imgUser = @"Ztheme_email";
                                    userImage = [[UIImage imageNamed:imgUser] imageWithColor:ZTHEME_SUB_PART_COLOR];
                                    userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 9, 18, 11)];
                                    userImageView.image = userImage;
                                    userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                                    userLabel.text = [NSString stringWithFormat:@"%@", [_shippingAddress valueForKey:@"email"]];
                                    userLabel.textColor = [UIColor blackColor];
                                    userLabel.font = [UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:18.0];
                                    labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                                    [cell addSubview:userImageView];
                                    [cell addSubview:userLabel];
                                    heightCell += labelHeight + 5;
                                }
                            }
                            //  Liam Update RTL
                            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                                for (UIView *view in cell.subviews) {
                                    if ([view isKindOfClass:[UILabel class]]) {
                                        UILabel *label = (UILabel *)view;
                                        [label setTextAlignment:NSTextAlignmentRight];
                                    }
                                }
                            }
                            //  End RTL
                        }
                            break;
                        default:
                            break;
                    }
                }
                else
                {
                    {
                        CGFloat heightCell = 15;
                        int imageX = 18;
                        int addressX = 60;
                        int addressWidth = 400;
                        int addressHeight = 30;
                        if (_billingAddress != nil) {
                            //User Name
                            NSString *imgUser = @"Ztheme_user";
                            UIImage *userImage = [[UIImage imageNamed:imgUser] imageWithColor:ZTHEME_SUB_PART_COLOR];
                            UIImageView *userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 6, 18, 18)];
                            userImageView.image = userImage;
                            NSString *imgEdit = @"Ztheme_address_edit";
                            UIImage *editImage = [[UIImage imageNamed:imgEdit] imageWithColor:ZTHEME_SUB_PART_COLOR];;
                            UIImageView *editImageView = [[UIImageView alloc]initWithFrame:CGRectMake(_tableRight.frame.size.width - 90,  heightCell, 23, 23)];
                            editImageView.image = editImage;
                            UILabel *userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                            userLabel.text = [NSString stringWithFormat:@"%@", [_billingAddress valueForKey:@"name"]];
                            userLabel.textColor = [UIColor blackColor];
                            userLabel.font = [UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:18.0];
                            CGFloat labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                            [cell addSubview:userImageView];
                            [cell addSubview:editImageView];
                            [cell addSubview:userLabel];
                            heightCell += labelHeight + 5;
                            // User Address
                            if([_billingAddress valueForKey:@"street"]){
                                imgUser = @"Ztheme_street";
                                userImage = [[UIImage imageNamed:imgUser] imageWithColor:ZTHEME_SUB_PART_COLOR];
                                userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 3.5, 16, 23)];
                                userImageView.image = userImage;
                                userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                                userLabel.text = [NSString stringWithFormat:@"%@", [_billingAddress valueForKey:@"street"]];
                                if([_billingAddress valueForKey:@"city"]){
                                    userLabel.text = [userLabel.text stringByAppendingString:[NSString stringWithFormat:@", %@", [_billingAddress valueForKey:@"city"]]];
                                }
                                if([_billingAddress valueForKey:@"state_name"] &&
                                   ![[_billingAddress valueForKey:@"state_name"] isKindOfClass:[NSNull class]] && [NSString stringWithFormat:@"%@", [_billingAddress valueForKey:@"state_name"]].length > 0){
                                    userLabel.text = [userLabel.text stringByAppendingString:[NSString stringWithFormat:@", %@", [_billingAddress valueForKey:@"state_name"]]];
                                }
                                userLabel.textColor = [UIColor blackColor];
                                userLabel.font = [UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:18.0];
                                labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                                [userLabel resizLabelToFit];
                                CGRect frame = userLabel.frame;
                                if(frame.size.height > 30){
                                    frame.size.height = 60;
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
                            if([_billingAddress valueForKey:@"zip"]){
                                if(![addressLabel.text isEqualToString:@""])
                                    addressLabel.text = [addressLabel.text stringByAppendingString:@", "];
                                addressLabel.text = [addressLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@", [_billingAddress valueForKey:@"zip"]]];
                            }
                            if([_billingAddress valueForKey:@"country_name"]){
                                if(![addressLabel.text isEqualToString:@""])
                                    addressLabel.text = [addressLabel.text stringByAppendingString:@", "];
                                addressLabel.text =[addressLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@", [_billingAddress valueForKey:@"country_name"]]];
                            }
                            addressLabel.textColor = [UIColor blackColor];
                            addressLabel.font = [UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:18.0];
                            labelHeight = [addressLabel.text sizeWithFont:addressLabel.font].height;
                            [cell addSubview:addressLabel];
                            heightCell += labelHeight + 5;
                            // User Phone
                            if([_billingAddress valueForKey:@"phone"]){
                                imgUser = @"Ztheme_phone";
                                userImage = [[UIImage imageNamed:imgUser] imageWithColor:ZTHEME_SUB_PART_COLOR];
                                userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 6, 18, 18)];
                                userImageView.image = userImage;
                                userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                                userLabel.text = [NSString stringWithFormat:@"%@", [_billingAddress valueForKey:@"phone"]];
                                userLabel.textColor = [UIColor blackColor];
                                userLabel.font = [UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:18.0];
                                labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                                [cell addSubview:userImageView];
                                [cell addSubview:userLabel];
                                heightCell += labelHeight + 5;
                            }
                            // User Email
                            if([_billingAddress valueForKey:@"email"]){
                                imgUser = @"Ztheme_email";
                                userImage = [[UIImage imageNamed:imgUser] imageWithColor:ZTHEME_SUB_PART_COLOR];
                                userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 9, 18, 11)];
                                userImageView.image = userImage;
                                userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                                userLabel.text = [NSString stringWithFormat:@"%@", [_billingAddress valueForKey:@"email"]];
                                userLabel.textColor = [UIColor blackColor];
                                userLabel.font = [UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:18.0];
                                labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                                [cell addSubview:userImageView];
                                [cell addSubview:userLabel];
                                heightCell += labelHeight + 5;
                            }
                        }
                    }
                }
                return cell;
            }
            if ([simiSection.identifier isEqualToString:ORDER_PAYMENT_SECTION]) {
                NSString *PaymentShowTypeSDKCell = [NSString stringWithFormat:@"PaymentShowTypeSDKCell_%d",(int)indexPath.row];
                NSString *PaymentShowTypeNoneCell = [NSString stringWithFormat:@"PaymentShowTypeNoneCell_%d",(int)indexPath.row];
                NSString *PaymentShowTypeCreditCardCell = [NSString stringWithFormat:@"PaymentShowTypeCreditCardCell_%d",(int)indexPath.row];
                SimiModel *payment = [_paymentCollection objectAtIndex:indexPath.row];
                UILabel *lblContentPayment = [[UILabel alloc]initWithFrame:CGRectMake(60, 40, 350, 40)];
                [lblContentPayment setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:14]];
                NSString *paymentTitle = @"";
                if ([[payment valueForKey:@"show_type"] integerValue] == PaymentShowTypeNone) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PaymentShowTypeNoneCell];
                    paymentTitle = [payment valueForKey:@"title"];
                    
                    if (![[payment valueForKey:@"content"] isKindOfClass:[NSNull class]] && indexPath.row == _selectedPayment) {
                        lblContentPayment.text = [payment valueForKey:@"content"];
                        [cell addSubview:lblContentPayment];
                        [lblContentPayment resizLabelToFit];
                    }
                }else if ([[payment valueForKey:@"show_type"] integerValue] == PaymentShowTypeCreditCard){
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PaymentShowTypeCreditCardCell];
                    paymentTitle = [payment valueForKey:@"title"];
                    
                    if (indexPath.row == _selectedPayment) {
                        //  Liam Update Credit Card
                        for (int i = 0; i < self.creditCards.count; i++) {
                            SimiModel *creditCard = [self.creditCards objectAtIndex:i];
                            if ([[creditCard valueForKey:@"payment_method"] isEqualToString:[payment valueForKey:@"payment_method"]]) {
                                if ([[creditCard valueForKey:hasData]boolValue]) {
                                    lblContentPayment.text = [NSString stringWithFormat:@"****%@", [[creditCard valueForKey:@"card_number"] substringWithRange:NSMakeRange([[creditCard valueForKey:@"card_number"] length] - 4, 4)]];
                                    [cell addSubview:lblContentPayment];
                                    [lblContentPayment resizLabelToFit];
                                }
                                break;
                            }
                        }
                        //  End Credit Card
                        /*
                         if (_creditCard != nil) {
                         lblContentPayment.text = [NSString stringWithFormat:@"****%@", [[_creditCard valueForKey:@"card_number"] substringWithRange:NSMakeRange([[_creditCard valueForKey:@"card_number"] length] - 4, 4)]];
                         [cell addSubview:lblContentPayment];
                         [lblContentPayment resizLabelToFit];
                         }
                         */
                    }
                }else{
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PaymentShowTypeSDKCell];
                    paymentTitle = [payment valueForKey:@"title"];
                }
                NSString *optionImageName = @"";
                if(_selectedPayment != indexPath.row){
                    optionImageName = @"Ztheme_option_round";
                }else{
                    optionImageName = @"Ztheme_option_round_checked";
                }
                UILabel *paymentTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, 350, 30)];
                paymentTitleLabel.text = paymentTitle;
                paymentTitleLabel.font = [UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:18.0];
                paymentTitleLabel.textColor = [UIColor blackColor];
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    [lblContentPayment setTextAlignment:NSTextAlignmentRight];
                    [paymentTitleLabel setTextAlignment:NSTextAlignmentRight];
                }
                //  End RTL
                [cell addSubview:paymentTitleLabel];
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                UIImage *optionImage = [[UIImage imageNamed:optionImageName] imageWithColor:ZTHEME_SUB_PART_COLOR];
                UIImageView *optionImageView = [[UIImageView alloc]initWithFrame:CGRectMake(18, 11, 18, 18)];
                optionImageView.image = optionImage;
                optionImageView.tag = 100;
                cell.textLabel.text = @" ";
                [cell addSubview:optionImageView];
            }
            if ([simiSection.identifier isEqualToString:ORDER_SHIPMENT_SECTION]) {
                static NSString *ShippingMethodCell = @"ShipmentMethodCell";
                cell = [tableView dequeueReusableCellWithIdentifier:ShippingMethodCell];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ShippingMethodCell];
                }
                cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", SCLocalizedString(@"Shipping Method"), [[_shippingCollection objectAtIndex:_selectedShippingMedthod] valueForKey:@"s_method_title"]];
                NSString *methodName = [[_shippingCollection objectAtIndex:_selectedShippingMedthod] valueForKey:@"s_method_name"];
                if (![methodName isKindOfClass:[NSNull class]]) {
                    if (methodName.length > 0){
                        cell.detailTextLabel.text = [[_shippingCollection objectAtIndex:_selectedShippingMedthod] valueForKey:@"s_method_name"];
                    }
                }
                [cell.textLabel setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:16]];
                [cell.textLabel setTextColor:[UIColor blackColor]];
                [cell.detailTextLabel setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:16]];
                [cell.detailTextLabel setTextColor:[UIColor blackColor]];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
    }else{
        if (self.orderTableRight) {
            simiSection = (SimiSection*)[self.orderTableRight objectAtIndex:indexPath.section];
            if ([simiSection.identifier isEqualToString:ORDER_TOTALS_SECTION]) {
                if(indexPath.row < [_cart count]){
                    //Init cell
                    SimiCartModel *item = [_cart objectAtIndex:indexPath.row];
                    NSString *CartCellIdentifier = [NSString stringWithFormat:@"%@_%@",@"SCCartCellIdentifier",[item valueForKey:@"cart_item_id"]];
                    cell = [tableView dequeueReusableCellWithIdentifier:CartCellIdentifier];
                    if (cell == nil) {
                        UINib *nib = [UINib nibWithNibName:@"SCCartCell" bundle:nil];
                        [tableView registerNib:nib forCellReuseIdentifier:CartCellIdentifier];
                        cell = [tableView dequeueReusableCellWithIdentifier:CartCellIdentifier];
                        //Set cell data
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
                        [cell setUserInteractionEnabled:NO];
                    }
                }else{
                    if (_isRequestOrderConfig) {
                        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OrderFeeLoading"];
                        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                        loadingView.frame = CGRectMake(145, 5, 30, 30);
                        [loadingView startAnimating];
                        for (UIView *view in cell.subviews) {
                            [view removeFromSuperview];
                        }
                        [cell addSubview:loadingView];
                    }else{
                        static NSString *OrderFeeCellIdentifier = @"SCOrderFeeCellIdentifier";
                        cell = [[SCOrderFeeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:OrderFeeCellIdentifier];
                        ((SCOrderFeeCell *)cell).isUsePhoneSizeOnPad = YES;
                        [(SCOrderFeeCell *)cell setData: _cartPrices];
                        cell.userInteractionEnabled = NO;
                    }
                }
            }
            if ([simiSection.identifier isEqualToString:ORDER_COUPON_SECTION]) {
                static NSString *CouponCodeCell = @"CouponCodeCell";
                cell = [tableView dequeueReusableCellWithIdentifier:CouponCodeCell];
                if (cell == nil) {
                    cell =  [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CouponCodeCell];
                    if (_textFieldCouponCode == nil) {
                        _textFieldCouponCode = [[UITextField alloc]init];
                        CGRect frame = CGRectMake(15, 15, 400, 40);
                        _textFieldCouponCode.frame = frame;
                        _textFieldCouponCode.borderStyle = UITextBorderStyleRoundedRect;
                        _textFieldCouponCode.placeholder = SCLocalizedString(@"Enter a coupon code");
                        _textFieldCouponCode.autocorrectionType = UITextAutocorrectionTypeNo;
                        _textFieldCouponCode.delegate = self;
                        [_textFieldCouponCode setClearButtonMode:UITextFieldViewModeUnlessEditing];
                        SimiToolbar *toolBar = [[SimiToolbar alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH, 40)];
                        toolBar.delegate = self;
                        _textFieldCouponCode.inputAccessoryView.backgroundColor = [UIColor blackColor];
                        _textFieldCouponCode.inputAccessoryView = toolBar;
                        [_textFieldCouponCode setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:16]];
                        [_textFieldCouponCode setTextColor:[UIColor blackColor]];
                    }
                    [cell addSubview:_textFieldCouponCode];
                }
                if (![[[_order valueForKey:@"fee"] valueForKey:@"coupon_code"] isKindOfClass:[NSNull class]]){
                    _textFieldCouponCode.text = [[_order valueForKey:@"fee"] valueForKey:@"coupon_code"];
                }
            }
            if ([simiSection.identifier isEqualToString:ORDER_TERMS_SECTION]) {
                NSString *TermAndConditionCell = [NSString stringWithFormat:@"TermAndConditions_%d",(int)indexPath.row];
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TermAndConditionCell];
                cell.accessoryType = UITableViewCellAccessoryNone;
                NSDictionary *term = [_termAndConditions objectAtIndex:indexPath.row];
                if([term objectForKey:@"name"]){
                    UILabel *termLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 7, CGRectGetWidth(self.view.frame) - 30, 30)];
                    termLabel.text = [[term objectForKey:@"name"] stringByAppendingString:@"..."];
                    [termLabel setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:16]];
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
                    NSString *imgMore = @"Ztheme_viewmore";
                    UIImage *moreImage = [UIImage imageNamed:imgMore];
                    UIImageView *moreImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imgMoreX, imgMoreY, 5, 5)];
                    moreImageView.image = moreImage;
                    [cell addSubview:termLabel];
                    [cell addSubview:moreImageView];
                }
                SimiCheckbox *checkbox = [[SimiCheckbox alloc] initWithTitle:[term objectForKey:@"title"]];
                [checkbox.titleLabel setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:16]];
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
            if ([simiSection.identifier isEqualToString:ORDER_BUTTON_SECTION]) {
                if ([self isOrderable]) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PlaceOrderCell"];
                    CGRect frame = cell.frame;
                    frame.origin.x = 30;
                    frame.origin.y = 10;
                    frame.size.width = 455;
                    frame.size.height = 40;
                    UIButton *button = [[UIButton alloc] initWithFrame: frame];
                    [button setBackgroundColor:THEME_COLOR];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    button.titleLabel.font = [UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:24];
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
        }
    }
    if (cell == nil) {
        cell  = [UITableViewCell new];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedOrderCellTheme01-After" object:simiSection userInfo:@{@"cell":cell, @"tableview":tableView,@"indexpath":indexPath}];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SimiSection *simiSection;
    if (tableView.tag == 1000) {
        if (self.orderTableLeft) {
            simiSection = (SimiSection*)[self.orderTableLeft objectAtIndex:section];
            if ([simiSection.identifier isEqualToString:ORDER_ADDRESS_SECTION]) {
                if (self.shippingCollection.count > 0) {
                    return 2;
                }else
                {
                    return 1;
                }
            }
            if ([simiSection.identifier isEqualToString:ORDER_PAYMENT_SECTION]) {
                return _paymentCollection.count;
            }
            if ([simiSection.identifier isEqualToString:ORDER_SHIPMENT_SECTION]) {
                if (self.shippingCollection.count > 0)
                {
                    return 1;
                }
            }
            return simiSection.count;
        }
    }else{
        if (self.orderTableRight) {
            simiSection = (SimiSection*)[self.orderTableRight objectAtIndex:section];
            if ([simiSection.identifier isEqualToString:ORDER_TOTALS_SECTION]) {
                return _cart.count +1;
            }
            if ([simiSection.identifier isEqualToString:ORDER_COUPON_SECTION]) {
                return 1;
            }
            if ([simiSection.identifier isEqualToString:ORDER_TERMS_SECTION]) {
                return [_termAndConditions count];
            }
            if ([simiSection.identifier isEqualToString:ORDER_BUTTON_SECTION]) {
                return 1;
            }
            return simiSection.count;
        }
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    int numberSections = 0;
    if (tableView.tag == 1000) {
        numberSections = (int)_orderTableLeft.count;
    }else
    {
        numberSections = (int)_orderTableRight.count;
    }
    return numberSections;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle = @"";
    SimiSection *simiSection;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 45)];
    UILabel *headerTitleSection = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width - 20, 40)];
    if (tableView.tag == 1000) {
        if (self.orderTableLeft) {
            simiSection = (SimiSection*)[self.orderTableLeft objectAtIndex:section];
            if ([simiSection.identifier isEqualToString:ORDER_ADDRESS_SECTION]) {
                if (self.shippingCollection.count > 0) {
                    headerTitle = SCLocalizedString(@"Billing and Shipping Addresses");
                }else
                {
                    headerTitle = SCLocalizedString(@"Billing Addresses");
                }
            }
            if ([simiSection.identifier isEqualToString:ORDER_PAYMENT_SECTION]) {
                headerTitle =  SCLocalizedString(@"Payment");
            }
            if ([simiSection.identifier isEqualToString:ORDER_SHIPMENT_SECTION]) {
                if (self.shippingCollection.count > 0) {
                    headerTitle = SCLocalizedString(@"Shipment Details");
                }
            }
            if (simiSection.headerTitle) {
                headerTitle = simiSection.headerTitle;
            }
        }
    }else
    {
        if (self.orderTableRight) {
            simiSection = (SimiSection*)[self.orderTableRight objectAtIndex:section];
            if ([simiSection.identifier isEqualToString:ORDER_COUPON_SECTION]) {
                headerTitle =  SCLocalizedString(@"Coupon code");
                //Gin edit
                [headerTitleSection setFrame:CGRectMake(10, -15, tableView.bounds.size.width - 20, 40)];
                //end
            }
            if ([simiSection.identifier isEqualToString:ORDER_TERMS_SECTION]) {
                if ([_termAndConditions count] > 0) {
                    headerTitle =  SCLocalizedString(@"Term and conditions");
                }
            }
            if (simiSection.headerTitle) {
                headerTitle = simiSection.headerTitle;
            }
        }
    }
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 45)];
//    UILabel *headerTitleSection = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width - 20, 40)];
    headerTitleSection.text = headerTitle;
    [headerTitleSection setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:18]];
    [headerTitleSection setTextColor:[UIColor blackColor]];
    [headerView setBackgroundColor:[UIColor colorWithRed:236.0/255 green:236.0/255 blue:236.0/255 alpha:1.0]];
    [headerView addSubview:headerTitleSection];
    //  Liam Update RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [headerTitleSection setTextAlignment:NSTextAlignmentRight];
    }
    //  End RTL
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    SimiSection *simiSection;
    if (tableView.tag == 1000) {
        if (self.orderTableLeft) {
            simiSection = (SimiSection*)[self.orderTableLeft objectAtIndex:section];
            if ([simiSection.identifier isEqualToString:ORDER_ADDRESS_SECTION]) {
                return 35;
            }
            if ([simiSection.identifier isEqualToString:ORDER_PAYMENT_SECTION]) {
                return 35;
            }
            if ([simiSection.identifier isEqualToString:ORDER_SHIPMENT_SECTION]) {
                if (self.shippingCollection.count > 0) {
                    return 35;
                }
            }
            if (simiSection.headerTitle) {
                return 35;
            }
        }
    }else{
        if (self.orderTableRight) {
            simiSection = (SimiSection*)[self.orderTableRight objectAtIndex:section];
            //Gin edit
            if ([simiSection.identifier isEqualToString:ORDER_COUPON_SECTION]) {
                return 20;
            }
            if ([simiSection.identifier isEqualToString:ORDER_BUTTON_SECTION]) {
                return 0.001f;
            }
            //end
            if ([simiSection.identifier isEqualToString:ORDER_TERMS_SECTION]) {
                if ([_termAndConditions count] > 0) {
                    return 35;
                }
            }
            if (simiSection.headerTitle) {
                return 35;
            }
        }
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SCOrderViewControllerPad_Theme01-AfterSetHeightViewForFooter" object:tableView];
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection;
    if (tableView.tag == 1000) {
        if (self.orderTableLeft) {
            simiSection = (SimiSection*)[self.orderTableLeft objectAtIndex:indexPath.section];
            if ([simiSection.identifier isEqualToString:ORDER_ADDRESS_SECTION]) {
                return 210;
            }
            if ([simiSection.identifier isEqualToString:ORDER_PAYMENT_SECTION]) {
                if ([[[_paymentCollection objectAtIndex:indexPath.row] valueForKey:@"show_type"] integerValue] == PaymentShowTypeNone) {
                    if (indexPath.row == _selectedPayment) {
                        return 120;
                    }
                }else if([[[_paymentCollection objectAtIndex:indexPath.row] valueForKey:@"show_type"] integerValue] == PaymentShowTypeCreditCard)
                {
                    if (indexPath.row == _selectedPayment) {
                        return 80;
                    }
                }
                return 45;
            }
            if ([simiSection.identifier isEqualToString:ORDER_SHIPMENT_SECTION]) {
                return 50;
            }
            if (simiSection.count) {
                return [simiSection objectAtIndex:0].height;
            }
        }
    }else{
        if (self.orderTableRight) {
            simiSection = (SimiSection*)[self.orderTableRight objectAtIndex:indexPath.section];
            if ([simiSection.identifier isEqualToString:ORDER_TOTALS_SECTION]) {
                if(indexPath.row < [_cart count]){
                    return 120;
                }else{
                    if (_isRequestOrderConfig) {
                        return 50;
                    }else{
                        _heightRow = 40;
                        NSArray * totalV2 = [_order valueForKey:@"total_v2"];
                        if(![_order valueForKey:@"total_v2"]){
                            NSArray *fee= [_order valueForKey:@"fee"];
                            totalV2 = [fee valueForKey:@"v2"];
                        }
                        if(totalV2.count > 0 ){
                            _heightRow = 26 * totalV2.count;
                        }
                        return  _heightRow + 20;
                    }
                }
            }
            if ([simiSection.identifier isEqualToString:ORDER_COUPON_SECTION]) {
                return 70;
            }
            if ([simiSection.identifier isEqualToString:ORDER_TERMS_SECTION]) {
                return 100;
            }
            if ([simiSection.identifier isEqualToString:ORDER_BUTTON_SECTION]) {
                return 60;
            }
            if (simiSection.count) {
                return [simiSection objectAtIndex:0].height;
            }
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc]initWithFrame:CGRectZero];
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectOrderCellAtIndexPath" object:tableView userInfo:@{@"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    NSInteger section = [indexPath section];
    SimiSection *simiSection;
    if (tableView.tag == 1000) {
        if (self.orderTableLeft) {
            simiSection = (SimiSection*)[self.orderTableLeft objectAtIndex:section];
            if ([simiSection.identifier isEqualToString:ORDER_ADDRESS_SECTION]) {
                if (indexPath.row == 0) {
                    isSelectBillingAddress = YES;
                }else{
                    isSelectBillingAddress = NO;
                }
                SCAddressViewController *nextController = [[SCAddressViewController alloc]init];
                [nextController setDelegate:self];
                [nextController setIsGetOrderAddress:YES];
                
                UINavigationController *navi;
                navi = [[UINavigationController alloc]initWithRootViewController:nextController];
                
                _popController = nil;
                _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                _popController.delegate = self;
                nextController.popover = _popController;
                navi.navigationBar.tintColor = THEME_COLOR;
                if (SIMI_SYSTEM_IOS >= 8) {
                    navi.navigationBar.tintColor = [UIColor whiteColor];
                }
                navi.navigationBar.barTintColor = THEME_COLOR;
                [self hiddenScreenWhenShowPopOver];
                [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
            }
            if ([simiSection.identifier isEqualToString:ORDER_PAYMENT_SECTION]) {
                _selectedPayment  = indexPath.row;
                SimiModel *payment = [_paymentCollection objectAtIndex:_selectedPayment];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectPaymentMethod" object:payment userInfo:@{@"payment": payment}];
                if ([[payment valueForKey:@"show_type"] integerValue] == PaymentShowTypeCreditCard) {
                    NSArray *creditCardTypes = [[_paymentCollection objectAtIndex:indexPath.row] valueForKey:@"cc_types"];
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
                        /*
                         nextController.creditCardList = [payment valueForKey:@"cc_types"];
                         nextController.isUseCVV = [[payment valueForKey:@"useccv"] boolValue];
                         */
                        //  End Update Credit Card
                        
                        UINavigationController *navi;
                        navi = [[UINavigationController alloc]initWithRootViewController:nextController];
                        
                        _popController = nil;
                        _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                        _popController.delegate = self;
                        nextController.popover = _popController;
                        navi.navigationBar.tintColor = THEME_COLOR;
                        if (SIMI_SYSTEM_IOS >= 8) {
                            navi.navigationBar.tintColor = [UIColor whiteColor];
                        }
                        navi.navigationBar.barTintColor = THEME_COLOR;
                        [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
                    }
                }else if ([[payment valueForKey:@"show_type"] integerValue] == PaymentShowTypeSDK){
                    
                }else{
                    
                }
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:[self.orderTableLeft getSectionIndexByIdentifier:ORDER_PAYMENT_SECTION]] withRowAnimation:UITableViewRowAnimationNone];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            if ([simiSection.identifier isEqualToString:ORDER_SHIPMENT_SECTION]) {
                ZThemeShippingViewControllerPad *nextController = [[ZThemeShippingViewControllerPad alloc]init];
                [nextController setMethodCollection: _shippingCollection];
                [nextController setSelectedMethodRow:_selectedShippingMedthod];
                nextController.delegate = self;
                
                UINavigationController *navi;
                navi = [[UINavigationController alloc]initWithRootViewController:nextController];
                
                self.popController = nil;
                self.popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                self.popController.delegate = self;
                nextController.popover = _popController;
                navi.navigationBar.tintColor = THEME_COLOR;
                if (SIMI_SYSTEM_IOS >= 8) {
                    navi.navigationBar.tintColor = [UIColor whiteColor];
                }
                navi.navigationBar.barTintColor = THEME_COLOR;
                [self hiddenScreenWhenShowPopOver];
                [self.popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
            }

        }
    }else{
        if (self.orderTableRight) {
            simiSection = (SimiSection*)[self.orderTableRight objectAtIndex:section];
            if ([simiSection.identifier isEqualToString:ORDER_TERMS_SECTION]) {
                SCTermConditionViewController *termView = [[SCTermConditionViewController alloc] init];
                termView.termAndCondition = [_termAndConditions objectAtIndex:indexPath.row];
                
                
                UINavigationController *navi;
                navi = [[UINavigationController alloc]initWithRootViewController:termView];
                
                _popController = nil;
                _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                _popController.delegate = self;
                termView.popover = _popController;
                navi.navigationBar.barTintColor = THEME_COLOR;
                navi.navigationBar.tintColor = THEME_COLOR;
                if (SIMI_SYSTEM_IOS >= 8) {
                    navi.navigationBar.tintColor = [UIColor whiteColor];
                }
                [self hiddenScreenWhenShowPopOver];
                [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
            }
        }
    }
}

#pragma mark Get Order Config
- (void)getOrderConfig{
    _isRequestOrderConfig = YES;
    if (_order == nil) {
        _order = [[SimiOrderModel alloc] init];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetOrderConfig:) name:@"DidGetOrderConfig" object:_order];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:_shippingAddress forKey:@"shippingAddress"];
    [params setValue:_billingAddress forKey:@"billingAddress"];
    if (self.isNewCustomer) {
        [params setValue:[_billingAddress valueForKey:@"customer_password"] forKey:@"customer_password"];
        [params setValue:[_billingAddress valueForKey:@"confirm_password"] forKey:@"confirm_password"];
        SimiModel *payment = [_paymentCollection objectAtIndex:_selectedPayment];
        NSDictionary *userInfo = payment ? @{@"data": payment} : nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectPaymentMethod" object:payment userInfo:userInfo];
    }
    [_order getOrderConfigWithParams:params];
    [self startLoadingData];
}

- (void)didGetOrderConfig:(NSNotification *)noti{
    [self stopLoadingData];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        _isRequestOrderConfig = NO;
        _paymentCollection = [[SimiPaymentModelCollection alloc] initWithArray:[_order valueForKey:@"payment_method_list"]];
        _shippingCollection = [[SimiShippingModelCollection alloc] initWithArray:[_order valueForKey:@"shipping_method_list"]];
        _selectedShippingMedthod = [self getSelectedShippingMedthodId];
        //  Liam Update Credit Card
        if (self.paymentCollection.count > 0) {
            if (self.creditCards == nil) {
                self.creditCards = [NSMutableArray new];
                for (int i = 0; i < self.paymentCollection.count; i++) {
                    SimiModel *payment = [self.paymentCollection objectAtIndex:i];
                    SimiModel *paymentModel = [SimiModel new];
                    [paymentModel setValue:@"NO" forKey:@"hasData"];
                    [paymentModel setValue:[payment valueForKey:@"payment_method"] forKey:@"payment_method"];
                    if ([[payment valueForKey:@"show_type"]intValue] == PaymentShowTypeCreditCard) {
                        [self.creditCards addObject:paymentModel];
                    }
                }
                NSMutableArray *localCrediCardsData = [[NSUserDefaults standardUserDefaults]valueForKey:saveCreditCardsToLocal];
                if (localCrediCardsData != nil) {
                    for (int i = 0; i < localCrediCardsData.count; i++) {
                        SimiModel *localModel = [localCrediCardsData objectAtIndex:i];
                        for (int j = 0; j < self.creditCards.count; j++) {
                            SimiModel *currentData = [self.creditCards objectAtIndex:j];
                            if ([[currentData valueForKey:@"payment_method"] isEqualToString:[localModel valueForKey:@"payment_method"]]) {
                                [currentData setValuesForKeysWithDictionary:localModel];
                                break;
                            }
                        }
                    }
                }
            }
        }
        //  End Update Credit Card
        // Term and conditions
        if (![[_order valueForKey:@"condition"] isKindOfClass:[NSNull class]]) {
            _termAndConditions = [NSMutableArray new];
            for (NSDictionary *data in [[_order valueForKey:@"fee"] valueForKey:@"condition"]) {
                [_termAndConditions addObject:data];
            }
        } else {
            _termAndConditions = nil;
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"FAIL") message:SCLocalizedString(@"") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        if (_paymentCollection.count == 0) {
            if (_paymentCollection.count == 0) {
                alertView.message = SCLocalizedString(@"Couldn't get payment method information.");
            }
            [alertView show];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            //  Liam Update for Default Payment Method
            if ([[SimiGlobalVar sharedInstance]isDefaultPayment]) {
                if (self.paymentCollection.count > 0 && self.selectedPayment < 0) {
                    for (int i = 0; i < self.paymentCollection.count; i++) {
                        SimiModel *payment = [self.paymentCollection objectAtIndex:i];
                        if ([[payment valueForKey:@"show_type"] integerValue] == PaymentShowTypeNone) {
                            self.selectedPayment = i;
                            if([self.isReloadPayment isEqualToString:@"1"]){
                                [self savePaymentMethod:payment];
                            }
                            break;
                        }
                    }
                }
            }
            //   End
            [_tableRight reloadData];
            [_tableLeft reloadData];
            if (_shippingCollection.count != 0){
                [self didSelectShippingMethodAtIndex:_selectedShippingMedthod];
            }else
            {
                _tableLeft.hidden = NO;
                _tableRight.hidden = NO;
                [self configOrderTableLeft];
                [self configOrderTableRight];
                [_tableRight reloadData];
                [_tableLeft reloadData];
            }
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    [self removeObserverForNotification:noti];
}

#pragma mark Credit Card View Delegate
- (void)didEnterCreditCardWithCardType:(NSString *)cardType cardNumber:(NSString *)number expiredMonth:(NSString *)expiredMonth expiredYear:(NSString *)expiredYear cvv:(NSString *)CVV{
    [_popController dismissPopoverAnimated:YES];
    [self showScreenWhenHiddenPopOver];
    //  Liam Update Credit Card
    SimiModel *payment = [self.paymentCollection objectAtIndex:self.selectedPayment];
    for (int i = 0; i < self.creditCards.count; i ++) {
        SimiModel *creditCard = [self.creditCards objectAtIndex:i];
        if ([[creditCard valueForKey:@"payment_method"] isEqualToString:[payment valueForKey:@"payment_method"]]) {
            [creditCard setValue:@"YES" forKey:hasData];
            [creditCard setValue:cardType forKey:@"card_type"];
            [creditCard setValue:number forKey:@"card_number"];
            [creditCard setValue:expiredMonth forKey:@"expired_month"];
            [creditCard setValue:expiredYear forKey:@"expired_year"];
            [creditCard setValue:CVV forKey:@"cc_id"];
            break;
        }
    }
    //  End Update Credit Card
    [[NSUserDefaults standardUserDefaults] setValue:self.creditCards forKey:saveCreditCardsToLocal];
    /*
    if (_creditCard == nil) {
        _creditCard = [[SimiModel alloc] init];
    }
    [_creditCard setValue:cardType forKey:@"card_type"];
    [_creditCard setValue:number forKey:@"card_number"];
    [_creditCard setValue:expiredMonth forKey:@"expired_month"];
    [_creditCard setValue:expiredYear forKey:@"expired_year"];
    [_creditCard setValue:CVV forKey:@"cc_id"];
     */
    [_tableLeft reloadData];
    [_tableRight reloadData];
    
}

- (int)getSelectedShippingMedthodId
{
    for (int i=0; i< _shippingCollection.count; i++){
        NSArray *shippingMethods = [_shippingCollection objectAtIndex:i];
        NSInteger selectedId = [[shippingMethods valueForKey:@"s_method_selected"] integerValue];
        if(selectedId == 1){
            return i;
        }
    }
    return 0;
}

#pragma mark SCShipping Delegate
- (void)didSelectShippingMethodAtIndex:(NSInteger)index{
    [self.popController dismissPopoverAnimated:YES];
    [self showScreenWhenHiddenPopOver];
    _selectedShippingMedthod = index;
    SimiShippingModel *method = (SimiShippingModel *)[_shippingCollection objectAtIndex:_selectedShippingMedthod];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSaveShippingMethod:) name:@"DidSaveShippingMethod" object:_order];
    [self startLoadingData];
    [_order selectShippingMethod:method];
}

- (void)didSaveShippingMethod:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if([_order valueForKey:@"fee"]){
            if([[_order valueForKey:@"fee"] valueForKey:@"v2"]){
                _cartPrices = [[_order valueForKey:@"fee"] valueForKey:@"v2"];
            }
        }
        if([_order valueForKey:@"payment_method_list"]){
            _paymentCollection = [[SimiPaymentModelCollection alloc] initWithArray:[_order valueForKey:@"payment_method_list"]];
        }
        _tableLeft.hidden = NO;
        _tableRight.hidden = NO;
        [self configOrderTableLeft];
        [self configOrderTableRight];
        [_tableRight reloadData];
        [_tableLeft reloadData];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
}

#pragma mark Text Field Delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self keyboardWasShown];
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    if ([textField isEqual:_textFieldCouponCode]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Do you want to cancel this coupon code ?") delegate:self cancelButtonTitle:SCLocalizedString(@"Cancel") otherButtonTitles:SCLocalizedString(@"OK"), nil];
        alertView.tag = TF_COUPON_CODE;
        [alertView show];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual: _textFieldCouponCode]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSetCouponCode:) name:@"DidSetCouponCode" object:_order];
        [[_order valueForKey:@"fee"] setValue:_textFieldCouponCode.text forKey:@"coupon_code"];
        [_order setCouponCode:_textFieldCouponCode.text];
        [self startLoadingData];
        [self hideKeyboard];
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField isEqual:_textFieldCouponCode]) {
        [self hideKeyboard];
    }
    [_tableLeft reloadData];
}

#pragma mark Key Board
- (void)keyboardWasShown
{
    UIEdgeInsets contentInsets = _tableLeft.contentInset;
    contentInsets.bottom = 400;
    _tableRight.contentInset = contentInsets;
    _tableRight.scrollIndicatorInsets = contentInsets;
}

- (void)hideKeyboard{
    _tableRight.contentInset = UIEdgeInsetsZero;
    _tableRight.scrollIndicatorInsets = UIEdgeInsetsZero;
}

#pragma mark Set CouponCode
- (void)didSetCouponCode:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
    [alertView show];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if([_order valueForKey:@"fee"]){
            if([[_order valueForKey:@"fee"] valueForKey:@"v2"]){
                _cartPrices = [[_order valueForKey:@"fee"] valueForKey:@"v2"];
            }
            [_tableRight reloadData];
        }
        if([_order valueForKey:@"payment_method_list"]){
            _paymentCollection = [[SimiPaymentModelCollection alloc] initWithArray:[_order valueForKey:@"payment_method_list"]];
            [_tableLeft reloadData];
        }
    }
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
}

#pragma mark  toggleCheckBox
- (void)toggleCheckBox:(SimiCheckbox *)sender
{
    NSMutableDictionary *term = [_termAndConditions objectAtIndex:sender.tag];
    if ([sender checkState] == M13CheckboxStateChecked) {
        [term setValue:[NSNumber numberWithBool:YES] forKey:@"checked"];
    } else {
        [term removeObjectForKey:@"checked"];
    }
    [_termAndConditions replaceObjectAtIndex:sender.tag withObject:term];
}

#pragma mark Place Order
- (void)placeOrder{
    if (_selectedPayment >= 0) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        if ([_termAndConditions count]) {
            accept = NO;
            for (NSDictionary *term in _termAndConditions) {
                if (![[term objectForKey:@"checked"] boolValue]) {
                    // Scroll to term and condition
                    [_tableRight scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    [_tableRight deselectRowAtIndexPath:[_tableLeft indexPathForSelectedRow] animated:YES];
                    // Show alert
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Please agree to all the terms and conditions before placing the order.") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil];
                    [alertView show];
                    return;
                }
            }
            accept = YES;
        }
        if (accept) {
            [params setValue:@"1" forKey:@"condition"];
        }else{
            [params setValue:@"0" forKey:@"condition"];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder" object:_order];
        [params setValue:[[_paymentCollection objectAtIndex:_selectedPayment] valueForKey:@"payment_method"] forKey:@"payment_method"];
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
        /*
        if (_creditCard != nil) {
            for (NSString *key in [_creditCard allKeys]) {
                [params setValue:[_creditCard valueForKey:key] forKey:key];
            }
        }
        */
        //  End Update Credit Card
        //  Liam Update Klarna Check Out
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SCOrderViewController-BeforePlaceOrder" object:self userInfo:@{@"order":self.order,@"payment":payment}];
        if (self.isDiscontinue) {
            self.isDiscontinue = NO;
            return;
        }
        //  End Update Klarna Check Out
        [self startLoadingData];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [_order placeOrderWithParams:params];
        self.tabBarController.tabBar.userInteractionEnabled = NO;
    }else{
        // Scroll to payment
        [_tableRight scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [_tableRight deselectRowAtIndexPath:[_tableRight indexPathForSelectedRow] animated:YES];
        // Show alert
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Please choose a payment method") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
}

- (BOOL)isOrderable{
    if (_billingAddress != nil && _shippingAddress != nil && _paymentCollection.count > 0) {
        return YES;
    }
    return NO;
}

#pragma mark Toolbar Delegates
- (void)toolbarDidClickCancelButton:(SimiToolbar *)toolbar{
    [self textFieldDidEndEditing:_textFieldCouponCode];
}
- (void)toolbarDidClickDoneButton:(SimiToolbar *)toolbar{
    [self textFieldShouldReturn:_textFieldCouponCode];
}

#pragma  mark UIPopover Delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self showScreenWhenHiddenPopOver];
    _popController = nil;
}

#pragma mark Address Delegate
- (void)selectAddress:(SimiAddressModel *)address{
    [_popController dismissPopoverAnimated:YES];
    [self showScreenWhenHiddenPopOver];
    if (isSelectBillingAddress) {
        _billingAddress = address;
        if (_shippingAddress == nil) {
            _shippingAddress = address;
        }
    }else{
        _shippingAddress = address;
    }
    [self getOrderConfig];
    [_tableRight reloadData];
}

#pragma mark Did Place Order
- (void)didReceiveNotification:(NSNotification *)noti{
    [self stopLoadingData];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([noti.name isEqualToString:@"DidPlaceOrder"]) {
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            //Success
            NSString *invoiceNumber = [_order valueForKey:@"invoice_number"];
            [_order removeObjectsForKeys:[NSArray arrayWithObjects:@"shipping_method_list", @"payment_method_list", nil]];
            [_order setValue:invoiceNumber forKey:@"invoice_number"];
            [_order setValue:[_paymentCollection objectAtIndex:_selectedPayment] forKey:@"payment"];
            
            SimiShippingModel *shippingModel = (SimiShippingModel *)[self.shippingCollection objectAtIndex:self.selectedShippingMedthod];
            if (shippingModel == nil) {
                shippingModel = [SimiShippingModel new];
            }
            if ([[[_paymentCollection objectAtIndex:_selectedPayment] valueForKey:@"show_type"] integerValue] == PaymentShowTypeRedirect) {
                [self.navigationController popToRootViewControllerAnimated:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DidPlaceOrder-Before" object:_order userInfo:@{@"data": _order, @"payment": [_order valueForKey:@"payment"], @"controller": self, @"responder":responder, @"cart":_cart, @"shipping":shippingModel}];
                
            }else if ([[[_paymentCollection objectAtIndex:_selectedPayment] valueForKey:@"show_type"] integerValue] != PaymentShowTypeSDK){
                //  Liam UPDATE 150401
                if ([self.order valueForKey:@"notification"]) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"DidCheckOut-Success" object:self.order];
                }else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:SCLocalizedString(@"Thank you for your purchase") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
                    alertView.delegate = self;
                    alertView.tag = AFTERPLACEORDER;
                    [alertView show];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
                //  End
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidPlaceOrder-After" object:_order userInfo:@{@"data": _order, @"payment": [_order valueForKey:@"payment"], @"controller": self, @"responder":responder, @"cart":_cart, @"shipping":shippingModel}];
        }else
        {
            //Fail
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:SCLocalizedString(responder.responseMessage) delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
            [_tableRight deselectRowAtIndexPath:[_tableRight indexPathForSelectedRow] animated:YES];
        }
    }
    [self removeObserverForNotification:noti];
}

#pragma mark AlertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TF_COUPON_CODE) {
        [_textFieldCouponCode resignFirstResponder];
        if (buttonIndex == 0) {
            //Not cancel coupon code
            _textFieldCouponCode.text = [[_order valueForKey:@"fee"] valueForKey:@"coupon_code"];
        }else{
            //Cancel coupon code
            [[_order valueForKey:@"fee"] setValue:@"" forKey:@"coupon_code"];
            _textFieldCouponCode.text = [[_order valueForKey:@"fee"] valueForKey:@"coupon_code"];
            [self toolbarDidClickDoneButton:nil];
        }
    }else if (alertView.tag == AGREEMENT){
        if (buttonIndex == 0) {
            accept = NO;
            [_tableRight deselectRowAtIndexPath:[_tableRight indexPathForSelectedRow] animated:YES];
        }else{
            accept = YES;
            [self placeOrder];
        }
    }else if (alertView.tag ==  AFTERPLACEORDER)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
