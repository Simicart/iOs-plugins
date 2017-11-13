//
//  LoyaltyLoginViewController.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 1/21/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import <SimiCartBundle/KeychainItemWrapper.h>
#import <SimiCartBundle/SCAppDelegate.h>

#import "LoyaltyLoginViewController.h"
#import "LoyaltyViewController.h"

@implementation LoyaltyLoginViewController

- (void)didReceiveNotification:(NSNotification *)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        if ([noti.name isEqualToString:Simi_DidLogin]) {
            NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
            NSString *bundleIdentifier = [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleIdentifier"]];
            KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:bundleIdentifier accessGroup:nil];
            [wrapper setObject:self.textFieldPassword.text forKey:(__bridge id)(kSecAttrDescription)];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PushLoginNormal" object:nil];
            if (self.navigationController.viewControllers.count) {
                LoyaltyViewController *back = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
                back.skipReloadData = NO;
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                 UINavigationController *currentVC = kNavigationController;
                [currentVC pushViewController:[LoyaltyViewController new] animated:YES];
            }
        }
    } else {
        self.textFieldPassword.text = @"";
        [self showAlertWithTitle:@"" message:responder.message];
    }
    [self stopLoadingData];
}

@end
