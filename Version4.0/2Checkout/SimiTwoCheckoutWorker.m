//
//  Simi2CheckoutWorker.m
//  SimiCartPluginFW
//
//  Created by biga on 11/6/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SCAppDelegate.h>
#import "SimiTwoCheckoutWorker.h"
#import "SimiOrderModel+TwoCheckout.h"

#define CHECKOUT_CREDIT @"2Checkout Credit"
#define CHECOUT_PAYPAL @"2Checkout Paypal"
#define METHOD_2CHECKOUT @"TWOUT"
#define SANDBOX_URL_2CHECKOUT @"https://sandbox.2checkout.com/checkout/purchase?"
#define LIVE_URL_2CHECKOUT @"https://2checkout.com/checkout/purchase?"
#define ALERT_VIEW_ERROR 0

@implementation SimiTwoCheckoutWorker{
    SimiModel *payment;
    NSString *payPalAppKey;
    NSString *payPalReceiverEmail;
    NSString *bnCode;
    SimiViewController *viewController;
    SimiOrderModel *order;
    SimiCartModel *cart;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder-Before" object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"DidPlaceOrder-Before"]){
        payment = [noti.userInfo valueForKey:@"payment"];
        if ([[payment valueForKey:@"payment_method"] isEqualToString:METHOD_2CHECKOUT]) {
            [self didPlaceOrder:noti];
//            [self removeObserverForNotification:noti];
        }
    }
}

- (void)didPlaceOrder:(NSNotification *)noti
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    order = [noti.userInfo valueForKey:@"data"];
    cart = [noti.userInfo valueForKey:@"cart"];
//     NSLog(@"%@", order);
    NSString *invoiceNumber = [order valueForKey:@"invoice_number"];
    NSString *params = [order valueForKey:@"params"];
    BOOL isSandbox = [[payment valueForKey:@"is_sandbox"] boolValue];
    @try {
        if([order valueForKey:@"invoice_number"]){
            NSString *url = LIVE_URL_2CHECKOUT;
            if(isSandbox){
                url = SANDBOX_URL_2CHECKOUT;
            }
            url = [url stringByAppendingString:params];
            SimiTwoCheckoutWebView *nextController = [[SimiTwoCheckoutWebView alloc] init];
            url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [nextController setUrlPath:url];
            nextController.urlCallBack = [payment valueForKey:@"url_back"];
            nextController.invoiceNumber = invoiceNumber;
            nextController.title = [self formatTitleString:(SCLocalizedString(@"2Checkout"))];
            [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, 2Checkout is not now available. Please try again later.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alertView.tag = ALERT_VIEW_ERROR;
            [alertView show];
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, 2Checkout is not now available. Please try again later.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alertView.tag = ALERT_VIEW_ERROR;
        [alertView show];
    }
    @finally {
        
    }
}

- (void)test
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    @try {
        if(1==1){
            NSString *url = @"https://sandbox.2checkout.com/checkout/purchase?sid=901257657&purchase_step=payment-method&merchant_order_id=100000979&email=sarah@g.com&first_name=Hxhhz&last_name=Hxhhz&phone=555&country=CM&street_address=938484&street_address2=&city=Bdbbx&state=XX&zip=Hbdbx&ship_name=Hxhhz Hxhhz&ship_country=KH&ship_street_address=Hdhd&ship_street_address2=&ship_city=Bdbbx&ship_state=Armed Forces Europe&ship_zip=Hbdbx&sh_cost=0&sh_weight=1&ship_method=Free Shipping - Free&2co_tax=0&2co_cart_type=magento&currency_code=USD&mode=2CO&li_0_type=product&li_0_product_id=226bw&li_0_quantity=1&li_0_name=22 Syncmaster LCD Monitor&li_0_description=&li_0_price=399.99&li_1_type=shipping&li_1_name=Free Shipping - Free&li_1_price=0";
            SimiTwoCheckoutWebView *nextController = [[SimiTwoCheckoutWebView alloc] init];
            url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [nextController setUrlPath:url];
            nextController.invoiceNumber = @"10002034";
            nextController.title = @"2Checkout";
            [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, PayPal is not now available. Please try again later.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alertView.tag = ALERT_VIEW_ERROR;
            [alertView show];
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, PayPal is not now available. Please try again later.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alertView.tag = ALERT_VIEW_ERROR;
        [alertView show];
    }
    @finally {
        
    }
}
@end
