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
        }
    }
}

- (void)didPlaceOrder:(NSNotification *)noti
{
    UINavigationController *currentVC = [SimiGlobalVar sharedInstance].currentlyNavigationController;
    order = [noti.userInfo valueForKey:@"data"];
    cart = [noti.userInfo valueForKey:@"cart"];
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
            UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:nextController];
            [currentVC presentViewController:navi animated:NO completion:nil];
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
@end
