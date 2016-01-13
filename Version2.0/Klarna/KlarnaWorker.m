//
//  KlarnaWorker.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SCOrderViewController.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import "KlarnaWorker.h"
@implementation KlarnaWorker
{
    SCOrderViewController *orderViewController;
    SimiOrderModel *order;
    SimiModel *payment;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotification:) name:@"SCOrderViewController-BeforePlaceOrder" object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"SCOrderViewController-BeforePlaceOrder"]) {
        orderViewController = noti.object;
        order = [noti.userInfo valueForKey:@"order"];
        payment = [noti.userInfo valueForKey:@"payment"];
        if ([[payment valueForKey:@"payment_method"] isEqualToString:@"SIMIKLARNA"]) {
            orderViewController.isDiscontinue = YES;
            KlarnaViewController *viewController = [[KlarnaViewController alloc] init];
            [orderViewController.navigationController pushViewController:viewController animated:YES];
            viewController.navigationItem.title = @"Klarna";
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
