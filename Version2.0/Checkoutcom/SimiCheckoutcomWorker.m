//
//  SimiCheckoutcomWorker.m
//  SimiCartPluginFW
//
//  Created by biga on 11/6/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SCAppDelegate.h>
#import "SimiCheckoutcomWorker.h"
#import "SimiOrderModel+Checkoutcom.h"

#define METHOD_SIMICHECKOUTCOM @"SIMICHECKOUTCOM"
//#define URL_CHECKOUTCOM @"https://secure.checkout.com/ipayment/default/iframePay.aspx?"
#define URL_CHECKOUTCOM @"https://secure.checkout.com/hpayment-tokenretry/pay.aspx?"
#define ALERT_VIEW_ERROR 0

@implementation SimiCheckoutcomWorker{
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
        if ([[payment valueForKey:@"payment_method"] isEqualToString:METHOD_SIMICHECKOUTCOM]) {
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
    NSString *invoiceNumber = [order valueForKey:@"invoice_number"];
    NSString *params = [order valueForKey:@"params"];
    @try {
//        NSLog(@"%@", payment);
        if([order valueForKey:@"invoice_number"]){
            NSString *url = URL_CHECKOUTCOM;
            url = [url stringByAppendingString:params];
            SimiCheckoutcomWebView *nextController = [[SimiCheckoutcomWebView alloc] init];
            url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [nextController setUrlPath:url];
            nextController.urlCallBack = [payment valueForKey:@"url_back"];
            nextController.invoiceNumber = invoiceNumber;
            nextController.title = [self formatTitleString:(SCLocalizedString(@"Checkout.com"))];
            [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, Checkout.com is not now available. Please try again later.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alertView.tag = ALERT_VIEW_ERROR;
            [alertView show];
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, Checkout.com is not now available. Please try again later.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
            SimiCheckoutcomWebView *nextController = [[SimiCheckoutcomWebView alloc] init];
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
