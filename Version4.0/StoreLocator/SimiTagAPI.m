//
//  SimiTagAPI.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/27/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiTagAPI.h"
@implementation SimiTagAPI
- (void)getTagListWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL, @"storelocatortags"];
    [self requestWithMethod:GET URL:url params:params target:target selector:selector header:nil];
}
@end
