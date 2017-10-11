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
    notificationName = DidGetCustomerCredit;
    self.parseKey = @"simicustomercredit";
    [self preDoRequest];
    [[SimiGiftCardCreditAPI new]getCustomerCreditWithParams:params target:self selector:@selector(didGetResponseFromNetwork:)];
}

- (void)removeGiftCodeFromCustomerWithParams:(NSDictionary *)params{
    notificationName = DidRemoveGiftCode;
    self.parseKey = @"simicustomercredit";
    [self preDoRequest];
    [[SimiGiftCardCreditAPI new]removeGiftCodeFromCustomerWithParams:params target:self selector:@selector(didGetResponseFromNetwork:)];
}

- (void)redeemGiftCodeWithParams:(NSDictionary *)params{
    notificationName = DidRedeemGiftCode;
    self.parseKey = @"message";
    [self preDoRequest];
    [[SimiGiftCardCreditAPI new]redeemGiftCodeWithParams:params target:self selector:@selector(didGetResponseFromNetwork:)];
}

- (void)addGiftCodeWithParams:(NSDictionary *)params{
    notificationName = DidAddGiftCodeToList;
    self.parseKey = @"message";
    [self preDoRequest];
    [[SimiGiftCardCreditAPI new]addGiftCodeWithParams:params target:self selector:@selector(didGetResponseFromNetwork:)];
}

- (void)sendEmailToFriendWithParams:(NSDictionary *)params{
    notificationName = DidSendGiftCodeToFriend;
    self.parseKey = @"message";
    [self preDoRequest];
    [[SimiGiftCardCreditAPI new]sendEmailToFriendWithParams:params target:self selector:@selector(didGetResponseFromNetwork:)];
}
@end
