//
//  SimiAvenueWorker.m
//  SimiCartPluginFW
//
//  Created by biga on 11/6/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SimiOrderModel.h>
#import "SimiPaymentWorker.h"

#define METHOD_PAYMENT @"SIMICUSTOMPAYMENT"
#define ALERT_VIEW_ERROR 0


@implementation SimiPaymentWorker{
    SimiModel *payment;
    NSString *payPalAppKey;
    NSString *payPalReceiverEmail;
    NSString *bnCode;
    SimiViewController *viewController;
    SimiOrderModel *order;
}

+ (id)sharedInstance{
    static SimiPaymentWorker *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SimiPaymentWorker alloc] init];
    });
    return _sharedInstance;
}


- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder-Before" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetCustomPayments" object:nil];
        [[self customPayment] getCustomPaymentsWithParams:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"DidPlaceOrder-Before"]){
        payment = [noti.userInfo valueForKey:@"payment"];
        for(NSDictionary* payment1 in _customPayment){
            if ([[NSString stringWithFormat:@"%@",[payment1 valueForKey:@"paymentmethod"]] caseInsensitiveCompare:[NSString stringWithFormat:@"%@",[payment valueForKey:@"payment_method"]]] == NSOrderedSame) {
                [self didPlaceOrder:noti];
                break;
            }
        }
    }else if([noti.name isEqualToString:@"DidGetCustomPayments"]){
        
    }
}

- (void)didPlaceOrder:(NSNotification *)noti
{
    UINavigationController *currentVC = [SimiGlobalVar sharedInstance].currentlyNavigationController;
    order = [noti.userInfo valueForKey:@"data"];
    @try {
        if([order valueForKey:@"invoice_number"] &&[order valueForKey:@"payment_method"] && [order valueForKey:@"url_action"] && [_customPayment count] > 0){
            NSString *url = [order valueForKey:@"url_action"];
            SimiPaymentWebView *nextController = [[SimiPaymentWebView alloc] init];
            url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            for(NSDictionary* payment1 in _customPayment){
                if([[NSString stringWithFormat:@"%@",[payment1 valueForKey:@"paymentmethod"]] caseInsensitiveCompare:[NSString stringWithFormat:@"%@",[order valueForKey:@"payment_method"]]] == NSOrderedSame){
                    nextController.payment = payment1;
                    break;
                }
            }
            [nextController setOrderID:[order valueForKey:@"invoice_number" ]];
            [nextController setUrlPath:url];
            UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:nextController];
            [currentVC presentViewController:navi animated:YES completion:nil];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, Credit Card Payments is not now available. Please try again later.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alertView.tag = ALERT_VIEW_ERROR;
            [alertView show];
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, Credit Card Payments is not now available. Please try again later.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alertView.tag = ALERT_VIEW_ERROR;
        [alertView show];
    }
    @finally {
        
    }
}

- (CustomPaymentModelCollection*) customPayment{
    if(_customPayment == nil){
        _customPayment = [CustomPaymentModelCollection new];
    }
    return _customPayment;
}

@end
