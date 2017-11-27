//
//  LoyaltyLoginViewController.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 1/21/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import <SimiCartBundle/SCAppDelegate.h>

#import "LoyaltyLoginViewController.h"
#import "LoyaltyViewController.h"

@implementation LoyaltyLoginViewController

- (void)didReceiveNotification:(NSNotification *)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if ([noti.name isEqualToString:@"DidLogin"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PushLoginNormal" object:nil];
            if (self.navigationController.viewControllers.count) {
                LoyaltyViewController *back = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
                back.skipReloadData = NO;
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                 UINavigationController *currentVC = (UINavigationController*)[(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
                [currentVC pushViewController:[LoyaltyViewController new] animated:YES];
            }
        }
    } else {
        self.textFieldPassword.text = @"";
        [self showAlertWithTitle:SCLocalizedString(responder.status) message:responder.responseMessage];
    }
    [self stopLoadingData];
}

@end
