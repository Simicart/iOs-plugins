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
@implementation PayUWorker{
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
    if ([[payment.code uppercaseString] isEqualToString:@"SIMIPAYU"] && order.invoiceNumber) {
        PayUViewController *viewController = [[PayUViewController alloc] init];
        viewController.order = order;
        viewController.stringURL = order.urlAction;
        UINavigationController *currentVC = [SimiGlobalVar sharedInstance].currentlyNavigationController;
        UINavigationController *navi  = [[UINavigationController alloc]initWithRootViewController:viewController];
        [currentVC presentViewController:navi animated:YES completion:nil];
    }
}
@end
