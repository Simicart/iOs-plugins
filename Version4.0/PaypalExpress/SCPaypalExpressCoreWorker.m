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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeCart:) name:SCCartController_DidChangeCart object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeCart:) name:@"SCCartViewControllerViewDidAppear" object:nil];
        
        //open webview after placed Order
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceOrder:) name:SCOrderViewController_DidPlaceOrderSuccess object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initProductCellsAfter:) name:[NSString stringWithFormat:@"%@%@",SCProductSecondDesignViewController_RootEventName,SimiTableViewController_SubKey_InitCells_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedProductCellAfter:) name:[NSString stringWithFormat:@"%@%@",SCProductSecondDesignViewController_RootEventName,SimiTableViewController_SubKey_InitializedCell_End] object:nil];
        
        paypalExpressConfig = [[SimiGlobalVar sharedInstance].storeView.modelData valueForKey:@"paypal_express_config"];
    }
    return self;
}
#pragma mark -
#pragma mark Add Button to Product View Controller
- (void)sCProductViewControllerViewWillAppear:(NSNotification *)noti{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProductWithProductId:) name:Simi_DidGetProductModel object:nil];
    productViewController = (SCProductViewController *)noti.object;
    productActionView = productViewController.viewAction;
    if (CGRectEqualToRect(productActionViewFrame,CGRectZero)) {
        productActionViewFrame = productActionView.frame;
    }
}

