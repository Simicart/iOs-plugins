//
//  SimiOrderAPI+TwoCheckout.m
//  SimiCartPluginFW
//
//  Created by biga on 11/7/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiOrderModel+TwoCheckout.h"

@implementation SimiOrderModel (TwoCheckout)
- (void)updateTwoutOrderWithParams:(NSDictionary *)params{
    self.parseKey = @"twoutapi";
    notificationName = TwoutCheckOut_DidUpdate2CheckoutPayment;
    self.resource = @"twoutapis/update_order";
    if (params.count > 0) {
        [self.body addEntriesFromDictionary:params];
    }
    self.method = MethodPut;
    [self request];
}
@end
