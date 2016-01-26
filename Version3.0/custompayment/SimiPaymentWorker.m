//
//  SimiAvenueWorker.m
//  SimiCartPluginFW
//
//  Created by biga on 11/6/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SCAppDelegate.h>
#import "SimiPaymentWorker.h"
#import <SimiCartBundle/SimiOrderModel.h>

//Axe need edit
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
            if (([[payment1 valueForKey:@"paymentmethod"] isEqualToString:[payment valueForKey:@"payment_method"]])||([[[payment1 valueForKey:@"paymentmethod"] uppercaseString] isEqualToString:[payment valueForKey:@"payment_method"]])) {
                [self didPlaceOrder:noti];
            }
            break;
        }
    }else if([noti.name isEqualToString:@"DidGetCustomPayments"]){
        if(noti.object)
            _customPayment = noti.object;
    }
}



- (void)didPlaceOrder:(NSNotification *)noti
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    order = [noti.userInfo valueForKey:@"data"];
    
    @try {
        if([order valueForKey:@"invoice_number"] &&[order valueForKey:@"payment_method"] && [order valueForKey:@"url_action"] && [_customPayment count] > 0){
            NSString *url = [order valueForKey:@"url_action"];
            SimiPaymentWebView *nextController = [[SimiPaymentWebView alloc] init];
            url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            for(NSDictionary* payment1 in _customPayment){
                if([[payment1 valueForKey:@"paymentmethod"] isEqualToString:[order valueForKey:@"payment_method"]]){
                    nextController.payment = payment1;
                    break;
                }
            }
            [nextController setOrderID:[order valueForKey:@"invoice_number" ]];
            [nextController setUrlPath:url];
            nextController.title =  SCLocalizedString([payment valueForKey:@"title"]);
            nextController.webTitle = SCLocalizedString([payment valueForKey:@"title"]);
            [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
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

-(CustomPaymentModelCollection*) customPayment{
    if(_customPayment == nil){
        _customPayment = [CustomPaymentModelCollection new];
    }
    return _customPayment;
}

@end
