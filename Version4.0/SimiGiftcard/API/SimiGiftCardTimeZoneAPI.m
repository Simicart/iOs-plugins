//
//  SimiGiftCardTimeZoneAPI.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/11/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiGiftCardTimeZoneAPI.h"

@implementation SimiGiftCardTimeZoneAPI
- (void)getGiftCardTimeZoneWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL, @"simitimezones"];
    [self requestWithMethod:GET URL:urlPath params:params target:target selector:selector header:nil];
}
@end
