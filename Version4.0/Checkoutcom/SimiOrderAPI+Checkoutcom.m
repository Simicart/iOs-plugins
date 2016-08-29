//
//  CheckoutOrderApi.m
//  SimiCartPluginFW
//
//  Created by biga on 11/7/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiOrderAPI+Checkoutcom.h"
#import "SimiGlobalVar+Checkoutcom.h"

@implementation SimiOrderAPI (TwoCheckout)

- (void)updateCheckoutcomOrderWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiCheckoutcomUpdatePayment];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}


@end
