//
//  SCPaypalExpressCoreWorker.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/17/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SCPaypalExpressCoreWorker.h"
#import <SimiCartBundle/SCCartViewControllerPad.h>
#import <SimiCartBundle/SCProductSecondDesignViewController.h>

static NSString *product_paypalcheckout_row = @"product_paypalcheckout_row";
@implementation SCPaypalExpressCoreWorker
{
    NSDictionary *paypalExpressConfig;
}
@synthesize btnPaypalCart, btnPaypalProduct, btnPaypalProductNew;
@synthesize productViewController, productActionView, productActionViewFrame;
@synthesize webViewController;

- (id)init{
    self = [super init];
    if (self) {
        //add button to product view controller
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sCProductViewControllerViewWillAppear:) name:@"SCProductViewControllerViewWillAppear" object:nil];
        
        //add button to cart
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeCart:) name:@"DidChangeCart" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeCart:) name:@"SCCartViewControllerViewDidAppearBeforeComplete" object:nil];
        
        //open webview after placed Order
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceOrderBefore:) name:@"DidPlaceOrder-Before" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initProductCellsAfter:) name:@"InitProductCells-After" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedProductCellAfter:) name:@"InitializedProductCell-After" object:nil];
        
        paypalExpressConfig = [[SimiGlobalVar sharedInstance].allConfig valueForKey:@"paypal_express_config"];
    }
    return self;
}
#pragma mark -
#pragma mark Add Button to Product View Controller
-(void)sCProductViewControllerViewWillAppear: (NSNotification *)noti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProductWithProductId:) name:@"DidGetProductWithID" object:nil];
    productViewController = (SCProductViewController *)noti.object;
    productActionView = productViewController.viewAction;
    if (CGRectEqualToRect(productActionViewFrame,CGRectZero)) {
        productActionViewFrame = productActionView.frame;
    }
}

-(void)didGetProductWithProductId: (NSNotification *)noti
{
    [self removeObserverForNotification:noti];
    if ([[paypalExpressConfig valueForKey:@"show_on_product_detail"]boolValue]) {
        if (btnPaypalProduct == nil) {
            CGFloat buttonWidth = [SimiGlobalVar scaleValue:310];
            CGFloat buttonHeight = 40;
            CGFloat leftPadding = [SimiGlobalVar scaleValue:5];
            CGFloat topPadding = [SimiGlobalVar scaleValue:10];
            CGFloat cornerRadius = 4.0f;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                leftPadding = 300;
                topPadding =15;
                buttonWidth = 424;
            }
            
            btnPaypalProduct = [[UIButton alloc]initWithFrame:CGRectMake(leftPadding,buttonHeight + topPadding,buttonWidth,buttonHeight)];
            [btnPaypalProduct.layer setCornerRadius:cornerRadius];
            [btnPaypalProduct setBackgroundColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#ffc439"]];
            [btnPaypalProduct setContentEdgeInsets:UIEdgeInsetsMake(0, buttonWidth/2 -75, 0, buttonWidth/2 -75)];
            [btnPaypalProduct addTarget:self action:@selector(didClickProductPaypalButton:) forControlEvents:UIControlEventTouchUpInside];
            [btnPaypalProduct setImage:[UIImage imageNamed:@"en_paypal_express_product_btn"] forState:UIControlStateNormal];
        }
        [btnPaypalProduct removeFromSuperview];
        [productActionView setFrame:productActionViewFrame];
        
        //Change the ActionView Frame
        [productActionView addSubview:btnPaypalProduct];
        CGRect newActionViewFrame = productActionViewFrame;
        newActionViewFrame.origin.y -= btnPaypalProduct.frame.origin.y;
        newActionViewFrame.size.height += btnPaypalProduct.frame.origin.y;
        [productActionView setFrame:newActionViewFrame];
    }
}

#pragma mark Product Second Design
- (void)initProductCellsAfter:(NSNotification*)noti
{
    if ([[paypalExpressConfig valueForKey:@"show_on_product_detail"]boolValue]) {
        SimiTable *cells = noti.object;
        SimiSection *mainSection = [cells getSectionByIdentifier:product_main_section];
        SimiRow *beforeRow = [mainSection getRowByIdentifier:product_option_row];
        if (beforeRow == nil) {
            beforeRow = [mainSection getRowByIdentifier:product_nameandprice_row];
        }
        [mainSection addRowWithIdentifier:product_paypalcheckout_row height:50 sortOrder:beforeRow.sortOrder + 10];
        [mainSection sortItems];
    }
}

