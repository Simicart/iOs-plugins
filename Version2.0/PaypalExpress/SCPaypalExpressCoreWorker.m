//
//  SCPaypalExpressCoreWorker.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/17/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SCPaypalExpressCoreWorker.h"
#import "SCPaypalExpressWebViewController.h"
#import "SCPaypalExpressModel.h"
#import "SCPaypalExpressAddressReviewViewController.h"
#import "SCPaypalExpressShippingMethodViewController.h"
#import "SCProductViewController_Pad.h"
#import "SimiNavigationBarWorker.h"
#import "SimiCartPadWorker.h"

#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SCOrderViewController.h>
#import <SimiCartBundle/SCCartViewController.h>
#import <SimiCartBundle/SimiAddressModel.h>


#define CART_VIEW_WIDTH_PAD 682
#define CART_VIEW_HEIGHT_PAD 556


#define CHECK_OUT_WITH_PAYPAL_BUTTON_TAG 11111
#define CHECK_OUT_BUTTON_TAG 11112
#define CHECK_OUT_WITH_PAYPAL_BUTTON_TAG_PAD 12111
#define CHECK_OUT_WITH_PAYPAL_BUTTON_PRODUCT_TAG 13111

#define PAYPAL_EXPRESS_PRODUCT_BTN_VERTICAL_ALIGN_DISTANCE 10


#define CART_CHECKOUT_VIEW_HEIGHT 60
#define CART_CHECKOUT_BUTTON_IMAGE_WIDTH 220.0f
#define CART_CHECKOUT_BUTTON_IMAGE_HEIGHT 75.0f
#define CART_CHECKOUT_BUTTON_WIDTH 120
#define CART_CHECKOUT_BUTTON_HORIZON_ALIGN_DISTANCE 10


static NSString *PRODUCT_ADDTOCART_CELL_ID   = @"PRODUCT_OPTION_ADDTOCART_CELL_ID";

@implementation SCPaypalExpressCoreWorker
{
    BOOL reviewAddress;
    BOOL isTheme01;
    BOOL showButtonOnCart;
    
    UIViewController * currentVC;
    SCPaypalExpressWebViewController * paypalCheckoutView;
    SimiSection * section;
    SCProductViewController * currentProductViewController;
    SCCartViewController * cartViewController;
    SCOrderViewController * orderViewController;
    SCPaypalExpressModel * paypalModel;
    SCPaypalExpressAddressReviewViewController * addressReviewVC;
    SCPaypalExpressShippingMethodViewController * shippingMethodsVC;
    UIView * checkOutTopView;
    
    
    //ipad - theme01
    SCProductViewController_Pad * currentProductViewController_Pad;
    UIButton * checkOutButtonPad;
    NSMutableArray * productPadViewAddressArray;
    
    UIViewController * cartViewControllerPad; //when cart is not on popover
    
    UIPopoverController * paypalPopOver;
    SCCartViewController * paypalPopOverRootVC;
    BOOL checkOutFromProductView; //when customer checkout via product detail view
    BOOL openNewPopOver;
    BOOL startPaypalCheckOutRightAfterOpenCart;
    UIButton *paypalButton;
    
    //Ztheme
    UIView *zThemeViewAction;
    CGRect zThemeViewActionFrame;
}


- (id)init{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editAddToCartCell:) name:@"InitializedProductCell-After" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartControllerViewDidLoad:) name:@"SCCartViewController-ViewDidLoad" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(productDetailViewControllerPadWillAppear:) name:@"SCDetailViewControllerPad_Theme01-ViewWillAppear" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isTheme01Active:) name:@"SCHomeViewController_Theme01-ViewWillAppear" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cartViewControllerPadViewDidLoad:) name:@"SCCartViewControllerPad_Theme01-ViewDidLoad" object:nil];
        /*
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartControllerViewDidLoad_Theme01_ZTheme:) name:@"SCCartViewController_Theme01-ViewDidLoad" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartControllerViewDidLoad_Theme01_ZTheme:) name:@"ZThemeCartViewController-ViewDidLoad" object:nil];
        */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderControllerViewDidLoad:) name:@"SCOrderViewController-ViewDidLoad" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productViewControllerWillAppear:) name:@"SCProductViewController-ViewWillAppear" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartViewControllerWillAppear:) name:@"SCCartViewController-ViewWillAppear" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeLocationPaypalButton:) name:@"LoyaltyPlugin-Enable" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCart:) name:@"DidGetCart" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceOrderBefore:) name:@"DidPlaceOrder-Before" object:nil];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPaypalCheckoutButtonPad:) name:@"SCProductViewControllerPad-EndEditInfoProduct" object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productViewController_PadWillAppear:) name:@"SCProductViewController_Pad-ViewWillAppear" object:nil];
            productPadViewAddressArray = [NSMutableArray arrayWithObjects: nil];
        }
        
        if ([SimiGlobalVar sharedInstance].themeUsing == ThemeShowZTheme) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zThemeProductViewControllerPadDidLoadBefore:) name:@"ZThemeProductViewControllerPad_DidLoadBefore" object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zThemeProductViewControllerPadDidLoadBefore:) name:@"ZThemeProductViewController_DidLoadBefore" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zThemeCartViewControllerViewDidLoad:) name:@"ZThemeCartViewController-ViewDidLoad" object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zThemeDidGetProduct:) name:@"DidGetProductWithProductId" object:nil];
        }
        
        isTheme01 = NO;
        reviewAddress = YES;
        checkOutFromProductView = NO;
        openNewPopOver = NO;
        paypalModel = [[SCPaypalExpressModel alloc]init];
    }
    return self;
}

