//
//  SimiGiftCodeAPI.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiGiftCodeAPI.h"

@implementation SimiGiftCodeAPI
- (void)getGiftCodeDetailWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *giftCodeID = [params valueForKey:@"id"];
    NSMutableDictionary *currentParams = [[NSMutableDictionary alloc]initWithDictionary:params];
    [currentParams removeObjectForKey:@"id"];
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@/%@", kBaseURL, kSimiConnectorURL, @"simigiftcodes", giftCodeID];
    [self requestWithMethod:GET URL:urlPath params:currentParams target:target selector:selector header:nil];
}
@end