- (void)initializedProductCellAfter:(NSNotification*)noti
{
    SimiRow *row = [noti.userInfo valueForKey:@"row"];
    if ([row.identifier isEqualToString:product_paypalcheckout_row]) {
        UITableViewCell *cell = [noti.userInfo valueForKey:@"cell"];
        if ([[paypalExpressConfig valueForKey:@"show_on_product_detail"]boolValue]) {
            if (btnPaypalProductNew == nil) {
                CGFloat buttonWidth = [SimiGlobalVar scaleValue:290];
                if (PADDEVICE)
                    buttonWidth = [SimiGlobalVar scaleValue:480];
                CGFloat buttonHeight = 40;
                CGFloat leftPadding = [SimiGlobalVar scaleValue:15];
                CGFloat topPadding = 5;
                CGFloat cornerRadius = 4.0f;
                
                btnPaypalProductNew = [[UIButton alloc]initWithFrame:CGRectMake(leftPadding, topPadding, buttonWidth,buttonHeight)];
                [btnPaypalProductNew.layer setCornerRadius:cornerRadius];
                [btnPaypalProductNew setBackgroundColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#ffc439"]];
                [btnPaypalProductNew setContentEdgeInsets:UIEdgeInsetsMake(0, buttonWidth/2 -75, 0, buttonWidth/2 -75)];
                [btnPaypalProductNew addTarget:self action:@selector(didClickProductPaypalButton:) forControlEvents:UIControlEventTouchUpInside];
                [btnPaypalProductNew setImage:[UIImage imageNamed:@"en_paypal_express_product_btn"] forState:UIControlStateNormal];
            }
            [btnPaypalProductNew removeFromSuperview];
            [cell addSubview:btnPaypalProductNew];
        }
    }
}

#pragma mark Add Button to Cart View Controller
-(void)didChangeCart: (NSNotification *)noti
{
    if (PHONEDEVICE) {
        SCCartViewController * cartVC = [[SCThemeWorker sharedInstance].navigationBarPhone cartViewController];
        if ((cartVC.cart == nil) || (cartVC.cart.count == 0)|| ![[paypalExpressConfig valueForKey:@"show_on_cart"]boolValue]) {
            btnPaypalCart.hidden = YES;
            return;
        }
        
        if (btnPaypalCart == nil && cartVC.btnCheckout != nil) {
            CGFloat padding = [SimiGlobalVar scaleValue:5];
            CGFloat buttonHeight = [SimiGlobalVar scaleValue:40];
            CGFloat buttonWidth = [SimiGlobalVar scaleValue:150];
            CGFloat buttonY = cartVC.btnCheckout.frame.origin.y;
            CGFloat buttonDistance = [SimiGlobalVar scaleValue:10];
            btnPaypalCart = [[UIButton alloc]initWithFrame:CGRectMake(padding, buttonY, buttonWidth, buttonHeight)];
            [btnPaypalCart setBackgroundImage:[UIImage imageNamed:@"en_paypal_express_cart_btn"] forState:UIControlStateNormal];
            [btnPaypalCart addTarget:self action:@selector(startPaypalCheckout) forControlEvents:UIControlEventTouchUpInside];
            btnPaypalCart.hidden = NO;
            cartVC.btnCheckout.layer.shadowOpacity = 0;
            
            [cartVC.btnCheckout setFrame:CGRectMake(padding + buttonWidth +buttonDistance, buttonY, buttonWidth, buttonHeight)];
            [cartVC.view addSubview:btnPaypalCart];
        }
    }
    else {
        SCCartViewController * cartVC = [[SCThemeWorker sharedInstance].navigationBarPad cartViewControllerPad];
        if ((cartVC.cart == nil) || (cartVC.cart.count == 0) || ![[paypalExpressConfig valueForKey:@"show_on_cart"]boolValue]){
            btnPaypalCart.hidden = YES;
            return;
        }
        if (btnPaypalCart == nil) {
            btnPaypalCart = [[UIButton alloc]initWithFrame:CGRectMake(20, 30, 180, 50)];
            [btnPaypalCart setBackgroundImage:[UIImage imageNamed:@"en_paypal_express_product_pad"] forState:UIControlStateNormal];
            btnPaypalCart.layer.masksToBounds = NO;
            btnPaypalCart.layer.shadowColor = [[SimiGlobalVar sharedInstance] darkerColorForColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#ffc439"]].CGColor;
            btnPaypalCart.layer.shadowOpacity = 0.7;
            btnPaypalCart.layer.shadowRadius = -1;
            btnPaypalCart.layer.shadowOffset = CGSizeMake(-0, 5);
            
            [btnPaypalCart addTarget:self action:@selector(startPaypalCheckout) forControlEvents:UIControlEventTouchUpInside];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedCartCellAfter:) name:@"InitializedCartCell-After" object:nil];
        }
    }
    btnPaypalCart.hidden = NO;
}

-(void)initializedCartCellAfter:(NSNotification *)noti
{
    SimiRow *row = [noti.userInfo objectForKey:@"row"];
    if (row.identifier == CART_CHECKOUT_ROW) {
        UITableViewCell *cell = [noti.userInfo objectForKey:@"cell"];
        [cell addSubview:btnPaypalCart];
        SCCartViewController * cartVC = [[SCThemeWorker sharedInstance].navigationBarPad cartViewControllerPad];
        [cartVC.btnCheckout setFrame:CGRectMake(220, 30, 180, 50)];
        [self removeObserverForNotification:noti];
    }
}

#pragma mark Open Webview After placed Order
//while paypal checkout runs like normall offline payments
- (void)didPlaceOrderBefore:(NSNotification *)noti
{
    SimiModel *payment = [noti.userInfo valueForKey:@"payment"];
    if ([[payment valueForKey:@"payment_method"] isEqualToString:@"PAYPALUK_EXPRESS"]) {
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            [self startPaypalCheckout];
        }
    }
}

#pragma mark Paypal Checkout Actions
-(void)didClickProductPaypalButton:(id)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddToCart:) name:@"DidAddToCart" object:nil];
    [productViewController addToCart];
}

-(void)didAddToCart:(NSNotification *)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [self startPaypalCheckout];
    }
    [self removeObserverForNotification:noti];
}


-(void)startPaypalCheckout
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    webViewController = [SCPaypalExpressWebViewController new];
    [(UINavigationController *)currentVC pushViewController:webViewController animated:YES];
}


#pragma mark -
#pragma mark dealloc

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
