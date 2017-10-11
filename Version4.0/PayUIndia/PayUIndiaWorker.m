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
@implementation PayUIndiaWorker{
    SimiOrderModel *order;
    SimiPaymentMethodModel *payment;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didPlaceOrder:) name:SCOrderViewController_DidPlaceOrderSuccess object:nil];
    }
    return self;
}

- (void)didPlaceOrder:(NSNotification *)noti{
    order = noti.object;
    payment = [noti.userInfo valueForKey:KEYEVENT.ORDERVIEWCONTROLLER.selected_payment];
    if ([[payment.code uppercaseString] isEqualToString:@"SIMIPAYUINDIA"] && order.invoiceNumber) {
        PayUIndiaViewController *viewController = [[PayUIndiaViewController alloc] init];
        viewController.order = order;
        UINavigationController *currentVC = [SimiGlobalVar sharedInstance].currentlyNavigationController;
        UINavigationController *navi  = [[UINavigationController alloc]initWithRootViewController:viewController];
        [currentVC presentViewController:navi animated:YES completion:nil];
    }
}
@end
