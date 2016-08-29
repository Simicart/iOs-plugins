//
//  CheckoutOrderApi.m
//  SimiCartPluginFW
//
//  Created by biga on 11/7/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiOrderAPI+TwoCheckout.h"
#import "SimiGlobalVar+TwoCheckout.h"

@implementation SimiOrderAPI (TwoCheckout)

- (void)updateTwoutOrderWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiTwoutUpdatePayment];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}


@end
