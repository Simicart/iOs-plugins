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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder-Before" object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"DidPlaceOrder-Before"]){
        payment = [noti.userInfo valueForKey:@"payment"];
        if ([[payment valueForKey:@"payment_method"] isEqualToString:METHOD_IPAY]) {
            [self didPlaceOrder:noti];
//            [self removeObserverForNotification:noti];
        }
    }
}

- (void)didPlaceOrder:(NSNotification *)noti
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    order = [noti.userInfo valueForKey:@"data"];
//    NSLog(@"%@", order);
    @try {
        if([order valueForKey:@"invoice_number"]){
            SimiIpayViewController *nextController = [[SimiIpayViewController alloc] init];
            nextController.title =  SCLocalizedString(@"Ipay88");
            nextController.order = order;
            nextController.payment = payment;
            [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, Ipay88 is not now available. Please try again later.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alertView.tag = ALERT_VIEW_ERROR;
            [alertView show];
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, Ipay88 is not now available. Please try again later.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alertView.tag = ALERT_VIEW_ERROR;
        [alertView show];
    }
    @finally {
        
    }
}

@end
