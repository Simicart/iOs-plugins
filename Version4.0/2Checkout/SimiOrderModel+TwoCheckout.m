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
    self.parseKey = @"twoutapi";
    notificationName = TwoutCheckOut_DidUpdate2CheckoutPayment;
    [[SimiOrderAPI new] updateTwoutOrderWithParams:params target:self selector:@selector(didGetResponseFromNetwork:)];
}

@end
