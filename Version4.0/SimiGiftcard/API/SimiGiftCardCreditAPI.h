//
//  SimiGiftCardCreditAPI.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SimiGiftCardCreditAPI : SimiAPI
- (void)getCustomerCreditWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
- (void)removeGiftCodeFromCustomerWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
- (void)redeemGiftCodeWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
- (void)addGiftCodeWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
- (void)sendEmailToFriendWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

@end
