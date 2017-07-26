//
//  SimiAvenueWorker.m
//  SimiCartPluginFW
//
//  Created by biga on 11/6/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SCAppDelegate.h>
#import "SimiAvenueWorker.h"
#import "SimiOrderModel+Avenue.h"

#define METHOD_AVENUE @"SIMIAVENUE"
#define ALERT_VIEW_ERROR 0

@implementation SimiAvenueWorker{
    SimiModel *payment;
    NSString *payPalAppKey;
    NSString *payPalReceiverEmail;
    NSString *bnCode;
    SimiViewController *viewController;
    SimiOrderModel *order;
    SimiCartModel *cart;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder-Before" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savePaymentMethodBefore:) name:@"SavePaymentMethod-Before" object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"DidPlaceOrder-Before"]){
        payment = [noti.userInfo valueForKey:@"payment"];
        if ([[payment valueForKey:@"payment_method"] isEqualToString:METHOD_AVENUE]) {
            [self didPlaceOrder:noti];
        }
    }
}

- (void)savePaymentMethodBefore:(NSNotification*)noti{
    payment = [noti.userInfo valueForKey:@"payment"];
    if ([[payment valueForKey:@"payment_method"] isEqualToString:METHOD_AVENUE]) {
        SimiModel *shippingAddress = [noti.userInfo valueForKey:@"shipping_address"];
        SimiModel *billingAddress = [noti.userInfo valueForKey:@"billing_address"];
        if (![billingAddress valueForKey:@"state_name"] || [[billingAddress valueForKey:@"state_name"] isKindOfClass:[NSNull class]] || [[billingAddress valueForKey:@"state_name"] isEqualToString:@""]) {
            viewController = noti.object;
            viewController.isDiscontinue = YES;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:SCLocalizedString(@"The billing address doesn't have a state. Please update it or select another address to place order.") delegate:nil cancelButtonTitle:SCLocalizedString(@"Ok") otherButtonTitles:nil];
            [alert show];
            return;
        }
        if (![shippingAddress valueForKey:@"state_name"] || [[shippingAddress valueForKey:@"state_name"] isKindOfClass:[NSNull class]] || [[shippingAddress valueForKey:@"state_name"] isEqualToString:@""]) {
            viewController = noti.object;
            viewController.isDiscontinue = YES;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:SCLocalizedString(@"The shipping address doesn't have a state. Please update it or select another address to place order.") delegate:nil cancelButtonTitle:SCLocalizedString(@"Ok") otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
}

- (void)didPlaceOrder:(NSNotification *)noti
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    order = [noti.userInfo valueForKey:@"data"];
    cart = [noti.userInfo valueForKey:@"cart"];
    @try {
        if([order valueForKey:@"invoice_number"] && [order valueForKey:@"params"]){
            NSString *url = [order valueForKey:@"params"];
            SimiAvenueWebView *nextController = [[SimiAvenueWebView alloc] init];
            url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [nextController setUrlPath:url];
            nextController.title =  SCLocalizedString(@"CCAvenue");
            nextController.webTitle = SCLocalizedString(@"CCAvenue");
            [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, CCAvenue is not now available. Please try again later.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alertView.tag = ALERT_VIEW_ERROR;
            [alertView show];
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, CCAvenue is not now available. Please try again later.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alertView.tag = ALERT_VIEW_ERROR;
        [alertView show];
    }
    @finally {
        
    }
}

@end
