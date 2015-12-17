//
//  KlarnaAPI.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "KlarnaAPI.h"
NSString *const kSimiGetParamsKlarna = @"simiklarna/api/get_params";
NSString *const kSimiCheckoutWithKlarna = @"simiklarna/api/push";
@implementation KlarnaAPI
- (void)getParamsKlarnaWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiGetParamsKlarna];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}
- (void)checkoutKlarnaWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiCheckoutWithKlarna];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}
@end