#pragma mark flag

- (void)isTheme01Active: (NSNotification *)noti
{
    isTheme01 = YES;
}

#pragma mark add 'checkout with paypal' button to product detail view screen
- (void)editAddToCartCell: (NSNotification *)noti
{
    SCProductViewController *productViewController = (SCProductViewController *)[noti.userInfo objectForKey:@"controller"];
    NSIndexPath * indexPath = (NSIndexPath *)[noti.userInfo objectForKey:@"indexPath"];
    
    if ((productViewController == nil)&&(isTheme01)&&(currentProductViewController_Pad!=nil)) {
        productViewController = (SCProductViewController *)currentProductViewController_Pad;
    }
    if (([productViewController.product objectForKey:@"is_paypal_express"]!=nil) && (![[productViewController.product objectForKey:@"is_paypal_express"] boolValue]))
        return;
    
    SimiSection * simiSection = [productViewController.cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    NSString *identifier = simiRow.identifier;
    UITableViewCell * cell = (UITableViewCell *)noti.object;
    
    if ([identifier isEqualToString:PRODUCT_ACTION_CELL_ID]||[identifier isEqualToString:PRODUCT_ADDTOCART_CELL_ID]) {
        int productButtonWidth = cell.frame.size.width - 20;
        int productButtonHeight = productButtonWidth * 144/992;
        
        if (isTheme01&&(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
            simiRow.height += productButtonHeight + 2*PAYPAL_EXPRESS_PRODUCT_BTN_VERTICAL_ALIGN_DISTANCE;
        }
        
        CGRect cellFrame= cell.frame;
        cellFrame.size.height += productButtonHeight + PAYPAL_EXPRESS_PRODUCT_BTN_VERTICAL_ALIGN_DISTANCE;
        cell.frame = cellFrame;
        BOOL addedBefore = NO;
        for (UIView *view in cell.subviews) {
            if (view.tag == CHECK_OUT_WITH_PAYPAL_BUTTON_PRODUCT_TAG) {
                addedBefore = YES;
                if ((!addedBefore)||(simiRow.height <= 120)) {
                    simiRow.height += productButtonHeight + 2*PAYPAL_EXPRESS_PRODUCT_BTN_VERTICAL_ALIGN_DISTANCE;
                }
                return;
            }
        }
        if ((!addedBefore)||(simiRow.height <= 120)) {
            simiRow.height += productButtonHeight + 2*PAYPAL_EXPRESS_PRODUCT_BTN_VERTICAL_ALIGN_DISTANCE;
        }
        
        CGRect paypalButtonFrame = CGRectMake(20/2, 40 + PAYPAL_EXPRESS_PRODUCT_BTN_VERTICAL_ALIGN_DISTANCE+ 10, productButtonWidth, productButtonHeight);
        
        CGFloat buttonRoundCorner = 5.0f;
        
        if (isTheme01) {
            paypalButtonFrame.origin.y += PAYPAL_EXPRESS_PRODUCT_BTN_VERTICAL_ALIGN_DISTANCE;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                paypalButtonFrame = CGRectMake(15, 100, 410, 60);
                buttonRoundCorner = 0;
            }
            
        }
        paypalButton = [[UIButton alloc]initWithFrame: paypalButtonFrame];
        
        paypalButton.layer.masksToBounds = YES;
        
        [paypalButton setBackgroundImage:[UIImage imageNamed:@"en_paypal_express_product_btn"] forState:UIControlStateNormal];
        [paypalButton.layer setCornerRadius:buttonRoundCorner];
        
        [paypalButton addTarget:self action:@selector(checkOutWithPaypalExpFromProductView:) forControlEvents:UIControlEventTouchUpInside];
        [paypalButton setTag:CHECK_OUT_WITH_PAYPAL_BUTTON_PRODUCT_TAG];
        
        [cell addSubview:paypalButton];
        
    }
    
}

- (void)zThemeProductViewControllerPadDidLoadBefore: (NSNotification *)noti
{
    
    zThemeViewAction = [noti.userInfo objectForKey:@"viewAction"];
    zThemeViewActionFrame = zThemeViewAction.frame;
    return;
    paypalButton = nil;
    paypalButton = [UIButton new];
    paypalButton.layer.masksToBounds = YES;
    [paypalButton setBackgroundImage:[UIImage imageNamed:@"en_paypal_express_product_btn"] forState:UIControlStateNormal];
    [paypalButton.layer setCornerRadius:5.0f];
    [paypalButton addTarget:self action:@selector(checkOutWithPaypalExpFromProductView:) forControlEvents:UIControlEventTouchUpInside];
    [paypalButton setTag:CHECK_OUT_WITH_PAYPAL_BUTTON_PRODUCT_TAG];
    zThemeViewAction = [noti.userInfo objectForKey:@"viewAction"];
    CGRect frame = zThemeViewAction.frame;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        paypalButton.frame = CGRectMake(340, 60, 320, 50);
        frame.origin.y -= 60;
        frame.size.height += 60;
        openNewPopOver = YES;
    }
    else {
        paypalButton.frame = CGRectMake(20, 50, 280, 40);
        frame.origin.y -= 50;
        frame.size.height += 50;
    }
    zThemeViewAction.frame = frame;
    
    [zThemeViewAction addSubview:paypalButton];
}

