//
//  SCPaypalMobileInitWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/25/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCPaypalMobileInitWorker.h"
#import "SimiOrderModel+PayPal.h"
#import <SimiCartBundle/SCAppDelegate.h>

#define ALERT_VIEW_ERROR 0

#define DidPlaceOrder_After @"DidPlaceOrder-After"
#define PAYPAL_MOBILE @"PAYPAL_MOBILE"

@implementation SCPaypalMobileInitWorker{
    SimiModel *payment;
    NSString *payPalAppKey;
    NSString *payPalReceiverEmail;
    NSString *bnCode;
    SimiViewController *viewController;
    SimiOrderModel *order;
    SimiOrderModel *paypalOrder;
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
    if ([[payment valueForKey:@"payment_method"] isEqualToString:PAYPAL_MOBILE]) {
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
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, PayPal is not now available. Please try again later") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                alertView.tag = ALERT_VIEW_ERROR;
                [alertView show];
                [viewController stopLoadingData];
            }
            @finally {
                
            }
        }else if ([noti.name isEqualToString:DidPlaceOrder_After]){
            [self didPlaceOrder:noti];
        }
    }
}

- (void)didPlaceOrder:(NSNotification *)noti{
    viewController = [noti.userInfo valueForKey:@"controller"];
    if (!viewController) {
        UINavigationController *navi = [SimiGlobalVar sharedInstance].currentlyNavigationController;
        viewController = [navi.viewControllers lastObject];
        
    }
    order = [noti.userInfo valueForKey:@"data"];
    SimiModel *fee = [order valueForKey:@"total"];
    
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
        pay.amount = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%@",[fee valueForKey:@"grand_total_incl_tax"]]];
        pay.currencyCode = [[SimiGlobalVar sharedInstance] currencyCode];
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
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, PayPal is not now available. Please try again later") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alertView.tag = ALERT_VIEW_ERROR;
            [alertView show];
            [viewController stopLoadingData];
            [viewController.navigationController popViewControllerAnimated:YES];
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:[NSString stringWithFormat:SCLocalizedString(@"Sorry, %@ is not now available. Please try again later"),SCLocalizedString(@"Paypal")] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:SCLocalizedString([paypalOrder valueForKey:@"message"]) delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
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
    if (paypalOrder == nil) {
        paypalOrder = [SimiOrderModel new];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdatePaymentStatus:) name:DidSavePaypalPayment object:paypalOrder];
    [paypalOrder savePaymentWithStatus:[NSString stringWithFormat:@"%ld",(long)PaymentStatusCancelled] invoiceNumber:[NSString stringWithFormat:@"%@",[order valueForKey:@"invoice_number"]] proof:nil];
    [viewController dismissViewControllerAnimated:YES completion:^{
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    }];
    [viewController startLoadingData];
}

#pragma mark Proof of payment validation
- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    if (paypalOrder == nil) {
        paypalOrder = [SimiOrderModel new];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdatePaymentStatus:) name:DidSavePaypalPayment object:paypalOrder];
    [paypalOrder savePaymentWithStatus:[NSString stringWithFormat:@"%ld",(long)PaymentStatusApproved] invoiceNumber:[NSString stringWithFormat:@"%@",[order valueForKey:@"invoice_number"]] proof:completedPayment.confirmation];
    [viewController dismissViewControllerAnimated:YES completion:^{
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    }];
    [viewController startLoadingData];
}

#pragma mark Alert View Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == ALERT_VIEW_ERROR) {
        if (paypalOrder == nil) {
            paypalOrder = [SimiOrderModel new];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdatePaymentStatus:) name:DidSavePaypalPayment object:paypalOrder];
        [paypalOrder savePaymentWithStatus:[NSString stringWithFormat:@"%ld",(long)PaymentStatusCancelled] invoiceNumber:nil proof:nil];
        [viewController dismissViewControllerAnimated:YES completion:^{
            [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        }];
        [viewController startLoadingData];
    }
}

@end
