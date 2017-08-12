//
//  SimiGiftCardCreditModel.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
static NSString *DidGetCustomerCredit = @"DidGetCustomerCredit";
static NSString *DidRemoveGiftCode = @"DidRemoveGiftCode";
static NSString *DidRedeemGiftCode = @"DidRedeemGiftCode";
static NSString *DidAddGiftCodeToList = @"DidAddGiftCodeToList";

@interface SimiGiftCardCreditModel : SimiModel
- (void)getCustomerCreditWithParams:(NSDictionary *)params;

- (void)removeGiftCodeFromCustomerWithParams:(NSDictionary *)params;

- (void)redeemGiftCodeWithParams:(NSDictionary *)params;

- (void)addGiftCodeWithParams:(NSDictionary *)params;
@end
