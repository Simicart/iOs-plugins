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
@implementation KlarnaWorker{
    SCOrderViewController *orderViewController;
    SimiOrderModel *order;
    SimiPaymentMethodModel *payment;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(beforePlaceOrder:) name:SCOrderViewController_BeforePlaceOrder object:nil];
    }
    return self;
}

- (void)beforePlaceOrder:(NSNotification *)noti{
    order = noti.object;
    orderViewController = [noti.userInfo valueForKey:KEYEVENT.ORDERVIEWCONTROLLER.viewcontroller];
    payment = [noti.userInfo valueForKey:KEYEVENT.ORDERVIEWCONTROLLER.selected_payment];
    if ([payment.code isEqualToString:@"SIMIKLARNA"]) {
        orderViewController.isDiscontinue = YES;
        [orderViewController.navigationController popToRootViewControllerAnimated:NO];
        KlarnaViewController *viewController = [[KlarnaViewController alloc] init];
        viewController.order = order;
        UINavigationController *currentVC = [SimiGlobalVar sharedInstance].currentlyNavigationController;
        UINavigationController *navi  = [[UINavigationController alloc]initWithRootViewController:viewController];
        [currentVC presentViewController:navi animated:YES completion:nil];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
