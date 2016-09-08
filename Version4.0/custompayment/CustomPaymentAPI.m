//
//  CustomPaymentAPI.m
//  SimiCartPluginFW
//
//  Created by Axe on 10/21/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "CustomPaymentAPI.h"

@implementation CustomPaymentAPI

- (void)getCustomPaymentsWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@simicustompayment/api/get_custom_payments", kBaseURL];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}

@end