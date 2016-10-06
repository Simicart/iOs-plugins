//
//  SimiOrderAPI+TwoCheckout.m
//  SimiCartPluginFW
//
//  Created by biga on 11/7/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiOrderModel+TwoCheckout.h"
#import "SimiOrderAPI+TwoCheckout.h"

@implementation SimiOrderModel (TwoCheckout)

- (void)updateTwoutOrderWithParams:(NSDictionary *)params{
    modelActionType = ModelActionTypeGet;
    keyResponse = @"twoutapi";
    currentNotificationName = @"DidUpdate2CheckoutPayment";
    [self preDoRequest];
    [(SimiOrderAPI *)[self getAPI] updateTwoutOrderWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

@end
