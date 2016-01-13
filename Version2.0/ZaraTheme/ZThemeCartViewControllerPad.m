//
//  ZThemeCartViewControllerPad.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 5/28/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeCartViewControllerPad.h"

#import <SimiCartBundle/SimiProductModel.h>
#import <SimiCartBundle/SimiResponder.h>
#import <SimiCartBundle/SCOrderFeeCell.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>

#import "SimiViewController+ZTheme.h"
#import "ZThemeOrderViewControllerPad.h"
#import "ZThemeProductViewControllerPad.h"
#import "ZThemeWorker.h"

@interface ZThemeCartViewControllerPad ()

@end

@implementation ZThemeCartViewControllerPad
{
    UIView * verticalBorder;
}

@synthesize cartCells = _cartCells, headerView, emptyLabel;

+ (instancetype)sharedInstance{
    static ZThemeCartViewControllerPad * _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ZThemeCartViewControllerPad alloc] init];
    });
    return _sharedInstance;
}

- (void)viewDidLoadBefore
{
    [super viewDidLoadBefore];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.tableViewCart setFrame:CGRectMake(674, 80, 350, 688)];
    if (self.tableviewProduct ==nil) {
        self.tableviewProduct = [UITableView new];
        self.tableviewProduct.delegate = self;
        self.tableviewProduct.dataSource = self;
        self.tableviewProduct.frame = CGRectMake(20, 140, 650, 628);
        [self.tableviewProduct setContentInset:UIEdgeInsetsZero];
        [self.tableviewProduct setContentOffset:CGPointMake(0, 0)];
        [self.view addSubview:self.tableviewProduct];
    }
    [self addGestureRecognizer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidLogin" object:nil];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    [self updateHeaderView];
    [self updateEmptyLabel];
    [self updateNavigationBar];
}

- (void)reloadData
{
    _cartCells = nil;
    [self.tableViewCart reloadData];
    [self.tableviewProduct reloadData];
    [self updateHeaderView];
    [self updateEmptyLabel];
    [self updateNavigationBar];
}

