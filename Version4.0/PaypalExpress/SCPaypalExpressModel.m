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
    [[SCPaypalExpressAPI new] startPaypalExpress:self selector:@selector(didGetResponseFromNetwork:)];
}

- (void)reviewAddress{
    notificationName = SCPaypalExpress_DidGetPaypalAddressInformation;
    self.parseKey = @"ppexpressapi";
    [[SCPaypalExpressAPI new] reviewAddress:self selector:@selector(didGetResponseFromNetwork:)];
}

- (void)placeOrderWithParam:(NSDictionary *)params{
    notificationName = SCPaypalExpress_PaypalExpressDidPlaceOrder;
    self.parseKey = @"order";
    [[SCPaypalExpressAPI new] placeOrderWithParam:params target:self selector:@selector(didGetResponseFromNetwork:)];
}

- (void)updateAddressWithParam:(NSDictionary *)params{
    notificationName = SCPaypalExpress_DidUpdatePaypalCheckoutAddress;
    self.parseKey = @"ppexpressapi";
    [[SCPaypalExpressAPI new] updateAddressWithParam:params target:self selector:@selector(didGetResponseFromNetwork:)];
}

- (void)getShippingMethods{
    notificationName = SCPaypalExpress_DidGetPaypalCheckoutShippingMethods;
    self.parseKey = @"ppexpressapi";
    [[SCPaypalExpressAPI new] getShippingMethod:self selector:@selector(didGetResponseFromNetwork:)];
}
@end