- (void)zThemeCartViewControllerViewDidLoad: (NSNotification *)noti
{
    cartViewController = (SCCartViewController *)noti.object;
}


-(void) zThemeDidGetProduct:(NSNotification *)noti
{
    SimiModel *productModel = noti.object;
    if ([[productModel objectForKey:@"is_paypal_express"] boolValue]) {
        paypalButton = nil;
        paypalButton = [UIButton new];
        paypalButton.layer.masksToBounds = YES;
        [paypalButton setBackgroundImage:[UIImage imageNamed:@"en_paypal_express_product_btn"] forState:UIControlStateNormal];
        [paypalButton.layer setCornerRadius:5.0f];
        [paypalButton addTarget:self action:@selector(checkOutWithPaypalExpFromProductView:) forControlEvents:UIControlEventTouchUpInside];
        [paypalButton setTag:CHECK_OUT_WITH_PAYPAL_BUTTON_PRODUCT_TAG];
        CGRect frame = zThemeViewActionFrame;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            paypalButton.frame = CGRectMake(340, 60, 320, 50);
            frame.origin.y -= 60;
            frame.size.height += 60;
            openNewPopOver = YES;
        }
        else {
            paypalButton.frame = CGRectMake(20, 50, 280, 40);
            frame.origin.y -= 50;
            frame.size.height += 50;
        }
        zThemeViewAction.frame = frame;
        [zThemeViewAction addSubview:paypalButton];
    }
}


#pragma mark -
#pragma mark Events Handle


- (void)productViewControllerWillAppear: (NSNotification *)noti
{
    currentProductViewController = (SCProductViewController *)noti.object;
}

- (void)productDetailViewControllerPadWillAppear: (NSNotification *)noti
{
    currentProductViewController_Pad = (SCProductViewController_Pad *)noti.object;
}

- (void)didAddProductToCart: (NSNotification *)noti
{
    UIViewController * currenViewController = currentProductViewController;
    //ipad default
    if (checkOutFromProductView) {
        currentProductViewController = (SCProductViewController *)currentProductViewController_Pad;
        if (currentProductViewController_Pad.popOver != nil) {
            [currentProductViewController_Pad.navigationController popViewControllerAnimated:YES];
            [currentProductViewController_Pad.popOver dismissPopoverAnimated:YES];
        }
        
        [self openCartView];
        [self removeObserverForNotification:noti];
        return;
        //[self addIpadAlignmentEventCatcher];
    }
    
    //theme01 OR ZTHEME IPHONE
    if (isTheme01 || (([SimiGlobalVar sharedInstance].themeUsing == ThemeShowZTheme) &&(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad))) {
        [currentProductViewController.navigationController popToRootViewControllerAnimated:NO];
        [self startPaypalCheckoutTheme01:currenViewController];
        [self removeObserverForNotification:noti];
        return;
    }
    
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [self startPaypalCheckOut:currentProductViewController];
    }
    [self removeObserverForNotification:noti];
}

