//
//  SimiGiftCardCreditModel.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiGiftCardCreditModel.h"

@implementation SimiGiftCardCreditModel
- (void)getCustomerCreditWithParams:(NSDictionary *)params{
    notificationName = DidGetCustomerCredit;
    self.parseKey = @"simicustomercredit";
    self.resource = @"simicustomercredits/self";
    if (params.count > 0) {
        [self.params addEntriesFromDictionary:params];
    }
    self.method = MethodGet;
    [self preDoRequest];
    [self request];
}

- (void)removeGiftCodeFromCustomerWithParams:(NSDictionary *)params{
    notificationName = DidRemoveGiftCode;
    self.parseKey = @"simicustomercredit";
    self.resource = @"simicustomercredits/self";
    [self addExtendsUrlWithKey:[params valueForKey:@"id"]];
    self.method = MethodDelete;
    [self preDoRequest];
    [self request];
}

- (void)redeemGiftCodeWithParams:(NSDictionary *)params{
    notificationName = DidRedeemGiftCode;
    self.parseKey = @"message";
    self.resource = @"simicustomercredits/addredeem";
    if (params.count > 0) {
        [self.body addEntriesFromDictionary:params];
    }
    self.method = MethodPut;
    [self preDoRequest];
    [self request];
}

- (void)addGiftCodeWithParams:(NSDictionary *)params{
    notificationName = DidAddGiftCodeToList;
    self.parseKey = @"message";
    self.resource = @"simicustomercredits/addlist";
    if (params.count > 0) {
        [self.body addEntriesFromDictionary:params];
    }
    self.method = MethodPut;
    [self preDoRequest];
    [self request];
}

- (void)sendEmailToFriendWithParams:(NSDictionary *)params{
    notificationName = DidSendGiftCodeToFriend;
    self.parseKey = @"message";
    self.resource = @"simicustomercredits/sendemail";
    if (params.count > 0) {
        [self.body addEntriesFromDictionary:params];
    }
    self.method = MethodPut;
    [self preDoRequest];
    [self request];
}
@end
