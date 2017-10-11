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
#define ALERT_VIEW_ERROR 0

@implementation SimiAvenueWorker{
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceOrderBefore:) name:@"DidPlaceOrder-Before" object:nil];
    }
    return self;
}

- (void)didPlaceOrderBefore:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"DidPlaceOrder-Before"]){
        payment = [noti.userInfo valueForKey:@"payment"];
        if ([[payment valueForKey:@"payment_method"] isEqualToString:METHOD_AVENUE]) {
            [self didPlaceOrder:noti];
        }
    }
}

- (void)didPlaceOrder:(NSNotification *)noti
{
    UINavigationController *currentVC = [SimiGlobalVar sharedInstance].currentlyNavigationController;
    order = [noti.userInfo valueForKey:@"data"];
    cart = [noti.userInfo valueForKey:@"cart"];
    @try {
        if([order valueForKey:@"invoice_number"] && [order valueForKey:@"url_action"]){
            NSString *url = [order valueForKey:@"url_action"];
            SimiAvenueWebView *nextController = [[SimiAvenueWebView alloc] init];
            nextController.order = [[SimiOrderModel alloc]initWithDictionary:order];
            url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [nextController setUrlPath:url];
            nextController.title =  SCLocalizedString(@"CCAvenue");
            nextController.webTitle = SCLocalizedString(@"CCAvenue");
            UINavigationController *navi  = [[UINavigationController alloc]initWithRootViewController:nextController];
            [currentVC presentViewController:navi animated:YES completion:nil];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:[NSString stringWithFormat:SCLocalizedString(@"Sorry, %@ is not now available. Please try again later"),SCLocalizedString(@"CCAvenue")] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alertView.tag = ALERT_VIEW_ERROR;
            [alertView show];
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:[NSString stringWithFormat:SCLocalizedString(@"Sorry, %@ is not now available. Please try again later"),SCLocalizedString(@"CCAvenue")] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alertView.tag = ALERT_VIEW_ERROR;
        [alertView show];
    }
    @finally {
        
    }
}

@end