- (void)didCompletePaypalWebCheckout: (NSNotification *)noti
{
    reviewAddress = [(NSNumber *)[noti.userInfo objectForKey:@"review_address"] boolValue];
    [paypalModel reviewAddress];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetPaypalAdressInformation:) name:@"DidGetPaypalAdressInformation" object:nil];
    
    [self removeObserverForNotification:noti];
}

- (void)didGetPaypalAdressInformation: (NSNotification *)noti
{
    [cartViewController startLoadingData];
    [paypalCheckoutView.navigationController popViewControllerAnimated:YES];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [self removeObserverForNotification:noti];
        cartViewController.tabBarController.selectedIndex = 3;
        currentVC = cartViewController;
        if (reviewAddress) {
            // open address reviewing screen
            [self openReviewAddressViewController];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paypalDidCompleteReviewAddress:) name:@"DidUpdatePaypalCheckoutAddress" object:nil];
        }
        else {
            if (addressReviewVC!=nil) {
                [addressReviewVC.navigationController popViewControllerAnimated:NO];
            }
            addressReviewVC = [[SCPaypalExpressAddressReviewViewController alloc]init];
            if (addressReviewVC.paypalModelCollection == nil) {
                addressReviewVC.paypalModelCollection = [[SCPaypalExpressModelCollection alloc]init];
            }
            // no need to review address
            [addressReviewVC.paypalModelCollection getShippingMethods];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paypalDidCompleteReviewAddress:) name:@"DidGetPaypalCheckoutShippingMethods" object:nil];
        }
    }
    else {
        UIAlertView * a = [[UIAlertView alloc]initWithTitle:SCLocalizedString(@"Error") message:responder.responseMessage delegate:self cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [a show];
        
    }
}

- (void)paypalDidCompleteReviewAddress: (NSNotification *)noti
{
    if (noti!=nil) {
        [self removeObserverForNotification:noti];
    }
    if (addressReviewVC!=nil) {
        [addressReviewVC.navigationController popViewControllerAnimated:NO];
    }
    if (shippingMethodsVC!=nil) {
        [shippingMethodsVC.navigationController popViewControllerAnimated:NO];
    }
    shippingMethodsVC = [[SCPaypalExpressShippingMethodViewController alloc]init];
    shippingMethodsVC.paypalModelCollection = addressReviewVC.paypalModelCollection;
    [cartViewController.navigationController pushViewController:shippingMethodsVC animated:YES];
    if ([cartViewController respondsToSelector:@selector(clearCart)]) {
        [[NSNotificationCenter defaultCenter] addObserver:cartViewController selector:@selector(clearCart) name:@"DidPlaceOrder-After" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceOrderAfter:) name:@"DidPlaceOrder-After"  object:nil];
    }
}


- (void)cartControllerViewDidLoad: (NSNotification *)noti
{
    cartViewController = (SCCartViewController *)noti.object;
    if (isTheme01 || ([SimiGlobalVar sharedInstance].themeUsing == ThemeShowZTheme)){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCartPaypalCheckoutButton:) name:@"InitializedCartCell-After" object:nil];
    }
    [self removeObserverForNotification:noti];
}

- (void)didPlaceOrderAfter: (NSNotification *)noti
{
    SimiResponder * responder = [noti.userInfo valueForKey:@"responder"];
    if (openNewPopOver) {
        [paypalPopOver dismissPopoverAnimated:YES];
        [currentProductViewController.navigationController popToRootViewControllerAnimated:YES];
        [cartViewControllerPad.navigationController popToRootViewControllerAnimated:YES];
    }
    NSString * resultmessage = @"Thank you for your purchase";
    if (![responder.status isEqualToString:@"SUCCESS"])
        resultmessage = [responder.message objectAtIndex:0];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:resultmessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
    [alertView show];
    [cartViewController.navigationController popToRootViewControllerAnimated:YES];
}


//while paypal checkout runs like normall offline payments

