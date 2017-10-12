//
//  SimiGiftCardCreditModel.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
static NSString *const DidGetCustomerCredit = @"DidGetCustomerCredit";
static NSString *const DidRemoveGiftCode = @"DidRemoveGiftCode";
static NSString *const DidRedeemGiftCode = @"DidRedeemGiftCode";
static NSString *const DidAddGiftCodeToList = @"DidAddGiftCodeToList";
static NSString *const DidSendGiftCodeToFriend = @"DidSendGiftCodeToFriend";

@interface SimiGiftCardCreditModel : SimiModel
- (void)getCustomerCreditWithParams:(NSDictionary *)params;

- (void)removeGiftCodeFromCustomerWithParams:(NSDictionary *)params;

- (void)redeemGiftCodeWithParams:(NSDictionary *)params;

- (void)addGiftCodeWithParams:(NSDictionary *)params;

- (void)sendEmailToFriendWithParams:(NSDictionary *)params;
@end
