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
        if ([[[payment valueForKey:@"payment_method"] lowercaseString] isEqualToString:@"simicheckoutcom"] &&[order valueForKey:@"invoice_number"]) {
            SCCheckoutcomViewController *checkoutVC = [[SCCheckoutcomViewController alloc] init];
            checkoutVC.order = [order copy];
            UINavigationController *currentVC = [SimiGlobalVar sharedInstance].currentlyNavigationController;
            UINavigationController *navi  = [[UINavigationController alloc]initWithRootViewController:checkoutVC];
            [currentVC presentViewController:navi animated:YES completion:nil];
        }
    }
}
@end
