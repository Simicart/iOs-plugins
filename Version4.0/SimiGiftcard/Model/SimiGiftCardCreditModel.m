//
//  SimiGiftCardCreditModel.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiGiftCardCreditModel.h"
#import "SimiGiftCardCreditAPI.h"

@implementation SimiGiftCardCreditModel
- (void)getCustomerCreditWithParams:(NSDictionary *)params{
    currentNotificationName = DidGetCustomerCredit;
    keyResponse = @"simicustomercredit";
    [self preDoRequest];
    [[SimiGiftCardCreditAPI new]getCustomerCreditWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)removeGiftCodeFromCustomerWithParams:(NSDictionary *)params{
    currentNotificationName = DidRemoveGiftCode;
    keyResponse = @"simicustomercredit";
    [self preDoRequest];
    [[SimiGiftCardCreditAPI new]removeGiftCodeFromCustomerWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)redeemGiftCodeWithParams:(NSDictionary *)params{
    currentNotificationName = DidRedeemGiftCode;
    keyResponse = @"message";
    [self preDoRequest];
    [[SimiGiftCardCreditAPI new]redeemGiftCodeWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)addGiftCodeWithParams:(NSDictionary *)params{
    currentNotificationName = DidAddGiftCodeToList;
    keyResponse = @"message";
    [self preDoRequest];
    [[SimiGiftCardCreditAPI new]addGiftCodeWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}
@end
