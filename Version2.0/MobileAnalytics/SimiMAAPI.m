//
//  SimiMAAPI.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/6/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiMAAPI.h"
#import "SimiGlobalVar+MobileAnalytics.h"
@implementation SimiMAAPI
- (void)getGoogleAnalyticsIDWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiMobileAnalyticsGetGoogleID];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}
@end
