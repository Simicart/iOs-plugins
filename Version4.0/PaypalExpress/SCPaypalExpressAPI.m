//
//  SCProductAPI.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 11/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCPaypalExpressAPI.h"



NSString *const kSimiPaypalExpressStartURL = @"ppexpressapis/start";
NSString *const kSimiPaypalExpressReviewAddress = @"ppexpressapis/checkout_address";
NSString *const kSimiPaypalExpressUpdateAddress = @"ppexpressapis/checkout_address";
NSString *const kSimiPaypalExpressGetShippingMethods = @"ppexpressapis/shipping_methods";
NSString *const kSimiPaypalExpressPlaceOrder = @"ppexpressapis/place";

@implementation SCPaypalExpressAPI


- (void)startPaypalExpress:(id)target selector:(SEL)selector
{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL,kSimiPaypalExpressStartURL];
    [self requestWithMethod:GET URL:urlPath params:nil target:target selector:selector header:nil];
}


- (void)reviewAddress:(id)target selector:(SEL)selector
{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL, kSimiPaypalExpressReviewAddress];
    [self requestWithMethod:GET URL:urlPath params:nil target:target selector:selector header:nil];
}

- (void)updateAddressWithParam:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL, kSimiPaypalExpressUpdateAddress];
    [self requestWithMethod:PUT URL:url params:params target:target selector:selector header:nil];
}

- (void)getShippingMethod:(id)target selector:(SEL)selector
{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL,kSimiConnectorURL,kSimiPaypalExpressGetShippingMethods];
    [self requestWithMethod:GET URL:urlPath params:nil target:target selector:selector header:nil];
}

- (void)placeOrderWithParam:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL,kSimiPaypalExpressPlaceOrder];
    [self requestWithMethod:POST URL:url params:params target:target selector:selector header:nil];
}
@end
