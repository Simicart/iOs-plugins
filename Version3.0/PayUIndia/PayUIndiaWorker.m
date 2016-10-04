//
//  PayUIndiaWorker.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/17/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "PayUIndiaWorker.h"
#import <SimiCartBundle/SCOrderViewController.h>
#import <SimiCartBundle/SCAppDelegate.h>
@implementation PayUIndiaWorker
{
    SimiOrderModel *order;
    SimiModel *payment;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder-Before" object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"DidPlaceOrder-Before"]) {
        order = noti.object;
        payment = [noti.userInfo valueForKey:@"payment"];
        if ([[[payment valueForKey:@"payment_method"] uppercaseString] isEqualToString:@"SIMIPAYUINDIA"] &&[order valueForKey:@"invoice_number"]) {
            PayUIndiaViewController *viewController = [[PayUIndiaViewController alloc] init];
            viewController.stringURL = [order valueForKey:@"url_action"];
            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
            [(UINavigationController *)currentVC pushViewController:viewController animated:YES];
            viewController.navigationItem.title = @"PayU";
        }
    }
}
@end