- (void)didGetProductWithProductId:(NSNotification *)noti{
    [self removeObserverForNotification:noti];
    if ([[paypalExpressConfig valueForKey:@"show_on_product_detail"]boolValue]) {
        if (btnPaypalProduct == nil) {
            CGFloat buttonWidth = SCALEVALUE(310);
            CGFloat buttonHeight = 40;
            CGFloat leftPadding = SCALEVALUE(5);
            CGFloat topPadding = SCALEVALUE(10);
            CGFloat cornerRadius = 4.0f;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                leftPadding = 300;
                topPadding =15;
                buttonWidth = 424;
            }
            
            btnPaypalProduct = [[UIButton alloc]initWithFrame:CGRectMake(leftPadding,buttonHeight + topPadding,buttonWidth,buttonHeight)];
            [btnPaypalProduct.layer setCornerRadius:cornerRadius];
            [btnPaypalProduct setBackgroundColor:COLOR_WITH_HEX(@"#ffc439")];
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
- (void)initProductCellsAfter:(NSNotification*)noti{
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

- (void)initializedProductCellAfter:(NSNotification*)noti{
    SimiTable *cells = noti.object;
    NSIndexPath *indexPath = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if ([row.identifier isEqualToString:product_paypalcheckout_row]) {
        UITableViewCell *cell = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.cell];
        if ([[paypalExpressConfig valueForKey:@"show_on_product_detail"]boolValue]) {
            if (btnPaypalProductNew == nil) {
                CGFloat buttonWidth = SCALEVALUE(290);
                if (PADDEVICE)
                    buttonWidth = SCALEVALUE(480);
                CGFloat buttonHeight = 40;
                CGFloat leftPadding = SCALEVALUE(15);
                CGFloat topPadding = 5;
                CGFloat cornerRadius = 4.0f;
                
                btnPaypalProductNew = [[UIButton alloc]initWithFrame:CGRectMake(leftPadding, topPadding, buttonWidth,buttonHeight)];
                [btnPaypalProductNew.layer setCornerRadius:cornerRadius];
                [btnPaypalProductNew setBackgroundColor:COLOR_WITH_HEX(@"#ffc439")];
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
- (void)didChangeCart:(NSNotification *)noti{
    SCCartViewController *cartVC = nil;
    if ([noti.userInfo valueForKey:KEYEVENT.CARTVIEWCONTROLLER.viewcontroller]) {
        cartVC = [noti.userInfo valueForKey:KEYEVENT.CARTVIEWCONTROLLER.viewcontroller];
    }else if([noti.object isKindOfClass:[SCCartViewController class]]){
        cartVC = noti.object;
    }
    if (PHONEDEVICE) {
        if ((cartVC.cart == nil) || (cartVC.cart.count == 0)|| ![[paypalExpressConfig valueForKey:@"show_on_cart"]boolValue]) {
            btnPaypalCart.hidden = YES;
            return;
        }
        
        if (btnPaypalCart == nil && cartVC.btnCheckout != nil) {
            CGFloat padding = SCALEVALUE(5);
            CGFloat buttonHeight = SCALEVALUE(40);
            CGFloat buttonWidth = SCALEVALUE(150);
            CGFloat buttonY = cartVC.btnCheckout.frame.origin.y;
            CGFloat buttonDistance = SCALEVALUE(10);
            btnPaypalCart = [[UIButton alloc]initWithFrame:CGRectMake(padding, buttonY, buttonWidth, buttonHeight)];
            [btnPaypalCart setBackgroundImage:[UIImage imageNamed:@"en_paypal_express_cart_btn"] forState:UIControlStateNormal];
            [btnPaypalCart addTarget:self action:@selector(startPaypalCheckout) forControlEvents:UIControlEventTouchUpInside];
            btnPaypalCart.hidden = NO;
            cartVC.btnCheckout.layer.shadowOpacity = 0;
            
            [cartVC.btnCheckout setFrame:CGRectMake(padding + buttonWidth +buttonDistance, buttonY, buttonWidth, buttonHeight)];
            [cartVC.view addSubview:btnPaypalCart];
        }
    }else {
        if ((cartVC.cart == nil) || (cartVC.cart.count == 0) || ![[paypalExpressConfig valueForKey:@"show_on_cart"]boolValue]){
            btnPaypalCart.hidden = YES;
            return;
        }
        if (btnPaypalCart == nil) {
            btnPaypalCart = [[UIButton alloc]initWithFrame:CGRectMake(20, 30, 180, 50)];
            [btnPaypalCart setBackgroundImage:[UIImage imageNamed:@"en_paypal_express_product_pad"] forState:UIControlStateNormal];
            btnPaypalCart.layer.masksToBounds = NO;
            btnPaypalCart.layer.shadowColor = [SimiGlobalFunction darkerColorForColor:COLOR_WITH_HEX(@"#ffc439")].CGColor;
            btnPaypalCart.layer.shadowOpacity = 0.7;
            btnPaypalCart.layer.shadowRadius = -1;
            btnPaypalCart.layer.shadowOffset = CGSizeMake(-0, 5);
            
            [btnPaypalCart addTarget:self action:@selector(startPaypalCheckout) forControlEvents:UIControlEventTouchUpInside];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedCartCellAfter:) name:[NSString stringWithFormat:@"%@%@",SCCartViewController_RootEventName,SimiTableViewController_SubKey_InitializedCell_End] object:nil];
        }
    }
    btnPaypalCart.hidden = NO;
}

- (void)initializedCartCellAfter:(NSNotification *)noti{
    SimiTable *cells = noti.object;
    NSIndexPath *indexPath = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if (row.identifier == CART_CHECKOUT_ROW) {
        UITableViewCell *cell = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.cell];
        [cell addSubview:btnPaypalCart];
        SCCartViewController * cartVC = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
        [cartVC.btnCheckout setFrame:CGRectMake(220, 30, 180, 50)];
    }
}

#pragma mark Open Webview After placed Order
//while paypal checkout runs like normall offline payments
- (void)didPlaceOrder:(NSNotification *)noti{
    SimiPaymentMethodModel *payment = [noti.userInfo valueForKey:KEYEVENT.ORDERVIEWCONTROLLER.selected_payment];
    if ([payment.code isEqualToString:@"PAYPAL_EXPRESS"]) {
        SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
        if (responder.status == SUCCESS) {
            [self startPaypalCheckout];
        }
    }
}

#pragma mark Paypal Checkout Actions
- (void)didClickProductPaypalButton:(id)sender{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddToCart:) name:Simi_DidAddToCart object:nil];
    [productViewController addToCart];
}

- (void)didAddToCart:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        [self startPaypalCheckout];
    }
    [self removeObserverForNotification:noti];
}


- (void)startPaypalCheckout{
    UINavigationController *currentVC = kNavigationController;
    webViewController = [SCPaypalExpressWebViewController new];
    [currentVC pushViewController:webViewController animated:YES];
}


#pragma mark -
#pragma mark dealloc

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
