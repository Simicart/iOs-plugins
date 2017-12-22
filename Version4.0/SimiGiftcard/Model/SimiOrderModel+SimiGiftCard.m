//
//  SimiOrderModel+SimiGiftCard.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/11/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiOrderModel+SimiGiftCard.h"

@implementation SimiOrderModel (SimiGiftCard)
- (void)useGiftCardCreditWithParams:(NSDictionary *)params {
    notificationName = DidUseGiftCardCreditOnOrder;
    self.parseKey = @"order";
    self.resource = @"giftvouchercheckouts/usecreditcheckout";
    self.method = MethodPut;
    if (params.count > 0) {
        [self.body addEntriesFromDictionary:params];
    }
    [self preDoRequest];
    [self request];
}
- (void)useGiftCodeWithParams:(NSDictionary *)params {
    notificationName = DidUseGiftCodeOnOrder;
    self.parseKey = @"order";
    self.resource = @"giftvouchercheckouts/addcodecheckout";
    if (params.count > 0) {
        [self.body addEntriesFromDictionary:params];
    }
    self.method = MethodPut;
    [self preDoRequest];
    [self request];
}

- (void)updateGiftCodeWithParams: (NSDictionary *)params {
    notificationName = DidUseGiftCodeOnOrder;
    self.parseKey = @"order";
    self.resource = @"giftvouchercheckouts/updategiftcode";
    if (params.count > 0) {
        [self.body addEntriesFromDictionary:params];
    }
    self.method = MethodPut;
    [self preDoRequest];
    [self request];
}
- (void)removeGiftCodeWithParams:(NSDictionary *)params {
    notificationName = DidUseGiftCodeOnOrder;
    self.parseKey = @"order";
    self.resource = @"giftvouchercheckouts/removegiftcode";
    if (params.count > 0) {
        [self.body addEntriesFromDictionary:params];
    }
    self.method = MethodPut;
    [self preDoRequest];
    [self request];
}
@end
