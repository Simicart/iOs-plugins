//
//  SimiAvenueWorker.m
//  SimiCartPluginFW
//
//  Created by biga on 11/6/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SimiOrderModel.h>
#import <SimiCartBundle/SCOrderViewController.h>
#import "SimiPaymentWorker.h"

#define METHOD_PAYMENT @"SIMICUSTOMPAYMENT"

@implementation SimiPaymentWorker{
    SimiPaymentMethodModel *payment;
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


- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceOrder:) name:SCOrderViewController_DidPlaceOrderSuccess object:nil];
        self.customPayment = [CustomPaymentModelCollection new];
        [self.customPayment getCustomPaymentsWithParams:nil];
    }
    return self;
}

- (void)didPlaceOrder:(NSNotification *)noti{
    payment = [noti.userInfo valueForKey:KEYEVENT.ORDERVIEWCONTROLLER.selected_payment];
    for(NSDictionary* unitPayment in self.customPayment.collectionData){
        if ([[NSString stringWithFormat:@"%@",[unitPayment valueForKey:@"paymentmethod"]] caseInsensitiveCompare:payment.code] == NSOrderedSame) {
            UINavigationController *currentVC = [SimiGlobalVar sharedInstance].currentlyNavigationController;
            order = noti.object;
            @try {
                if(order.invoiceNumber && order.paymentMethod && order.urlAction && [self.customPayment count] > 0){
                    NSString *url = order.urlAction;
                    SimiPaymentWebView *nextController = [[SimiPaymentWebView alloc] init];
                    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    nextController.payment = unitPayment;
                    [nextController setOrderID:[order valueForKey:@"invoice_number" ]];
                    [nextController setUrlPath:url];
                    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:nextController];
                    [currentVC presentViewController:navi animated:YES completion:nil];
                }else{
                    [self showAlertWithTitle:@"Error" message:[NSString stringWithFormat:@"Sorry, %@ is not now available. Please try again later",payment.title]];
                }
            }
            @catch (NSException *exception) {
                [self showAlertWithTitle:@"Error" message:[NSString stringWithFormat:@"Sorry, %@ is not now available. Please try again later",payment.title]];
            }
            @finally {
                
            }
            break;
        }
    }
}
@end