- (void)didPlaceOrderBefore:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"DidPlaceOrder-Before"]){
        SimiModel *payment = [noti.userInfo valueForKey:@"payment"];
        if ([[payment valueForKey:@"payment_method"] isEqualToString:@"PAYPAL_EXPRESS"]) {
            if (isTheme01 || ([[SimiGlobalVar sharedInstance]themeUsing] == ThemeShowZTheme)) {
                [self startPaypalCheckoutTheme01:nil];
                return;
            }
            
            SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
            if ([responder.status isEqualToString:@"SUCCESS"]) {
                [cartViewController.navigationController popViewControllerAnimated:NO];
                [self startPaypalCheckOut:cartViewController];
            }
        }
    }
}

- (void)didGetCart: (NSNotification *)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        showButtonOnCart = NO;
        if (([responder.other valueForKey:@"is_paypal_express"]== nil) || ([[responder.other valueForKey:@"is_paypal_express"] boolValue] )) {
            showButtonOnCart = YES;
            [self addTopViewToCart];
        }
        [self removeObserverForNotification:noti];
    }
}

#pragma mark -
#pragma mark iPad and other themes events

- (void)productViewController_PadWillAppear: (NSNotification *)noti
{
    currentProductViewController_Pad = (SCProductViewController_Pad *)noti.object;
}

- (void)cartViewControllerWillAppear: (NSNotification *)noti
{
    if (checkOutTopView != nil) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // ipad
            CGRect cartframe = cartViewController.view.frame;
            checkOutTopView.frame = CGRectMake(checkOutTopView.frame.origin.x, 44, cartframe.size.width, checkOutTopView.frame.size.height);
            CGRect frame = cartViewController.tableViewCart.frame;
            frame.origin.y += (64 - 44);
            frame.size.height = frame.size.height - (64 - 44);
            cartViewController.tableViewCart.frame = frame;
            for (UIView * view in checkOutTopView.subviews) {
                if (view.tag == CHECK_OUT_BUTTON_TAG) {
                    view.frame = CGRectMake(cartframe.size.width -CART_CHECKOUT_BUTTON_HORIZON_ALIGN_DISTANCE - view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                }
            }
            //[self addIpadAlignmentEventCatcher];
        }
        [self removeObserverForNotification:noti];
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self addIpadAlignmentEventCatcher];
    }
    if (checkOutFromProductView) {
        [self cartPaypalButtonClicked:nil];
    }
}

- (void)addPaypalCheckoutButtonPad: (NSNotification *)noti
{
    if ((currentProductViewController_Pad != nil)&&(([currentProductViewController_Pad.product objectForKey:@"is_paypal_express"]==nil)||([[currentProductViewController_Pad.product objectForKey:@"is_paypal_express"] boolValue]))) {
        BOOL addedBefore = NO;
        if (checkOutButtonPad==nil) {
            checkOutButtonPad = [[UIButton alloc]init];
            [checkOutButtonPad setBackgroundImage:[UIImage imageNamed:@"en_paypal_express_product_pad"] forState:UIControlStateNormal];
            [checkOutButtonPad addTarget:self action:@selector(checkOutWithPaypalExpFromProductView:) forControlEvents:UIControlEventTouchUpInside];
            checkOutButtonPad.layer.masksToBounds = YES;
            [checkOutButtonPad.layer setCornerRadius:3.0f];
            
        }
        for (NSString * string in productPadViewAddressArray) {
            if ([string isEqualToString:[NSString stringWithFormat:@"%lu",(uintptr_t)currentProductViewController_Pad]]) {
                addedBefore = YES;
            }
        }
        
        UIButton * button = currentProductViewController_Pad.btaddToCart;
        CGRect newFrame = CGRectMake(button.frame.origin.x + button.frame.size.width + 20, button.frame.origin.y, button.frame.size.width, button.frame.size.height);
        if (!addedBefore) {
            [UIView animateWithDuration:0.3 animations:^{[checkOutButtonPad setFrame:newFrame];}];
            [currentProductViewController_Pad.scrollView addSubview:checkOutButtonPad];
        }
        if ([[currentProductViewController_Pad.product valueForKey:@"stock_status"] boolValue])
            checkOutButtonPad.hidden = NO;
        else
            checkOutButtonPad.hidden = YES;
    }
}

