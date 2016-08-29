//
//  CheckoutOrderApi.m
//  SimiCartPluginFW
//
//  Created by biga on 11/7/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiOrderAPI+Avenue.h"
#import "SimiGlobalVar+Avenue.h"

@implementation SimiOrderAPI (Avenue)

- (void)updateAvenueOrderWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiAvenueUpdatePayment];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}


@end
