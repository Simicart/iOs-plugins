//
//  SimiOrderAPI+Checkoutcom.m
//  SimiCartPluginFW
//
//  Created by biga on 11/7/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiOrderModel+Checkoutcom.h"
#import "SimiOrderAPI+Checkoutcom.h"

@implementation SimiOrderModel (Checkoutcom)

- (void)updateCheckoutcomOrderWithParams:(NSDictionary *)params{
    modelActionType = ModelActionTypeGet;
    currentNotificationName = @"DidUpdate2CheckoutPayment";
    [self preDoRequest];
    [(SimiOrderAPI *)[self getAPI] updateCheckoutcomOrderWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

@end