- (void)webViewControllerDidLoad: (NSNotification *)noti
{
    SCPaypalExpressWebViewController * webView = (SCPaypalExpressWebViewController *)noti.object;
    CGRect frame = webView.paypalExpCheckOutWebView.frame;
    frame.size.width = CART_VIEW_WIDTH_PAD;
    frame.size.height = CART_VIEW_HEIGHT_PAD;
    frame.origin.y = 0;
    webView.paypalExpCheckOutWebView.frame = frame;
}

- (void)addressReviewViewControllerDidLoad: (NSNotification *)noti
{
    SCPaypalExpressAddressReviewViewController * addressView = (SCPaypalExpressAddressReviewViewController *)noti.object;
    CGRect frame = addressView.addressTableView.frame;
    frame.size.width = CART_VIEW_WIDTH_PAD;
    addressView.addressTableView.frame = frame;
}

- (void)shippingMethodsViewControllerDidLoad: (NSNotification *)noti
{
    SCPaypalExpressShippingMethodViewController * shippingView = (SCPaypalExpressShippingMethodViewController *)noti.object;
    CGRect frame = shippingView.shippingMethodTableView.frame;
    frame.size.width = CART_VIEW_WIDTH_PAD;
    shippingView.shippingMethodTableView.frame = frame;
}


//for theme01 - matrixTheme - iphone - ztheme

- (void)addCartPaypalCheckoutButton: (NSNotification *)noti
{
    if (![(SCCartViewController *)noti.object isCheckoutable]) return;
    if (!showButtonOnCart) return;
    
    SimiRow *row = (SimiRow *)[noti.userInfo objectForKey:@"row"];
    
    if ([row.identifier isEqualToString:CART_BUTTON]) {
        
        
        UITableViewCell * cell = (UITableViewCell *)[(SCCartViewController *)noti.object simiObjectIdentifier];
        CGRect buttonFrame = CGRectMake(10, 60, 300, 40);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            row.height = row.height + 50 + PAYPAL_EXPRESS_PRODUCT_BTN_VERTICAL_ALIGN_DISTANCE;
            if (isTheme01){
                buttonFrame = CGRectMake(10, 70, 360, 50);
            }
            openNewPopOver = YES;
        }
        else {
            row.height += PAYPAL_EXPRESS_PRODUCT_BTN_VERTICAL_ALIGN_DISTANCE;
        }
        
        paypalButton = [[UIButton alloc]initWithFrame:buttonFrame];
        
        paypalButton.layer.masksToBounds = YES;
        [paypalButton setBackgroundImage:[UIImage imageNamed:@"en_paypal_express_product_btn"] forState:UIControlStateNormal];
        [paypalButton.layer setCornerRadius:5.0f];
        
        [paypalButton addTarget:self action:@selector(cartPaypalButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:paypalButton];
    }
    if (startPaypalCheckOutRightAfterOpenCart) {
        [self cartPaypalButtonClicked:nil];
        startPaypalCheckOutRightAfterOpenCart = NO;
    }
}

- (void)cartViewControllerWillAppear_Theme01: (NSNotification *)noti
{
    [self cartPaypalButtonClicked:nil];
    [self removeObserverForNotification:noti];
}

