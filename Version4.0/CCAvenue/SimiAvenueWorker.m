//
//  SimiAvenueWorker.m
//  SimiCartPluginFW
//
//  Created by biga on 11/6/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SCAppDelegate.h>
#import "SimiAvenueWorker.h"
#import "SimiOrderModel+Avenue.h"

#define METHOD_AVENUE @"SIMIAVENUE"

@implementation SimiAvenueWorker{
    SimiPaymentMethodModel *payment;
    NSString *payPalAppKey;
    NSString *payPalReceiverEmail;
    NSString *bnCode;
    SimiViewController *viewController;
    SimiOrderModel *order;
}

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceOrder:) name:SCOrderViewController_DidPlaceOrderSuccess object:nil];
    }
    return self;
}

- (void)didPlaceOrder:(NSNotification *)noti{
        payment = [noti.userInfo valueForKey:KEYEVENT.ORDERVIEWCONTROLLER.selected_payment];
        if ([payment.code isEqualToString:METHOD_AVENUE]) {
            UINavigationController *currentVC = [SimiGlobalVar sharedInstance].currentlyNavigationController;
            order = noti.object;
            @try {
                if(order.invoiceNumber && order.urlAction){
                    NSString *url = order.urlAction;
                    SimiAvenueWebView *nextController = [[SimiAvenueWebView alloc] init];
                    nextController.order = order;
                    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    [nextController setUrlPath:url];
                    nextController.title =  SCLocalizedString(@"CCAvenue");
                    nextController.webTitle = SCLocalizedString(@"CCAvenue");
                    UINavigationController *navi  = [[UINavigationController alloc]initWithRootViewController:nextController];
                    [currentVC presentViewController:navi animated:YES completion:nil];
                }else{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:[NSString stringWithFormat:SCLocalizedString(@"Sorry, %@ is not now available. Please try again later"),SCLocalizedString(@"CCAvenue")] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alertView show];
                }
            }
            @catch (NSException *exception) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:[NSString stringWithFormat:SCLocalizedString(@"Sorry, %@ is not now available. Please try again later"),SCLocalizedString(@"CCAvenue")] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            }
            @finally {
                
            }
        }
}
@end
