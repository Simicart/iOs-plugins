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
    url = [NSString stringWithFormat:@"%@%@%@/%@", kBaseURL, kSimiConnectorURL, @"simigiftcards", productID];
    [self requestWithMethod:GET URL:url params:params target:target selector:selector header:nil];
}

- (void)getGiftCardProductCollectionWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL, @"simigiftcards"];
    [self requestWithMethod:GET URL:url params:params target:target selector:selector header:nil];
}

- (void)uploadImageWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL, @"simigiftcards/uploadimage"];
    [self requestWithMethod:POST URL:url params:nil uploadDataParams:[params valueForKey:@"image_content"] uploadKey:@"image" uploadFileName:@"image_name.png" target:target selector:selector header:nil];
}

@end