#pragma mark add topview to cart (doesn't appear on theme01 version)
- (void)addTopViewToCart
{
    if (isTheme01 || ([SimiGlobalVar sharedInstance].themeUsing == ThemeShowZTheme)) {
        return;
    }
    cartViewController.tableViewCart.frame = CGRectMake(0,CART_CHECKOUT_VIEW_HEIGHT,SCREEN_WIDTH,SCREEN_HEIGHT - CART_CHECKOUT_VIEW_HEIGHT);
    if (checkOutTopView == nil) {
        checkOutTopView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, CART_CHECKOUT_VIEW_HEIGHT)];
        
        CGRect frame = CGRectMake(CART_CHECKOUT_BUTTON_HORIZON_ALIGN_DISTANCE, PAYPAL_EXPRESS_PRODUCT_BTN_VERTICAL_ALIGN_DISTANCE, CART_CHECKOUT_BUTTON_WIDTH, CART_CHECKOUT_BUTTON_WIDTH * (CART_CHECKOUT_BUTTON_IMAGE_HEIGHT/CART_CHECKOUT_BUTTON_IMAGE_WIDTH));
        
        paypalButton = [[UIButton alloc]initWithFrame:frame];
        paypalButton.layer.masksToBounds = YES;
        paypalButton.tag = CHECK_OUT_WITH_PAYPAL_BUTTON_TAG;
        [paypalButton setBackgroundImage:[UIImage imageNamed:@"en_paypal_express_cart_btn"] forState:UIControlStateNormal];
        [paypalButton.layer setCornerRadius:5.0f];
        [paypalButton addTarget:self action:@selector(cartPaypalButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        frame = CGRectMake(SCREEN_WIDTH -CART_CHECKOUT_BUTTON_HORIZON_ALIGN_DISTANCE - frame.size.width, frame.origin.y, frame.size.width, frame.size.height);
        UIButton * checkoutButton = [[UIButton alloc]initWithFrame:frame];
        
        checkoutButton.layer.masksToBounds = YES;
        [checkoutButton setTitle:SCLocalizedString(@"Checkout") forState:UIControlStateNormal];
        [checkoutButton setBackgroundColor:THEME_COLOR];
        [checkoutButton.layer setCornerRadius:5.0f];
        checkoutButton.tag = CHECK_OUT_BUTTON_TAG;
        [checkoutButton addTarget:self action:@selector(startRegularCheckOut:) forControlEvents:UIControlEventTouchUpInside];
        UIView * background = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CART_CHECKOUT_VIEW_HEIGHT -1)];
        [background setBackgroundColor:[UIColor whiteColor]];
        [background setAlpha:0.9f];
        
        UIView * bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, CART_CHECKOUT_VIEW_HEIGHT - 1, SCREEN_WIDTH, 1)];
        [bottomLine setBackgroundColor:[UIColor lightGrayColor]];
        
        [checkOutTopView addSubview:background];
        [checkOutTopView addSubview:bottomLine];
        [checkOutTopView addSubview:checkoutButton];
        [checkOutTopView addSubview:paypalButton];
    }
    [checkOutTopView removeFromSuperview];
    [cartViewController.view addSubview:checkOutTopView];
    [cartViewController.view bringSubviewToFront:checkOutTopView];
    cartViewController.navigationItem.rightBarButtonItem = nil;
}

- (void)cartViewControllerPadViewDidLoad: (NSNotification *)noti
{
    cartViewControllerPad = (UIViewController *)noti.object;
    //[self removeObserverForNotification:noti];
}

- (void)orderControllerViewDidLoad: (NSNotification *)noti
{
    orderViewController = (SCOrderViewController *)noti.object;
    [self removeObserverForNotification:noti];
}

#pragma mark -
#pragma mark Actions

- (void)cartPaypalButtonClicked: (id)sender
{
    if (([[cartViewController.cart cartQty] isEqualToString:@"0"])&&(!isTheme01)&&([[SimiGlobalVar sharedInstance]themeUsing] != ThemeShowZTheme)) {
        UIAlertView * cartEmptyAlert = [[UIAlertView alloc]initWithTitle:@"" message:SCLocalizedString(@"You have no items in your shopping cart") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [cartEmptyAlert show];
        return;
    }
    checkOutFromProductView = NO;
    [self startPaypalCheckOut:cartViewController];
}

- (void)startRegularCheckOut: (id)sender
{
    if ([[cartViewController.cart cartQty] isEqualToString:@"0"]) {
        UIAlertView * cartEmptyAlert = [[UIAlertView alloc]initWithTitle:@"" message:SCLocalizedString(@"You have no items in your shopping cart") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [cartEmptyAlert show];
        return;
    }
    [cartViewController checkout];
}


- (void)startPaypalCheckOut: (UIViewController *)currentViewController
{
    if (paypalCheckoutView!=nil) {
        [paypalCheckoutView.navigationController popViewControllerAnimated:YES];
    }
    paypalCheckoutView = [[SCPaypalExpressWebViewController alloc]init];
    [currentViewController.navigationController pushViewController:paypalCheckoutView animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCompletePaypalWebCheckout:) name:@"DidCompletePaypalWebCheckout" object:nil];
    
    // theme01 ipad
    if (openNewPopOver) {
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        UIView * topView = window.rootViewController.view;
        if (paypalPopOver == nil) {
            paypalPopOver = nil;
        }
        paypalPopOverRootVC = [[SCCartViewController alloc]init];
        paypalPopOverRootVC.view.frame = CGRectMake(0, 0, CART_VIEW_WIDTH_PAD, CART_VIEW_HEIGHT_PAD);
        UINavigationController * navi = [[UINavigationController alloc]initWithRootViewController:paypalPopOverRootVC];
        paypalPopOver = [[UIPopoverController alloc] initWithContentViewController:navi];
        
        cartViewController = paypalPopOverRootVC;
        [paypalPopOver presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:topView permittedArrowDirections:0 animated:YES];
        [navi pushViewController:paypalCheckoutView animated:NO];
        paypalCheckoutView.navigationItem.hidesBackButton= YES;
    }
}

- (void)startPaypalCheckoutTheme01 :(UIViewController *)currenViewController
{
    UIViewController *currentViewC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        @try {
            startPaypalCheckOutRightAfterOpenCart = YES;
            cartViewControllerPad = [(UIViewController *)[NSClassFromString(@"SCCartViewControllerPad_Theme01") alloc]init];
            [(UINavigationController *)currentViewC pushViewController:cartViewControllerPad animated:YES];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    else {
        startPaypalCheckOutRightAfterOpenCart = YES;
        [(UINavigationController *)currentViewC pushViewController:cartViewController animated:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartViewControllerWillAppear_Theme01:) name:@"SCCartViewController_Theme01-ViewWillAppear" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartViewControllerWillAppear_Theme01:) name:@"ZThemeCartViewController-ViewWillAppear" object:nil];
        
        
        currenViewController = cartViewController;
    }
}

