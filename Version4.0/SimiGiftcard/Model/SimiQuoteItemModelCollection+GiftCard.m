//
//  SimiCartModelCollection+GiftCard.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/10/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiQuoteItemModelCollection+GiftCard.h"

@implementation SimiQuoteItemModelCollection (GiftCard)
- (void)useGiftCardCreditWithParams:(NSDictionary *)params {
    notificationName = DidUseGiftCardCreditOnCart;
    self.parseKey = @"quoteitems";
    self.resource = @"giftvouchercheckouts/usecredit";
    if (params.count > 0) {
        [self.body addEntriesFromDictionary:params];
    }
    self.method = MethodPut;
    [self preDoRequest];
    [self request];
}
- (void)useGiftCodeWithParams:(NSDictionary *)params {
    notificationName = DidUseGiftCodeOnCart;
    self.parseKey = @"quoteitems";
    self.resource = @"giftvouchercheckouts/usecode";
    if (params.count > 0) {
        [self.body addEntriesFromDictionary:params];
    }
    self.method = MethodPut;
    [self preDoRequest];
    [self request];
}

- (void)updateGiftCodeWithParams: (NSDictionary *)params {
    notificationName = DidUpdateGiftCodeOnCart;
    self.parseKey = @"quoteitems";
    self.resource = @"giftvouchercheckouts/updatecode";
    if (params.count > 0) {
        [self.body addEntriesFromDictionary:params];
    }
    self.method = MethodPut;
    [self preDoRequest];
    [self request];
}
- (void)removeGiftCodeWithParams:(NSDictionary *)params {
    notificationName = DidRemoveGiftCodeOnCart;
    self.parseKey = @"quoteitems";
    self.resource = @"giftvouchercheckouts/remove";
    if (params.count > 0) {
        [self.body addEntriesFromDictionary:params];
    }
    self.method = MethodPut;
    [self preDoRequest];
    [self request];
}

@end
