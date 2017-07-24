//
//  SCPayfortWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 7/24/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCPayfortWorker.h"
#import "SCPayfortViewController.h"

@implementation SCPayfortWorker {
    SimiModel *order;
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
        if ([[[order valueForKey:@"payment_method"] lowercaseString] isEqualToString:@"simipayfort"] &&[order valueForKey:@"invoice_number"]) {
            SCPayfortViewController *payfortVC = [[SCPayfortViewController alloc] init];
            payfortVC.navigationItem.title = [[order objectForKey:@"payment"] objectForKey:@"title"];
            payfortVC.order = order;
            UINavigationController *currentVC = [SimiGlobalVar sharedInstance].currentlyNavigationController;
            UINavigationController *navi  = [[UINavigationController alloc]initWithRootViewController:payfortVC];
            [currentVC presentViewController:navi animated:YES completion:nil];
        }
    }
}
@end
