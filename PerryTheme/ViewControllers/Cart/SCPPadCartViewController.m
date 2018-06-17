//
//  SCPPadCartViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 6/4/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPPadCartViewController.h"
#import <SimiCartBundle/SCAddressViewController.h>

@interface SCPPadCartViewController ()

@end

@implementation SCPPadCartViewController
- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:SCCartViewController_ContinueCheckOutWithExistCustomer object:nil];
}

- (void)initTableViewOnCart{
    self.view.backgroundColor = COLOR_WITH_HEX(@"#f2f2f2");
    CGRect frame = self.view.bounds;
    frame.size.width *= 0.6f;
    self.moreContentTableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStylePlain];
    self.moreContentTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.moreContentTableView.delegate = self;
    self.moreContentTableView.dataSource = self;
    self.moreContentTableView.cellLayoutMarginsFollowReadableWidth = NO;
    
    [self.moreContentTableView setContentOffset:CGPointMake(0, 0)];
    [self.moreContentTableView setBackgroundColor:[UIColor clearColor]];
    [self.moreContentTableView addSubview:refreshControl];
    [self.view addSubview:self.moreContentTableView];
    frame = self.view.bounds;
    frame.origin.x += frame.size.width * 0.6f;
    frame.size.width = frame.size.width * 0.4 - SCALEVALUE(28);
    self.contentTableView = [[SimiTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.contentTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.contentTableView.dataSource = self;
    self.contentTableView.delegate = self;
    [self.contentTableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.contentTableView];
    
    self.btnCheckout = [[SCPButton alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, SCALEVALUE(45)) title:@"CHECK OUT" titleFont:[UIFont fontWithName:SCP_FONT_SEMIBOLD size:FONT_SIZE_HEADER] cornerRadius:0 borderWidth:0 borderColor:nil];
    [self.btnCheckout addTarget:self action:@selector(checkout) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.cart.canCheckOut) {
        [self.btnCheckout setHidden:NO];
    }else{
        [self.btnCheckout setHidden:YES];
    }
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.moreContentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self reloadData];
}

- (void)viewDidAppearBefore:(BOOL)animated{
    [self updateSubViews];
    if (GLOBALVAR.isGettingCart) {
        [self startLoadingData];
    }else{
        [self reloadData];
    }
}

- (void)reloadData{
    [self initCells];
    [self initMoreCells];
    [self updateSubViews];
}

- (void)createCells{
    cartPrices = [GLOBALVAR convertCartPriceData:self.cart.cartTotal];
    if ([self.cart count]) {
        SimiSection *sectionPrice = [self.cells addSectionWithIdentifier:CART_TOTALS];
        SimiRow *cartTotalsRow = [[SimiRow alloc]initWithIdentifier:CART_TOTALS_ROW height:(25 * GLOBALVAR.numberRowOnCartPrice + 40)];
        if (GLOBALVAR.isReverseLanguage) {
            cartTotalsRow.height = (50 * GLOBALVAR.numberRowOnCartPrice) + 40;
        }
        [sectionPrice addRow:cartTotalsRow];
        [sectionPrice addRowWithIdentifier:CART_CHECKOUT_ROW height:SCALEVALUE(45)];
    }
}

- (void)createMoreCells{
    if ([self.cart count]) {
        SimiSection *products = [self.moreCells addSectionWithIdentifier:CART_PRODUCTS];
        for (NSInteger i = 0; i < [self.cart count]; i++) {
            SimiQuoteItemModel *item = [self.cart objectAtIndex:i];
            SimiRow *row = [[SimiRow alloc]initWithIdentifier:[NSString stringWithFormat:@"%@_%@",CART_PRODUCTS, item.itemId] height:SCALEVALUE(210)];
            [products addObject:row];
        }
    }
}

- (void)changeCartData:(NSNotification *)noti{
    [super changeCartData:noti];
    [self reloadData];
}

#pragma mark Create Cell For Rows
- (UITableViewCell *)createProductCellForRow:(SimiRow *)row atIndexPath:(NSIndexPath *)indexPath{
    SCPCartCell *cell = [self.moreContentTableView dequeueReusableCellWithIdentifier:row.identifier];
    SimiQuoteItemModel *item = [self.cart objectAtIndex:indexPath.row];
    if (cell == nil) {
        cell = [[SCPCartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier quoteItemModel:item];
        cell.delegate = self;
        [cell setBackgroundColor:[UIColor clearColor]];
    }else
        [cell updateCellWithQuoteItem:item];
    row.height = cell.heightCell;
    return cell;
}

- (UITableViewCell *)createTotalCellForRow:(SimiRow *)row{
    SCPOrderFeeCell *cell = [[SCPOrderFeeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
    if (self.cart.count <= 0) {
        return cell;
    }
    [cell setData:cartPrices andWidthCell:CGRectGetWidth(self.contentTableView.frame)];
    cell.userInteractionEnabled = NO;
    row.height = cell.heightCell;
    return cell;
}

- (UITableViewCell *)createCheckoutCellForRow:(SimiRow *)row{
    UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:CART_CHECKOUT_ROW];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        [cell.contentView addSubview:self.btnCheckout];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:[indexPath section]];
    SimiRow *row = [section objectAtIndex:[indexPath row]];
    UITableViewCell *aCell;
    if([section.identifier isEqualToString:CART_TOTALS]){
        if ([row.identifier isEqualToString:CART_TOTALS_ROW]) {
            aCell = [self createTotalCellForRow:row];
        }else if ([row.identifier isEqualToString:CART_CHECKOUT_ROW]) {
            aCell = [self createCheckoutCellForRow:row];
        }
    }
    return aCell;
}

- (UITableViewCell *)moreContentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.moreCells objectAtIndex:[indexPath section]];
    SimiRow *row = [section objectAtIndex:[indexPath row]];
    UITableViewCell *aCell;
    if ([section.identifier isEqualToString:CART_PRODUCTS]) {
        aCell = [self createProductCellForRow:row atIndexPath:indexPath];
    }
    return aCell;
}

