//
//  SCWishlistModelCollection.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 11/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCPaypalExpressModel.h"

@implementation SCPaypalExpressModel

- (void)startPaypalExpress
{
    currentNotificationName = @"DidStartPaypalExpress";
    keyResponse = @"ppexpressapi";
    [self preDoRequest];
    modelActionType = ModelActionTypeGet;
    [(SCPaypalExpressAPI *)[self getAPI] startPaypalExpress:self selector:@selector(didFinishRequest:responder:)];
}

- (void)reviewAddress
{
    currentNotificationName = @"DidGetPaypalAdressInformation";
    keyResponse = @"ppexpressapi";
    [self preDoRequest];
    modelActionType = ModelActionTypeGet;
    [(SCPaypalExpressAPI *)[self getAPI] reviewAddress:self selector:@selector(didFinishRequest:responder:)];
}

- (void)placeOrderWithParam:(NSDictionary *)params{
    modelActionType = ModelActionTypeGet;
    currentNotificationName = @"PaypalExpressDidPlaceOrder";
    keyResponse = @"order";
    [self preDoRequest];
    [(SCPaypalExpressAPI *)[self getAPI] placeOrderWithParam:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)updateAddressWithParam:(NSDictionary *)params{
    modelActionType = ModelActionTypeGet;
    currentNotificationName = @"DidUpdatePaypalCheckoutAddress";
    keyResponse = @"ppexpressapi";
    [self preDoRequest];
    [(SCPaypalExpressAPI *)[self getAPI] updateAddressWithParam:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)getShippingMethods
{
    currentNotificationName = @"DidGetPaypalCheckoutShippingMethods";
    keyResponse = @"ppexpressapi";
    [self preDoRequest];
    modelActionType = ModelActionTypeGet;
    [(SCPaypalExpressAPI *)[self getAPI] getShippingMethod:self selector:@selector(didFinishRequest:responder:)];
}

-(void) saveShippingMethod:(NSDictionary*) params{
    currentNotificationName = DidSaveShippingMethod;
    keyResponse = @"ppexpressapi";
    [self preDoRequest];
    modelActionType = ModelActionTypeGet;
    NSString* url = [NSString stringWithFormat:@"%@simiconnector/rest/v2/ppexpressapis/save_shipping_method",kBaseURL];
    [[SimiAPI new] requestWithMethod:PUT URL:url params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}

@end
