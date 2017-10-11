//
//  CheckoutOrderApi.m
//  SimiCartPluginFW
//
//  Created by biga on 11/7/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiOrderAPI+Avenue.h"

@implementation SimiOrderAPI (Avenue)

- (void)updateAvenueOrderWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    url = [NSString stringWithFormat:@"%@%@%@", kBaseURL,kSimiConnectorURL, @"twoutapis/update_order"];
    [self requestWithMethod:PUT URL:url params:params target:target selector:selector header:nil];
}


@end
