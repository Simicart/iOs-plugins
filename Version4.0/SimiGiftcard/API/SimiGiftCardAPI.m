//
//  SimiGiftCardAPI.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiGiftCardAPI.h"

@implementation SimiGiftCardAPI
- (void)getGiftCardProductWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *productID = [params valueForKey:@"entity_id"];
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@/%@", kBaseURL, kSimiConnectorURL, @"simigiftcards", productID];
    [self requestWithMethod:GET URL:urlPath params:params target:target selector:selector header:nil];
}

- (void)getGiftCardProductCollectionWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL, @"simigiftcards"];
    [self requestWithMethod:GET URL:urlPath params:params target:target selector:selector header:nil];
}

@end
