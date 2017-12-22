//
//  CheckoutcomModel.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 11/10/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "CheckoutcomModel.h"

@implementation CheckoutcomModel
- (void)completeOrderWithParams:(NSDictionary *)params{
    notificationName = CheckoutCom_DidUpdateCheckoutComPayment;
    self.parseKey = @"checkoutcomapi";
    self.resource = @"checkoutcomapis/update_payment";
    if (params.count > 0) {
        [self.params addEntriesFromDictionary:params];
    }
    self.method = MethodGet;
    [self preDoRequest];
    [self request];
}
@end
