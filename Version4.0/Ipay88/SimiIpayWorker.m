//
//  SimiIpayWorker.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/27/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiIpayWorker.h"
#import "SimiOrderModel+Ipay.h"
#import "SimiIpayViewController.h"
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SCOrderViewController.h>

#define METHOD_IPAY @"SIMIIPAY88"
#define ALERT_VIEW_ERROR 0

@implementation SimiIpayWorker{
    SimiModel *payment;
    NSString *payPalAppKey;
    NSString *payPalReceiverEmail;
    NSString *bnCode;
    SimiViewController *viewController;
    SimiOrderModel *order;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceOrderAfter:) name:DidPlaceOrderAfter object:nil];
    }
    return self;
}

- (void)didPlaceOrderAfter:(NSNotification *)noti
{
    if ([noti.name isEqualToString:DidPlaceOrderAfter]){
        payment = [noti.userInfo valueForKey:@"payment"];
        if ([[payment valueForKey:@"payment_method"] isEqualToString:METHOD_IPAY]) {
            [self didPlaceOrder:noti];
        }
    }
}

- (void)didPlaceOrder:(NSNotification *)noti
{
    UINavigationController *currentVC = [SimiGlobalVar sharedInstance].currentlyNavigationController;
    order = [noti.userInfo valueForKey:@"data"];
    @try {
        if([order valueForKey:@"invoice_number"]){
            SimiIpayViewController *nextController = [[SimiIpayViewController alloc] init];
            nextController.order = order;
            nextController.payment = payment;
            UINavigationController *navi  = [[UINavigationController alloc]initWithRootViewController:nextController];
            [currentVC presentViewController:navi animated:YES completion:nil];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:[NSString stringWithFormat:SCLocalizedString(@"Sorry, %@ is not now available. Please try again later"),SCLocalizedString(@"Ipay88")] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alertView.tag = ALERT_VIEW_ERROR;
            [alertView show];
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:[NSString stringWithFormat:SCLocalizedString(@"Sorry, %@ is not now available. Please try again later"),SCLocalizedString(@"Ipay88")] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alertView.tag = ALERT_VIEW_ERROR;
        [alertView show];
    }
    @finally {
        
    }
}

@end
