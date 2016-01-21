//
//  SimiPayPalWorker.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/27/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiPayPalWorker.h"
#import "SimiOrderModel+PayPal.h"
#import <SimiCartBundle/SCAppDelegate.h>

#define ALERT_VIEW_ERROR 0

@implementation SimiPayPalWorker{
    SimiModel *payment;
    NSString *payPalAppKey;
    NSString *payPalReceiverEmail;
    NSString *bnCode;
    SimiViewController *viewController;
    SimiOrderModel *order;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder-After" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSelectPaymentMethod" object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti{
    payment = [noti.userInfo valueForKey:@"payment"];
    if ([[payment valueForKey:@"payment_method"] isEqualToString:@"PAYPAL_MOBILE"]) {
        if ([noti.name isEqualToString:@"DidSelectPaymentMethod"]) {
            payPalAppKey = [payment valueForKey:@"client_id"];
            payPalReceiverEmail = [payment valueForKey:@"email"];
            BOOL isSandbox = [[payment valueForKey:@"is_sandbox"] boolValue];
            @try {
                if (isSandbox) {
                    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentSandbox : payPalAppKey}];
                    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
                }else{
                    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : payPalAppKey}];
                    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentProduction];
                }
            }
            @catch (NSException *exception) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, PayPal is not now available. Please try again later.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                alertView.tag = ALERT_VIEW_ERROR;
                [alertView show];
                [viewController stopLoadingData];
            }
            @finally {
                
            }
        }else if ([noti.name isEqualToString:@"DidPlaceOrder-After"]){
            [self didPlaceOrder:noti];
        }
    }
}

- (void)didPlaceOrder:(NSNotification *)noti{
    viewController = [noti.userInfo valueForKey:@"controller"];
    if (!viewController) {
        UINavigationController *navi = (UINavigationController *)[(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
        viewController = [navi.viewControllers lastObject];
        
    }
    order = [noti.userInfo valueForKey:@"data"];
    SimiModel *fee = [order valueForKey:@"fee"];
    
    payPalAppKey = [payment valueForKey:@"client_id"];
    payPalReceiverEmail = [payment valueForKey:@"email"];
    bnCode = [payment valueForKey:@"bncode"];
    
    BOOL isSandbox = [[payment valueForKey:@"is_sandbox"] boolValue];
    @try {
        if (isSandbox) {
            [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
        }else{
            [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentProduction];
        }
        
        PayPalConfiguration *_payPalConfig = [[PayPalConfiguration alloc] init];
        _payPalConfig.acceptCreditCards = YES;
        _payPalConfig.languageOrLocale = LOCALE_IDENTIFIER;
        
        PayPalPayment *pay = [[PayPalPayment alloc] init];
        pay.amount = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%.2f", [[fee valueForKey:@"grand_total"] floatValue]]];
        pay.currencyCode = CURRENCY_CODE;
        pay.bnCode = bnCode;
        pay.shortDescription = [NSString stringWithFormat:@"%@ #: %@", SCLocalizedString(@"Invoice"), [order valueForKey:@"invoice_number"]];
        pay.intent = PayPalPaymentIntentSale;
        if ([[payment valueForKey:@"payment_action"] isEqualToString:@"order"]) {
            pay.intent = PayPalPaymentIntentOrder;
        }else if([[payment valueForKey:@"payment_action"] isEqualToString:@"authorization"])
        {
            pay.intent = PayPalPaymentIntentAuthorize;
        }
        // Check whether payment is processable.
        if (pay.processable) {
            PayPalPaymentViewController *paymentViewController;
            paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:pay configuration:_payPalConfig delegate:self];
            
            // Present the PayPalPaymentViewController.
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                [[UINavigationBar appearance] setTintColor: [UIColor colorWithRed:0 green:69/255.0 blue:124/255.0 alpha:1]];
            }
            [viewController startLoadingData];
            [viewController presentViewController:paymentViewController animated:YES completion:nil];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, PayPal is not now available. Please try again later.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alertView.tag = ALERT_VIEW_ERROR;
            [alertView show];
            [viewController stopLoadingData];
            [viewController.navigationController popViewControllerAnimated:YES];
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, PayPal is not now available. Please try again later.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alertView.tag = ALERT_VIEW_ERROR;
        [alertView show];
        [viewController stopLoadingData];
        [viewController.navigationController popViewControllerAnimated:YES];
    }
    @finally {
        
    }
}

- (void)didUpdatePaymentStatus:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:SCLocalizedString(responder.responseMessage) delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
    [alertView show];
    [self removeObserverForNotification:noti];
    [viewController stopLoadingData];
    [viewController.navigationController popViewControllerAnimated:YES];
}

#pragma mark PayPalPaymentDelegate methods
- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    if (SIMI_DEBUG_ENABLE) {
        NSLog(@"PayPal Payment Success!");
    }
    // Payment was processed successfully; send to server for verification and fulfillment
    [self sendCompletedPaymentToServer:completedPayment];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    if (SIMI_DEBUG_ENABLE) {
        NSLog(@"PayPal Payment Canceled");
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdatePaymentStatus:) name:@"DidUpdatePaymentStatus" object:order];
    [order updateOrderWithPaymentStatus:PaymentStatusCancelled proof:nil];
    [viewController dismissViewControllerAnimated:YES completion:^{
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    }];
    [viewController startLoadingData];
}

#pragma mark Proof of payment validation
- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdatePaymentStatus:) name:@"DidUpdatePaymentStatus" object:order];
    [order updateOrderWithPaymentStatus:PaymentStatusApproved proof:completedPayment.confirmation];
    [viewController dismissViewControllerAnimated:YES completion:^{
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    }];
    [viewController startLoadingData];
}

#pragma mark Alert View Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == ALERT_VIEW_ERROR) {
        [self payPalPaymentDidCancel:nil];
    }
}

@end