#pragma mark - Init Cart Cells
- (SimiTable *)cartCells
{
    if (_cartCells) {
        return _cartCells;
    }
    _cartCells = [SimiTable new];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitCartCell-Before" object:_cartCells];
    
    SimiSection *cartTable = [_cartCells addSectionWithIdentifier:CART_PRODUCTS];
    if ([self.cart count]) {
        [cartTable addRowWithIdentifier:CART_TOTALS height:(27 * self.cartPrices.count + 20)];
        [cartTable addRowWithIdentifier:CART_BUTTON height:100];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitCartCell-After" object:_cartCells];
    return _cartCells;
}

#pragma mark Table View Data Source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}


#pragma mark Table View Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableviewProduct)
        return 300;
    else
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableviewProduct)
        return self.cart.count;
    else
        return [super tableView:tableView numberOfRowsInSection:section];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableviewProduct)
        return 1;
    return [super numberOfSectionsInTableView:tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableviewProduct) {
        SimiCartModel *item = [self.cart objectAtIndex:indexPath.row];
        ZThemeProductViewControllerPad * nextController = [ZThemeProductViewControllerPad new];
        NSString * productId = (NSString *)[item valueForKeyPath:@"product_id"];
        nextController.productId =  productId;
        nextController.arrayProductsID = [[NSMutableArray alloc]initWithObjects:productId, nil];
        nextController.firstProductID = productId;
        [self.navigationController pushViewController:nextController animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableviewProduct) {
        SimiCartModel *item = [self.cart objectAtIndex:indexPath.row];
        NSString *SCCartCellIdentifier = [NSString stringWithFormat:@"%@_%@", @"SCCartCellIdentifier", [item valueForKey:@"cart_item_id"]];
        ZThemeCartCellPad *cell = [tableView dequeueReusableCellWithIdentifier:SCCartCellIdentifier];
        if (cell == nil) {
            cell = [[ZThemeCartCellPad alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SCCartCellIdentifier];
            if ([item valueForKeyPath:@"cart_item_name"] == nil) {
                NSString *cartItemName = [item valueForKeyPath:@"product_name"];
                for (NSDictionary *option in [item valueForKeyPath:@"options"]) {
                    cartItemName = [NSString stringWithFormat:@"%@, %@", cartItemName, [option valueForKeyPath:@"option_value"]];
                }
                [item setValue:cartItemName forKeyPath:@"cart_item_name"];
            }
            [cell setCellWith:620];
            [cell setItem:item];
            [cell setName:[item valueForKeyPath:@"product_name"]];
            [cell setPrice:[item valueForKey:@"product_price"]];
            NSString *cartItemID = [item valueForKey:@"cart_item_id"];
            [cell setQty:[NSString stringWithFormat:@"%@", [item valueForKey:@"product_qty"]]];
            [cell setCartItemId:cartItemID];
            cell.delegate = self;
            [cell setImagePath:[item valueForKey:@"product_image"]];
            [cell setTextFieldTag:indexPath.row];
            [cell setStockStatus:1];
            cell.qtyTextField.delegate = self;
            [cell setInterfaceCell];
            if (qtyTextFieldList == nil) {
                qtyTextFieldList = [[NSMutableDictionary alloc] init];
            }
            [qtyTextFieldList setValue:cell.qtyTextField forKey:cartItemID];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell setPrice:[item valueForKey:@"product_price"]];
        [cell setQty:[NSString stringWithFormat:@"%@", [item valueForKey:@"product_qty"]]];
        return cell;
    }
    else
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}



#pragma mark Header Functions
- (void)updateHeaderView
{
    if (headerView != nil)
    {
        [headerView removeFromSuperview];
        headerView = nil;
    }
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 80)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    
    if (self.cart.count > 0) {
        //Clear Cart
        UIImage *imgClear = [[UIImage imageNamed:@"Ztheme_cart_clear~ipad"] imageWithColor:THEME_COLOR];
        UIImageView *clearImage = [[UIImageView alloc]initWithFrame:CGRectMake(40, 34, 25, 25)];
        clearImage.image = imgClear;
        [headerView addSubview:clearImage];
        UILabel *clearLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 35, 90, 20)];
        clearLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", ZTHEME_FONT_NAME_REGULAR] size:THEME_FONT_SIZE];
        clearLabel.backgroundColor = [UIColor clearColor];
        clearLabel.text = SCLocalizedString(@"Clear All");
        clearLabel.textColor = THEME_COLOR;
        [headerView addSubview:clearLabel];
        UIButton *clearButton = [[UIButton alloc]initWithFrame:CGRectMake(40, 30, 110, 30)];
        [clearButton addTarget:self action:@selector(clearAllProductsInCart) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:clearButton];
        
        UIImage *imgUpdate = [[UIImage imageNamed:@"Ztheme_cart_update~ipad"]imageWithColor:THEME_COLOR];
        UIImageView *updateImage = [[UIImageView alloc]initWithFrame:CGRectMake(860, 34, 25, 25)];
        updateImage.image = imgUpdate;
        [headerView addSubview:updateImage];
        UILabel *updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(890, 35, 90, 20)];
        updateLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", ZTHEME_FONT_NAME_REGULAR] size:THEME_FONT_SIZE];
        updateLabel.backgroundColor = [UIColor clearColor];
        updateLabel.text = SCLocalizedString(@"Refresh");
        updateLabel.textColor = THEME_COLOR;
        
        UIButton *updateButton = [[UIButton alloc]initWithFrame:CGRectMake(860, 30, 110, 30)];
        [updateButton addTarget:self action:@selector(getCart) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:updateButton];
        [headerView addSubview:updateLabel];
        
        UIView * bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 79, 1024, 1)];
        [bottomLine setBackgroundColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#dbdbdb"]];
        [headerView addSubview:bottomLine];
    }
    [self.view addSubview:headerView];
    [self.view bringSubviewToFront:headerView];
}

#pragma mark Empty Label

- (void)updateEmptyLabel
{
    if (emptyLabel == nil) {
        emptyLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 300, 824, 80)];
        emptyLabel.text = SCLocalizedString(@"You have no items in your shopping cart.");
        emptyLabel.textColor = [UIColor blackColor];
        emptyLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", ZTHEME_FONT_NAME_LIGHT] size:THEME_FONT_SIZE+3];
        [emptyLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [emptyLabel setTextAlignment:NSTextAlignmentCenter];
        [emptyLabel setNumberOfLines:2];
        [self.view addSubview:emptyLabel];
    }
    
    //vertical border
    if (verticalBorder ==nil) {
        verticalBorder = [[UIView alloc]initWithFrame:CGRectMake(669, 140, 1, 628)];
        [verticalBorder setBackgroundColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#dbdbdb"]];
        [verticalBorder setHidden:YES];
        [self.view addSubview:verticalBorder];
    }
    
    if (self.cart.count ==0) {
        [emptyLabel setHidden:NO];
        [verticalBorder setHidden:YES];
    }
    else {
        [emptyLabel setHidden:YES];
        [verticalBorder setHidden:NO];
    }
}

#pragma mark Navigation Bar

