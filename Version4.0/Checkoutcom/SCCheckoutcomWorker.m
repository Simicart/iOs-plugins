//
//  SCCheckoutcomWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 11/10/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCCheckoutcomWorker.h"
#import "SCCheckoutcomViewController.h"
#import <SimiCartBundle/SCOrderViewController.h>
#import <SimiCartBundle/SCAppDelegate.h>

@implementation SCCheckoutcomWorker
{
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
    if ([[payment.code lowercaseString] isEqualToString:@"simicheckoutcom"] && order.invoiceNumber) {
        SCCheckoutcomViewController *checkoutVC = [[SCCheckoutcomViewController alloc] init];
        checkoutVC.order = order;
        UINavigationController *currentVC = [SimiGlobalVar sharedInstance].currentlyNavigationController;
        UINavigationController *navi  = [[UINavigationController alloc]initWithRootViewController:checkoutVC];
        [currentVC presentViewController:navi animated:YES completion:nil];
    }
}
@end