- (void)openReviewAddressViewController
{
    if (addressReviewVC!=nil) {
        [addressReviewVC.navigationController popViewControllerAnimated:NO];
    }
    
    addressReviewVC = [[SCPaypalExpressAddressReviewViewController alloc]init];
    
    addressReviewVC.billingAddress = [[SimiAddressModel alloc]init];
    addressReviewVC.shippingAddress = [[SimiAddressModel alloc]init];
    [self applyDataToExistingModel:addressReviewVC.billingAddress :[paypalModel objectForKey:@"billing_address"]];
    [self applyDataToExistingModel:addressReviewVC.shippingAddress :[paypalModel objectForKey:@"shipping_address"]];
    [cartViewController.navigationController pushViewController:addressReviewVC animated:YES];
}

- (void)applyDataToExistingModel: (SimiAddressModel *)target :(NSMutableDictionary *)source
{
    for (NSString * key in source) {
        [target setValue:[source objectForKey:key] forKey:key];
    }
}

- (void)checkOutWithPaypalExpFromProductView: (id)sender
{
    //theme01 ipad
    if (isTheme01 && (currentProductViewController_Pad!=nil)) {
        SEL method = NSSelectorFromString(@"addtoCart");
        SEL method2 = NSSelectorFromString(@"addToCart");
        
        @try {
            ((void (*)(id, SEL))[currentProductViewController_Pad methodForSelector:method2])(currentProductViewController_Pad, method2);
        }
        @catch (NSException *exception) {
            
        }
        @try {
            ((void (*)(id, SEL))[currentProductViewController_Pad methodForSelector:method])(currentProductViewController_Pad, method);
        }
        @catch (NSException *exception) {
            
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddProductToCart:) name:@"DidAddToCart" object:nil];
        return;
    }
    //ipad
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)&&(currentProductViewController_Pad!=nil)) {
        checkOutFromProductView = YES;
        [currentProductViewController_Pad addToCart:sender];
        currentProductViewController = (SCProductViewController *)currentProductViewController_Pad;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddProductToCart:) name:@"DidAddToCart" object:nil];
    }
    //iphone
    else if (currentProductViewController.isViewLoaded && currentProductViewController.view.window) {
        [currentProductViewController addToCart];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddProductToCart:) name:@"DidAddToCart" object:nil];
    }
    
}


#pragma mark ipad Actions

- (void)addIpadAlignmentEventCatcher
{
    //edit the size
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewControllerDidLoad:) name:@"SCPaypalExpressWebViewController-ViewDidLoad" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressReviewViewControllerDidLoad:) name:@"SCPaypalExpressAddressReviewViewController-ViewDidLoad" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shippingMethodsViewControllerDidLoad:) name:@"SCPaypalExpressShippingMethodViewController-ViewDidLoad" object:nil];
}

- (void)openCartView
{
    SimiCartPadWorker * a = [SimiCartPadWorker sharedInstance];
    [a.navigationBarWorker didSelectCartBarItem:nil];
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

//  Liam Update 150406
- (void)changeLocationPaypalButton:(NSNotification*)noti
{
    [[NSNotificationCenter defaultCenter] removeObserverForNotification:noti];
    CGRect frame = paypalButton.frame;
    frame.origin.y += 12;
    [paypalButton setFrame:frame];
}
//  End
@end