#pragma mark Empty Label
- (void)updateSubViews
{
    if (emptyLabel == nil) {
        emptyLabel = [[SimiLabel alloc]initWithFrame:self.view.bounds andFontSize:FONT_SIZE_HEADER];
        emptyLabel.text = SCLocalizedString(@"You have no items in your shopping cart");
        [emptyLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [emptyLabel setTextAlignment:NSTextAlignmentCenter];
        [emptyLabel setNumberOfLines:2];
        [self.view addSubview:emptyLabel];
    }
    
    if (self.cart.count == 0) {
        emptyLabel.center = self.view.center;
        [emptyLabel setHidden:NO];
        [self.contentTableView setHidden:YES];
        [self.moreContentTableView setHidden:YES];
    }else {
        [emptyLabel setHidden:YES];
        [self.moreContentTableView setHidden:NO];
        [self.contentTableView setHidden:NO];
    }
}

#pragma mark Cart Actions
- (void)checkout {
    [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"cart_action" userInfo:@{@"action":@"clicked_checkout_button"}];
    if(orderWebURL){
        if([GLOBALVAR isLogin]){
            NSDictionary *accountInfo = [SimiCustomerModel getUserInfoForAutoLogin];
            NSString *email = [accountInfo objectForKey:@"email"];
            NSString *password = [accountInfo objectForKey:@"password"];
            
            orderWebURL = [orderWebURL stringByReplacingOccurrencesOfString:@"email_value" withString:email];
            orderWebURL = [orderWebURL stringByReplacingOccurrencesOfString:@"password_value" withString:password];
        }
        OrderWebViewController* orderWebVC = [[OrderWebViewController alloc] init];
        orderWebVC.stringURL = orderWebURL;
        [self.navigationController pushViewController:orderWebVC animated:YES];
    }else{
        if ([GLOBALVAR isLogin]) {
            [self chooseAddressForCheckOut];
            return;
        }
        [self askCustomerRole];
    }
}

#pragma mark Ask Roles
- (void)checkoutAsExistingCustomer{
    isNewCustomer = NO;
    [[SCAppController sharedInstance]openLoginScreenWithNavigationController:self.navigationController moreParams:@{KEYEVENT.LOGINVIEWCONTROLLER.is_login_on_checkout:[NSNumber numberWithBool:YES],KEYEVENT.APPCONTROLLER.is_showpopover:[NSNumber numberWithBool:YES]}];
}

- (void)checkoutAsNewCustomer{
    isNewCustomer = YES;
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithDictionary:@{KEYEVENT.APPCONTROLLER.delegate:self, KEYEVENT.NEWADDRESSVIEWCONTROLLER.is_newcustomer:[NSNumber numberWithBool:YES], KEYEVENT.APPCONTROLLER.is_showpopover:[NSNumber numberWithBool:YES]}];
    if (cacheAddressModel != nil) {
        [params setValue:cacheAddressModel forKey:KEYEVENT.NEWADDRESSVIEWCONTROLLER.address_model];
    }
    [[SCAppController sharedInstance]openNewAddressWithNavigationController:self.navigationController moreParams:params];
}

- (void)checkoutAsGuest{
    isNewCustomer = NO;
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithDictionary:@{KEYEVENT.APPCONTROLLER.delegate:self, KEYEVENT.APPCONTROLLER.is_showpopover:[NSNumber numberWithBool:YES]}];
    if (cacheAddressModel != nil) {
        [params setValue:cacheAddressModel forKey:KEYEVENT.NEWADDRESSVIEWCONTROLLER.address_model];
    }
    [[SCAppController sharedInstance]openNewAddressWithNavigationController:self.navigationController moreParams:params];
}

- (void)chooseAddressForCheckOut{
    [[SCAppController sharedInstance]openAddressBookWithNavigationController:self.navigationController moreParams:@{KEYEVENT.APPCONTROLLER.delegate:self, KEYEVENT.APPCONTROLLER.is_showpopover:[NSNumber numberWithBool:YES], KEYEVENT.ADDRESSVIEWCONTROLLER.open_address_from:[NSNumber numberWithInteger:PositionOpenAddressBookFromCart]}];
}

#pragma mark New Address Delegate
- (void)didSaveAddress:(SimiAddressModel *)address{
    cacheAddressModel = address;
    [self dismissViewControllerAnimated:YES completion:nil];
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (isNewCustomer) {
        [params setValue:[NSNumber numberWithInteger:CheckOutTypeNewCustomer] forKey:KEYEVENT.ORDERVIEWCONTROLLER.checkOut_type];
    }else
        [params setValue:[NSNumber numberWithInteger:CheckOutTypeGuest] forKey:KEYEVENT.ORDERVIEWCONTROLLER.checkOut_type];
    [[SCAppController sharedInstance]openOrderReviewcScreenWithNavigationController:self.navigationController shippingAddress:address billingAddress:address moreParams:params];
}

#pragma mark Address Delegate
- (void)selectAddress:(SimiAddressModel *)address{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[SCAppController sharedInstance]openOrderReviewcScreenWithNavigationController:self.navigationController shippingAddress:address billingAddress:address moreParams:@{KEYEVENT.ORDERVIEWCONTROLLER.checkOut_type:[NSNumber numberWithInteger:CheckOutTypeExitCustomer]}];
}

#pragma mark Notification Action
- (void)didLogin:(NSNotification*)noti{
    [self getCart];
    [self chooseAddressForCheckOut];
}
@end
