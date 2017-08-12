//
//  SimiCartModelCollection+GiftCard.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/10/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiCartModelCollection+GiftCard.h"

@implementation SimiCartModelCollection (GiftCard)
- (void)useGiftCardCreditWithParams:(NSDictionary *)params {
    keyResponse = @"quoteitems";
    [self preDoRequest];
    currentNotificationName = DidUseGiftCardCreditOnCart;
    [[self getAPI] requestWithMethod:PUT URL:[NSString stringWithFormat:@"%@%@giftvouchercheckouts/usecredit", kBaseURL, kSimiConnectorURL] params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
- (void)useGiftCodeWithParams:(NSDictionary *)params {
    keyResponse = @"quoteitems";
    [self preDoRequest];
    currentNotificationName = DidUseGiftCodeOnCart;
    [[self getAPI] requestWithMethod:PUT URL:[NSString stringWithFormat:@"%@%@giftvouchercheckouts/usecode", kBaseURL, kSimiConnectorURL] params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}

- (void)updateGiftCodeWithParams: (NSDictionary *)params {
    keyResponse = @"quoteitems";
    [self preDoRequest];
    currentNotificationName = DidUpdateGiftCodeOnCart;
    [[self getAPI] requestWithMethod:PUT URL:[NSString stringWithFormat:@"%@%@giftvouchercheckouts/updatecode", kBaseURL, kSimiConnectorURL] params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
- (void)removeGiftCodeWithParams:(NSDictionary *)params {
    keyResponse = @"quoteitems";
    [self preDoRequest];
    currentNotificationName = DidRemoveGiftCodeOnCart;
     [[self getAPI] requestWithMethod:PUT URL:[NSString stringWithFormat:@"%@%@giftvouchercheckouts/remove", kBaseURL, kSimiConnectorURL] params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}

@end
