//
//  SCLoginViewController_Theme01.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/2/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SimiCustomerModel.h>
#import <SimiCartBundle/SimiResponder.h>
#import <SimiCartBundle/KeychainItemWrapper.h>
#import <SimiCartBundle/SCWebViewController.h>
#import <SimiCartBundle/SCForgotPasswordViewController.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SCOrderHistoryViewController.h>
#import "SCLoginViewController_Theme01.h"
#import "SimiGlobalVar+Theme01.h"
#import "SimiThemeWorker.h"

@interface SCLoginViewController_Theme01 ()

@end

@implementation SCLoginViewController_Theme01

- (void)viewDidLoadBefore
{
    [super viewDidLoadBefore];
    self.navigationItem.title = [SCLocalizedString(@"Sign In") uppercaseString];
}

- (void)didReceiveNotification:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if ([noti.name isEqualToString:kNotiLogin]) {
            NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
            NSString *bundleIdentifier = [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleIdentifier"]];
            KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:bundleIdentifier accessGroup:nil];
            [wrapper setObject:self.textFieldPassword.text forKey:(__bridge id)(kSecAttrDescription)];
            if(self.isLoginInCheckout)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PushLoginInCheckout" object:nil];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else
                {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
            else
            {
                [self finishLogin];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PushLoginNormal" object:self];
                
            }
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK" ) otherButtonTitles: nil];
        self.textFieldPassword.text = @"";
        [alertView show];
    }
    [self stopLoadingData];
}


#pragma mark FinishLogin
-(void)finishLogin
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        switch (self.scLoginWhenClick) {
            case SCLoginWhenClickAddressBook:
            {
                SCAddressViewController *addressViewController = [[SCAddressViewController alloc]init];
                UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
                addressViewController.isGetOrderAddress = NO;
                addressViewController.enableEditing = YES;
                [(UINavigationController *)currentVC popToRootViewControllerAnimated:NO];
                [(UINavigationController *)currentVC pushViewController:addressViewController animated:YES];
                
            }
                break;
            case SCLoginWhenClickProfile:
            {
                SCProfileViewController *nextController = [[SCProfileViewController alloc]init];
                UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
                [(UINavigationController *)currentVC popToRootViewControllerAnimated:NO];
                [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
            }
                break;
            case SCLoginWhenClickOrderHistory:
            {
                SCOrderHistoryViewController *orderViewController = [[SCOrderHistoryViewController alloc]init];
                UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
                
                [(UINavigationController *)currentVC popToRootViewControllerAnimated:NO];
                [(UINavigationController *)currentVC pushViewController:orderViewController animated:YES];
            }
                break;
            case SCLoginWhenClickSignIn:
            {
                UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
                if (!self.isLoginInCheckout) {
                    [(UINavigationController *)currentVC popToRootViewControllerAnimated:NO];
                }else{
                    [self goBackPreviousControllerAnimated:YES];
                }
            }
                break;
            default:
                [self goBackPreviousControllerAnimated:YES];
                break;
        }
    }else
    {
        if (self.scLoginWhenClick == SCLoginWhenClickSignIn) {
            [self.delegate didFinishLoginSuccess];
            [self goBackPreviousControllerAnimated:YES];
        }else
        {
            [self goBackPreviousControllerAnimated:YES];
        }
    }
}

@end
