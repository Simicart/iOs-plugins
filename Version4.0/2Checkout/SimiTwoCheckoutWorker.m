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

#define SANDBOX_URL_2CHECKOUT @"https://sandbox.2checkout.com/checkout/purchase?"
#define LIVE_URL_2CHECKOUT @"https://2checkout.com/checkout/purchase?"

@implementation SimiTwoCheckoutWorker{
    SimiPaymentMethodModel *payment;
    NSString *payPalAppKey;
    NSString *payPalReceiverEmail;
    NSString *bnCode;
    SimiViewController *viewController;
    SimiOrderModel *order;
    SimiQuoteItemModel *cart;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceOrder:) name:SCOrderViewController_DidPlaceOrderSuccess object:nil];
    }
    return self;
}

- (void)didPlaceOrder:(NSNotification *)noti{
    payment = [noti.userInfo valueForKey:KEYEVENT.ORDERVIEWCONTROLLER.selected_payment];
    if ([payment.code isEqualToString:@"TWOUT"]) {
        UINavigationController *currentVC = [SimiGlobalVar sharedInstance].currentlyNavigationController;
        order = noti.object;
        NSString *invoiceNumber = order.invoiceNumber;
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
                nextController.order = order;
                url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [nextController setUrlPath:url];
                nextController.urlCallBack = [payment valueForKey:@"url_back"];
                nextController.invoiceNumber = invoiceNumber;
                nextController.title = SCLocalizedString(@"2Checkout");
                UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:nextController];
                [currentVC presentViewController:navi animated:NO completion:nil];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:[NSString stringWithFormat:SCLocalizedString(@"Sorry, %@ is not now available. Please try again later"),SCLocalizedString(@"2Checkout")] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            }
        }
        @catch (NSException *exception) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:[NSString stringWithFormat:SCLocalizedString(@"Sorry, %@ is not now available. Please try again later"),SCLocalizedString(@"2Checkout")] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
        @finally {
            
        }
    }
}
@end
