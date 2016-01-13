//
//  SCCartViewControllerPad_Theme01.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/11/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//
#import <SimiCartBundle/UIImage+SimiCustom.h>

#import "SCCartViewControllerPad_Theme01.h"
#import "SCOrderViewControllerPad_Theme01.h"
@class SCCartViewControllerPad_Theme01;
@interface SCCartViewControllerPad_Theme01 ()

@end

@implementation SCCartViewControllerPad_Theme01

+ (instancetype)sharedInstance{
    static SCCartViewControllerPad_Theme01 *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [SCCartViewControllerPad_Theme01 new];
    });
    return _sharedInstance;
}

- (void)viewDidLoadBefore
{
    [self setNavigationBarOnViewDidLoadForTheme01];
    if(self.isDiscontinue){
        self.isDiscontinue = NO;
        return;
    }
    _cartDetailController = [[SCCartDetailControllerPad_Theme01 alloc]init];
    [_cartDetailController.view setFrame:CGRectMake(1, 10, 620, 700)];
    _cartDetailController.delegate = self;
    [self.view addSubview:_cartDetailController.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCLoginViewController-DidCancel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidLogin" object:nil];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    [_cartDetailController.view setFrame:CGRectMake(1, 10, 620, 700)];
    [self setNavigationBarOnViewWillAppearForTheme01];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [_cartDetailController getCart];
}

#pragma mark Cart Detail Delegate
- (void)backToHomeWhenOrderSuccess
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}
- (void) setCartPrices:(NSMutableArray *)cartPrices isCheckoutable:(BOOL) isCheckout cart:(SimiCartModelCollection *)cart
{
    if(_cartTotalController == nil && isCheckout){
        _cartTotalController = [[SCCartTotalControllerPad_Theme01 alloc]init];
        _cartTotalController.delegate = self;
        [_cartTotalController.view setFrame:CGRectMake(630, 70, 390, 700)];
        if(_clearView == nil){
            _clearView = [[UIView alloc]initWithFrame:CGRectMake(625, 0, 390, 70)];
        }
       
        UIImage *imgClear = [[UIImage imageNamed:@"theme01_cart_clear"] imageWithColor:THEME_COLOR];
        UIImageView *clearImage = [[UIImageView alloc]initWithFrame:CGRectMake(260, 35, 18, 18)];
        clearImage.image = imgClear;
        [_clearView addSubview:clearImage];
        UILabel *clearLabel = [[UILabel alloc] initWithFrame:CGRectMake(290, 28, 120, 30)];
        clearLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:20];
        clearLabel.backgroundColor = [UIColor clearColor];
        clearLabel.text = SCLocalizedString(@"Clear All");
        clearLabel.textColor = THEME_COLOR;
        
        UIButton *clearButton = [[UIButton alloc]initWithFrame:CGRectMake(260, 30, 150, 40)];
        [clearButton addTarget:self action:@selector(clearAllProductsInCart) forControlEvents:UIControlEventTouchUpInside];
        [_clearView addSubview:clearButton];
        [_clearView addSubview:clearLabel];
        
        
        UIView *borderView = [[UIView alloc]initWithFrame:CGRectMake(0, 70, 1, 390)];
        [borderView setBackgroundColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#d9d9d9"]];
        [_clearView addSubview:borderView];
        [self.view addSubview:_clearView];
    }else if(isCheckout)
    {
         [_clearView setHidden:NO];
    }
    [_cartTotalController setIsCheckoutable:isCheckout];
    [_cartTotalController setCartPrices:cartPrices];
    [_cartTotalController reloadData];
    [_cartTotalController setCart:cart];
    [self.view addSubview:_cartTotalController.view];
}

- (void)showProductDetail:(NSString *)productId_
{
    SCProductViewControllerPad_Theme01 *productController = [[SCProductViewControllerPad_Theme01 alloc]init];
    productController.productId = productId_;
    [self.navigationController pushViewController:productController animated:YES];
}

