//
//  SimiGiftCardCreditAPI.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiGiftCardCreditAPI.h"

@implementation SimiGiftCardCreditAPI
- (void)getCustomerCreditWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL, @"simicustomercredits/self"];
    [self requestWithMethod:GET URL:urlPath params:params target:target selector:selector header:nil];
}

- (void)removeGiftCodeFromCustomerWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@/%@", kBaseURL, kSimiConnectorURL, @"simicustomercredits/self",[params valueForKey:@"id"]];
    [self requestWithMethod:DELETE URL:urlPath params:nil target:target selector:selector header:nil];
}

- (void)redeemGiftCodeWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL, @"simicustomercredits/addredeem"];
    [self requestWithMethod:PUT URL:urlPath params:params target:target selector:selector header:nil];
}

- (void)addGiftCodeWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL, @"simicustomercredits/addlist"];
    [self requestWithMethod:PUT URL:urlPath params:params target:target selector:selector header:nil];
}

- (void)sendEmailToFriendWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL, @"simicustomercredits/sendemail"];
    [self requestWithMethod:PUT URL:urlPath params:params target:target selector:selector header:nil];
}
@end
