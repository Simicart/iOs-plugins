//
//  LoyaltyAPI.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 1/16/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import "LoyaltyAPI.h"

@implementation LoyaltyAPI

- (void)loadProgramOverviewWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    url = [NSString stringWithFormat:@"%@%@simirewardpoints/home", kBaseURL, kSimiConnectorURL];
    [self requestWithMethod:GET URL:url params:params target:target selector:selector header:nil];
}

- (void)loadTransactionWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    url = [NSString stringWithFormat:@"%@%@simirewardpointstransactions", kBaseURL, kSimiConnectorURL];
    [self requestWithMethod:GET URL:url params:params target:target selector:selector header:nil];
}

- (void)spendPointsWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    url = [NSString stringWithFormat:@"%@%@simirewardpoints/spend", kBaseURL,kSimiConnectorURL];
    [self requestWithMethod:PUT URL:url params:params target:target selector:selector header:nil];
}

- (void)saveSettingsWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
     url = [NSString stringWithFormat:@"%@%@simirewardpoints/savesetting", kBaseURL, kSimiConnectorURL];
    [self requestWithMethod:PUT URL:url params:params target:target selector:selector header:nil];
}

@end