#pragma mark Action
- (void) clearAllProductsInCart
{
    [_cartDetailController clearAllProductsInCart];
    [_clearView setHidden:YES];
}

#pragma mark Receive Noti
- (void)didReceiveNotification:(NSNotification *)noti
{
    if([noti.name isEqualToString:@"AddToCart"])
    {
        if (_cartDetailController == nil) {
            _cartDetailController = [[SCCartDetailControllerPad_Theme01 alloc]init];
            [_cartDetailController.view setFrame:CGRectMake(1, 10, 590, 700)];
        }
        [_cartDetailController addProductToCart:noti];
    }else if ([noti.name isEqualToString:@"SCLoginViewController-DidCancel"])
    {
        [self showScreenWhenHiddenPopOver];
    }else if ([noti.name isEqualToString:@"DidLogin"])
    {
        [_popController dismissPopoverAnimated:YES];
        [self showScreenWhenHiddenPopOver];
        [self.cartDetailController getCart];
        
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
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"isLogin"]) {
        if (_cartDetailController == nil) {
            _cartDetailController = [[SCCartDetailControllerPad_Theme01 alloc]init];
            [_cartDetailController.view setFrame:CGRectMake(1, 10, 590, 700)];
        }
        [_cartDetailController getCart];
    }
}

#pragma mark TotalController Delegate
- (void)didClickCheckOut
{
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
    [self.cartDetailController getCart];
}

- (void)didGetAddressModelForCheckOut:(SimiAddressModel *)addressModel andIsNewCustomer:(BOOL)isNewCus
{
    [_popController dismissPopoverAnimated:YES];
    [self showScreenWhenHiddenPopOver];
    SCOrderViewControllerPad_Theme01 *orderViewController = [[SCOrderViewControllerPad_Theme01 alloc]init];
    orderViewController.isNewCustomer = isNewCus;
    orderViewController.shippingAddress = [addressModel mutableCopy];
    orderViewController.billingAddress = [addressModel mutableCopy];
    if (orderViewController.isNewCustomer) {
        orderViewController.addressNewCustomerModel = addressModel;
    }
    orderViewController.cart = [self.cartDetailController.cart mutableCopy];
    orderViewController.cartPrices = [self.cartDetailController.cartPrices mutableCopy];
    [self.navigationController pushViewController:orderViewController animated:YES];
}

#pragma  mark UIPopover Delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self showScreenWhenHiddenPopOver];
    _popController = nil;
}

#pragma mark Address Delegate
- (void)selectAddress:(SimiAddressModel *)address
{
    [_popController dismissPopoverAnimated:YES];
    [self showScreenWhenHiddenPopOver];
    SCOrderViewControllerPad_Theme01 *orderViewController = [[SCOrderViewControllerPad_Theme01 alloc]init];
    orderViewController.shippingAddress = [address mutableCopy];
    orderViewController.billingAddress = [address mutableCopy];
    orderViewController.cart = [self.cartDetailController.cart mutableCopy];
    orderViewController.cartPrices = [self.cartDetailController.cartPrices mutableCopy];
    [self.navigationController pushViewController:orderViewController animated:YES];
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
                SCLoginViewController_Theme01 *nextController = [[SCLoginViewController_Theme01 alloc] init];
                nextController.delegate = self;
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
                SCLoginViewController_Theme01 *nextController = [[SCLoginViewController_Theme01 alloc] init];
                nextController.delegate = self;
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
    SCOrderViewControllerPad_Theme01 *orderViewController = [[SCOrderViewControllerPad_Theme01 alloc]init];
    orderViewController.shippingAddress = [address mutableCopy];
    orderViewController.billingAddress = [address mutableCopy];
    orderViewController.isNewCustomer = self.isNewCustomer;
    if (self.isNewCustomer) {
        orderViewController.addressNewCustomerModel = address;
    }
    orderViewController.cart = [self.cartDetailController.cart mutableCopy];
    orderViewController.cartPrices = [self.cartDetailController.cartPrices mutableCopy];
    [self.navigationController pushViewController:orderViewController animated:YES];
}
@end
