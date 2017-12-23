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
#import <SimiCartBundle/SCOrderViewController.h>

#define PAYPAL_MOBILE @"PAYPAL_MOBILE"

@implementation SCPaypalMobileInitWorker{
    SimiPaymentMethodModel *payment;
    NSString *payPalAppKey;
    NSString *payPalReceiverEmail;
    NSString *bnCode;
    SimiViewController *viewController;
    SimiOrderModel *order;
    SimiOrderModel *paypalOrder;
}

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceOrder:) name:SCOrderViewController_DidPlaceOrderSuccess object:nil];
    }
    return self;
}

- (void)didPlaceOrder:(NSNotification *)noti{
    order = noti.object;
    payment = [noti.userInfo valueForKey:KEYEVENT.ORDERVIEWCONTROLLER.selected_payment];
    viewController = [noti.userInfo valueForKey:KEYEVENT.ORDERVIEWCONTROLLER.viewcontroller];
    if (![payment.code isEqualToString:@"PAYPAL_MOBILE"]) {
        return;
    }
    if (!viewController) {
        UINavigationController *navi = [SimiGlobalVar sharedInstance].currentlyNavigationController;
        viewController = [navi.viewControllers lastObject];
        
    }
    payPalAppKey = [payment valueForKey:@"client_id"];
    payPalReceiverEmail = [payment valueForKey:@"email"];
    bnCode = [payment valueForKey:@"bncode"];
    BOOL isSandbox = [[payment valueForKey:@"is_sandbox"] boolValue];
    @try {
        if (isSandbox) {
            [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentSandbox : payPalAppKey}];
            [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
        }else{
            [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : payPalAppKey}];
            [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentProduction];
        }
        
        PayPalConfiguration *_payPalConfig = [[PayPalConfiguration alloc] init];
        _payPalConfig.acceptCreditCards = [[payment objectForKey:@"use_credit_card"] boolValue];
        _payPalConfig.languageOrLocale = LOCALE_IDENTIFIER;
        _payPalConfig.payPalShippingAddressOption = PayPalShippingAddressOptionBoth;
        
        PayPalPayment *pay = [[PayPalPayment alloc] init];
        pay.amount = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%@",[order.total valueForKey:@"grand_total_incl_tax"]]];
        pay.currencyCode = [[SimiGlobalVar sharedInstance] currencyCode];
        pay.bnCode = bnCode;
        pay.shortDescription = [NSString stringWithFormat:@"%@ #: %@", SCLocalizedString(@"Invoice"), [order valueForKey:@"invoice_number"]];
        if(order.shippingAddress.count > 0){
            SimiAddressModel *shippingAddress = order.billingAddress;
            PayPalShippingAddress *paypalShippingAddress = [[PayPalShippingAddress alloc] init];
            paypalShippingAddress.city = shippingAddress.city;
            paypalShippingAddress.countryCode = shippingAddress.countryId;
            paypalShippingAddress.recipientName = [NSString stringWithFormat:@"%@ %@",shippingAddress.firstName,shippingAddress.lastName];
            paypalShippingAddress.postalCode = shippingAddress.postcode;
            paypalShippingAddress.state = shippingAddress.region;
            paypalShippingAddress.line1 = shippingAddress.street;
            pay.shippingAddress = paypalShippingAddress;
        }
        
        
        // Check whether payment is processable.
        if (pay.processable) {
            PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:pay configuration:_payPalConfig delegate:self];
            
            // Present the PayPalPaymentViewController.
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                [[UINavigationBar appearance] setTintColor: [UIColor colorWithRed:0 green:69/255.0 blue:124/255.0 alpha:1]];
            }
            [viewController startLoadingData];
            [viewController presentViewController:paymentViewController animated:YES completion:nil];
        }else{
            [self paypalCancel];
        }
    }
    @catch (NSException *exception) {
        [self paypalCancel];
    }
    @finally {
        
    }
}

- (void)paypalCancel{
    [viewController stopLoadingData];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:SCLocalizedString(@"Sorry, PayPal is not now available. Please try again later") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:SCLocalizedString(@"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self updatePaymentToServerWithStatus:PaymentStatusCancelled andProof:@{}];
        [viewController.navigationController popViewControllerAnimated:YES];
    }]];
    [viewController presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (void)didUpdatePaymentStatus:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if(responder.status == SUCCESS){
        [((SimiViewController *)[SimiGlobalVar sharedInstance].currentViewController) showAlertWithTitle:@"" message:[paypalOrder valueForKey:@"message"] completionHandler:^{
            [viewController.navigationController popToRootViewControllerAnimated:YES];
        }];
    }else{
        [((SimiViewController *)[SimiGlobalVar sharedInstance].currentViewController) showAlertWithTitle:@"" message:responder.message completionHandler:^{
            [viewController.navigationController popToRootViewControllerAnimated:YES];
        }];
    }
    [self removeObserverForNotification:noti];
    [viewController stopLoadingData];
}

#pragma mark PayPalPaymentDelegate methods
- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    if (SIMI_DEBUG_ENABLE) {
        NSLog(@"PayPal Payment Success!");
    }
    // Payment was processed successfully; send to server for verification and fulfillment
    [self updatePaymentToServerWithStatus:PaymentStatusApproved andProof:completedPayment.confirmation];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    [self updatePaymentToServerWithStatus:PaymentStatusCancelled andProof:@{}];
}


- (void)updatePaymentToServerWithStatus: (PaymentStatus) paymentStatus andProof: (NSDictionary *)proof {
    if (paypalOrder == nil) {
        paypalOrder = [SimiOrderModel new];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdatePaymentStatus:) name:Simi_DidSavePaypalPayment object:paypalOrder];
    [paypalOrder savePaymentWithStatus:[NSString stringWithFormat:@"%ld",(long)paymentStatus] invoiceNumber:[NSString stringWithFormat:@"%@",[order valueForKey:@"invoice_number"]] proof:proof];
    [viewController dismissViewControllerAnimated:YES completion:^{
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    }];
    [viewController startLoadingData];
}



@end
