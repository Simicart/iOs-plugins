//
//  SimiStoreLocatorAPI.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/26/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiStoreLocatorAPI.h"

@implementation SimiStoreLocatorAPI
- (void)getStoreListWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL,@"storelocations"];
    [self requestWithMethod:GET URL:url params:params target:target selector:selector header:nil];
}

@end
