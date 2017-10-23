//
//  PayUWorker.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/15/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "PayUWorker.h"
#import <SimiCartBundle/SCOrderViewController.h>
#import <SimiCartBundle/SCAppDelegate.h>

@implementation PayUWorker
{
    SimiOrderModel *order;
    SimiModel *payment;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotification:) name:DidPlaceOrderBefore object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:DidPlaceOrderBefore]) {
        order = noti.object;
        payment = [noti.userInfo valueForKey:@"payment"];
        if ([[[payment valueForKey:@"payment_method"] uppercaseString] isEqualToString:@"SIMIPAYU"] &&[order valueForKey:@"invoice_number"]) {
            PayUViewController *viewController = [[PayUViewController alloc] init];
            viewController.order = [[SimiOrderModel alloc]initWithDictionary:order];
            viewController.stringURL = [order valueForKey:@"url_action"];
            UINavigationController *currentVC = [SimiGlobalVar sharedInstance].currentlyNavigationController;
            UINavigationController *navi  = [[UINavigationController alloc]initWithRootViewController:viewController];
            [currentVC presentViewController:navi animated:YES completion:nil];
        }
    }
}

@end
