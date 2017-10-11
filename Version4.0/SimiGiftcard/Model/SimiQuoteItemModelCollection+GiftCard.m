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
    self.parseKey = @"quoteitems";
    [self preDoRequest];
    notificationName = DidUseGiftCardCreditOnCart;
    [[SimiAPI new] requestWithMethod:PUT URL:[NSString stringWithFormat:@"%@%@giftvouchercheckouts/usecredit", kBaseURL, kSimiConnectorURL] params:params target:self selector:@selector(didGetResponseFromNetwork:) header:nil];
}
- (void)useGiftCodeWithParams:(NSDictionary *)params {
    self.parseKey = @"quoteitems";
    [self preDoRequest];
    notificationName = DidUseGiftCodeOnCart;
    [[SimiAPI new] requestWithMethod:PUT URL:[NSString stringWithFormat:@"%@%@giftvouchercheckouts/usecode", kBaseURL, kSimiConnectorURL] params:params target:self selector:@selector(didGetResponseFromNetwork:) header:nil];
}

- (void)updateGiftCodeWithParams: (NSDictionary *)params {
    self.parseKey = @"quoteitems";
    [self preDoRequest];
    notificationName = DidUpdateGiftCodeOnCart;
    [[SimiAPI new] requestWithMethod:PUT URL:[NSString stringWithFormat:@"%@%@giftvouchercheckouts/updatecode", kBaseURL, kSimiConnectorURL] params:params target:self selector:@selector(didGetResponseFromNetwork:) header:nil];
}
- (void)removeGiftCodeWithParams:(NSDictionary *)params {
    self.parseKey = @"quoteitems";
    [self preDoRequest];
    notificationName = DidRemoveGiftCodeOnCart;
     [[SimiAPI new] requestWithMethod:PUT URL:[NSString stringWithFormat:@"%@%@giftvouchercheckouts/remove", kBaseURL, kSimiConnectorURL] params:params target:self selector:@selector(didGetResponseFromNetwork:) header:nil];
}

@end
