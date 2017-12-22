//
//  SCWishlistModelCollection.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 11/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCPaypalExpressModel.h"

@implementation SCPaypalExpressModel

- (void)startPaypalExpress{
    notificationName = SCPaypalExpress_DidStartPaypalExpress;
    self.parseKey = @"ppexpressapi";
    self.resource = @"ppexpressapis/start";
    self.method = MethodGet;
    [self request];
}

- (void)reviewAddress{
    notificationName = SCPaypalExpress_DidGetPaypalAddressInformation;
    self.parseKey = @"ppexpressapi";
    self.resource = @"ppexpressapis/checkout_address";
    self.method = MethodGet;
    [self request];
}

- (void)placeOrderWithParam:(NSDictionary *)params{
    notificationName = SCPaypalExpress_PaypalExpressDidPlaceOrder;
    self.parseKey = @"order";
    self.resource = @"ppexpressapis/place";
    if (params.count > 0) {
        [self.body addEntriesFromDictionary:params];
    }
    self.method = MethodPost;
    [self request];
}

- (void)updateAddressWithParam:(NSDictionary *)params{
    notificationName = SCPaypalExpress_DidUpdatePaypalCheckoutAddress;
    self.parseKey = @"ppexpressapi";
    self.resource = @"ppexpressapis/checkout_address";
    if (params.count > 0) {
        [self.body addEntriesFromDictionary:params];
    }
    self.method = MethodPut;
    [self request];
}

- (void)getShippingMethods{
    notificationName = SCPaypalExpress_DidGetPaypalCheckoutShippingMethods;
    self.parseKey = @"ppexpressapi";
    self.resource = @"ppexpressapis/shipping_methods";
    self.method = MethodGet;
    [self request];
}
@end
