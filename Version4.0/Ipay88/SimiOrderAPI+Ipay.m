//
//  SimiOrderAPI+Ipay.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/28/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiOrderAPI+Ipay.h"
#import "SimiGlobalVar+Ipay.h"

@implementation SimiOrderAPI (Ipay)

- (void)updateIpayOrderWithParams:(NSMutableDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiUpdateIpayPayment];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}

@end
