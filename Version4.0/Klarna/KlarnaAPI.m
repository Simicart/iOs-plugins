//
//  KlarnaAPI.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "KlarnaAPI.h"
NSString *const kSimiGetParamsKlarna = @"simiklarnaapis/get_params";
NSString *const kSimiCheckoutWithKlarna = @"simiklarnaapis/push";
@implementation KlarnaAPI
- (void)getParamsKlarnaWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL, kSimiGetParamsKlarna];
    [self requestWithMethod:GET URL:url params:params target:target selector:selector header:nil];
}
- (void)checkoutKlarnaWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL, kSimiCheckoutWithKlarna];
    [self requestWithMethod:GET URL:url params:params target:target selector:selector header:nil];
}
@end