- (void)updateNavigationBar
{
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.leftBarButtonItems = [[ZThemeWorker sharedInstance] navigationBarPad].leftButtonItems;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

#pragma mark CartCellPad Delegate

- (void)showProductDetail:(NSString*)productID{

}

#pragma mark Cart Actions
- (void)checkout {
    if ([[SimiGlobalVar sharedInstance]isLogin]) {
        SCAddressViewController *addressViewController = [SCAddressViewController new];
        addressViewController.delegate = self;
        UINavigationController *navi;
        navi = [[UINavigationController alloc]initWithRootViewController:addressViewController];
        
        _popController = nil;
        _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
        addressViewController.popover = _popController;
        _popController.delegate = self;
        navi.navigationBar.tintColor = THEME_COLOR;
        if (SIMI_SYSTEM_IOS >= 8) {
            navi.navigationBar.tintColor = [UIColor whiteColor];
        }
        navi.navigationBar.barTintColor = THEME_COLOR;
        [self hiddenScreenWhenShowPopOver];
        [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
        return;
    }
    [self askCustomerRole];
}
#pragma mark BeforeOrder Delegate
- (void)didCancelCheckout
{
    if (_popController) {
        [_popController dismissPopoverAnimated:YES];
        [self showScreenWhenHiddenPopOver];
    }
}

- (void)reloadCartDetail
{
    [self getCart];
}

- (void)didGetAddressModelForCheckOut:(SimiAddressModel *)addressModel andIsNewCustomer:(BOOL)isNewCus
{
    [_popController dismissPopoverAnimated:YES];
    [self showScreenWhenHiddenPopOver];
    ZThemeOrderViewControllerPad *orderViewController = [[ZThemeOrderViewControllerPad alloc]init];
    orderViewController.isNewCustomer = isNewCus;
    orderViewController.shippingAddress = [addressModel mutableCopy];
    orderViewController.billingAddress = [addressModel mutableCopy];
    if (orderViewController.isNewCustomer) {
        orderViewController.addressNewCustomerModel = addressModel;
    }
    orderViewController.cart = [self.cart mutableCopy];
    orderViewController.cartPrices = [self.cartPrices mutableCopy];
    [self.navigationController pushViewController:orderViewController animated:YES];
}

#pragma  mark UIPopover Delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self showScreenWhenHiddenPopOver];
    _popController = nil;
}

- (void)askCustomerRole{
    UIActionSheet *actionSheet;
    SimiStoreModel *store = [[SimiGlobalVar sharedInstance] store];
    if ([[[store valueForKey:@"checkout_config"] valueForKey:@"enable_guest_checkout"] boolValue]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:SCLocalizedString(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:SCLocalizedString(@"Checkout as existing customer"), SCLocalizedString(@"Checkout as new customer"), SCLocalizedString(@"Checkout as guest"), nil];
    }else{
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:SCLocalizedString(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:SCLocalizedString(@"Checkout as existing customer"), SCLocalizedString(@"Checkout as new customer"), nil];
    }
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    SimiStoreModel *store = [[SimiGlobalVar sharedInstance] store];
    BOOL isEnableGuestCheckout = [[[store valueForKey:@"checkout_config"] valueForKey:@"enable_guest_checkout"] boolValue];
    if (isEnableGuestCheckout) {
        switch (buttonIndex) {
            case 0: //Checkout as existing customer
            {
                self.isNewCustomer = NO;
                SCLoginViewController *nextController = [[SCLoginViewController alloc] init];
                nextController.isLoginInCheckout = YES;
                
                UINavigationController *navi;
                navi = [[UINavigationController alloc]initWithRootViewController:nextController];
                
                _popController = nil;
                _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                nextController.popover = _popController;
                _popController.delegate = self;
                navi.navigationBar.tintColor = THEME_COLOR;
                if (SIMI_SYSTEM_IOS >= 8) {
                    navi.navigationBar.tintColor = [UIColor whiteColor];
                }
                navi.navigationBar.barTintColor = THEME_COLOR;
                [self hiddenScreenWhenShowPopOver];
                [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
                
            }
                break;
            case 1: //Checkout as new customer
            {
                self.isNewCustomer = YES;
                SCNewAddressViewController *nextController = [[SCNewAddressViewController alloc]init];
                nextController.isNewCustomer = YES;
                nextController.delegate = self;
                UINavigationController *navi;
                navi = [[UINavigationController alloc]initWithRootViewController:nextController];
                
                _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                nextController.popover = _popController;
                _popController.delegate = self;
                navi.navigationBar.tintColor = THEME_COLOR;
                if (SIMI_SYSTEM_IOS >= 8) {
                    navi.navigationBar.tintColor = [UIColor whiteColor];
                }
                navi.navigationBar.barTintColor = THEME_COLOR;
                [self hiddenScreenWhenShowPopOver];
                [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
            }
                break;
            case 2: //Checkout as guest
            {
                self.isNewCustomer = NO;
                SCNewAddressViewController *nextController = [[SCNewAddressViewController alloc]init];
                nextController.delegate = self;
                UINavigationController *navi;
                navi = [[UINavigationController alloc]initWithRootViewController:nextController];
                
                _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                nextController.popover = _popController;
                _popController.delegate = self;
                navi.navigationBar.tintColor = THEME_COLOR;
                if (SIMI_SYSTEM_IOS >= 8) {
                    navi.navigationBar.tintColor = [UIColor whiteColor];
                }
                navi.navigationBar.barTintColor = THEME_COLOR;
                [self hiddenScreenWhenShowPopOver];
                [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
            }
                break;
            default: //Cancel
                break;
        }
    }else
    {
        switch (buttonIndex) {
            case 0: //Checkout as existing customer
            {
                self.isNewCustomer = NO;
                SCLoginViewController *nextController = [[SCLoginViewController alloc] init];
                nextController.isLoginInCheckout = YES;
                
                UINavigationController *navi;
                navi = [[UINavigationController alloc]initWithRootViewController:nextController];
                
                _popController = nil;
                _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                nextController.popover = _popController;
                _popController.delegate = self;
                navi.navigationBar.tintColor = THEME_COLOR;
                if (SIMI_SYSTEM_IOS >= 8) {
                    navi.navigationBar.tintColor = [UIColor whiteColor];
                }
                navi.navigationBar.barTintColor = THEME_COLOR;
                [self hiddenScreenWhenShowPopOver];
                [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
            }
                break;
            case 1: //Checkout as new customer
            {
                self.isNewCustomer = YES;
                SCNewAddressViewController *nextController = [[SCNewAddressViewController alloc]init];
                nextController.isNewCustomer = YES;
                nextController.delegate = self;
                
                UINavigationController *navi;
                navi = [[UINavigationController alloc]initWithRootViewController:nextController];
                
                _popController = nil;
                _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                nextController.popover = _popController;
                _popController.delegate = self;
                navi.navigationBar.tintColor = THEME_COLOR;
                if (SIMI_SYSTEM_IOS >= 8) {
                    navi.navigationBar.tintColor = [UIColor whiteColor];
                }
                navi.navigationBar.barTintColor = THEME_COLOR;
                [self hiddenScreenWhenShowPopOver];
                [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
            }
                break;
            default: //Cancel
                break;
        }
    }
}

#pragma mark New Address Delegate
- (void)didSaveAddress:(SimiAddressModel *)address
{
    [_popController dismissPopoverAnimated:YES];
    [self showScreenWhenHiddenPopOver];
    ZThemeOrderViewControllerPad *orderViewController = [[ZThemeOrderViewControllerPad alloc]init];
    orderViewController.shippingAddress = [address mutableCopy];
    orderViewController.billingAddress = [address mutableCopy];
    orderViewController.isNewCustomer = self.isNewCustomer;
    if (self.isNewCustomer) {
        orderViewController.addressNewCustomerModel = address;
    }
    orderViewController.cart = [self.cart mutableCopy];
    orderViewController.cartPrices = [self.cartPrices mutableCopy];
    [self.navigationController pushViewController:orderViewController animated:YES];
}

#pragma mark Address Delegate
- (void)selectAddress:(SimiAddressModel *)address
{
    [_popController dismissPopoverAnimated:YES];
    [self showScreenWhenHiddenPopOver];
    ZThemeOrderViewControllerPad *orderViewController = [[ZThemeOrderViewControllerPad alloc]init];
    orderViewController.shippingAddress = [address mutableCopy];
    orderViewController.billingAddress = [address mutableCopy];
    orderViewController.cart = [self.cart mutableCopy];
    orderViewController.cartPrices = [self.cartPrices mutableCopy];
    [self.navigationController pushViewController:orderViewController animated:YES];
}

#pragma mark Notification Action
#pragma mark Receive Noti
- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"DidLogin"])
    {
        [_popController dismissPopoverAnimated:YES];
        [self showScreenWhenHiddenPopOver];
        [self getCart];
        
        SCAddressViewController *addressViewController = [SCAddressViewController new];
        addressViewController.delegate = self;
        UINavigationController *navi;
        navi = [[UINavigationController alloc]initWithRootViewController:addressViewController];
        
        _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
        addressViewController.popover = _popController;
        _popController.delegate = self;
        navi.navigationBar.tintColor = THEME_COLOR;
        if (SIMI_SYSTEM_IOS >= 8) {
            navi.navigationBar.tintColor = [UIColor whiteColor];
        }
        navi.navigationBar.barTintColor = THEME_COLOR;
        [self hiddenScreenWhenShowPopOver];
        [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
    }
    [super didReceiveNotification:noti];
}

@end
