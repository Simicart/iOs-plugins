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
    keyResponse = @"order";
    [self preDoRequest];
    currentNotificationName = DidUseGiftCardCreditOnOrder;
    [[self getAPI] requestWithMethod:PUT URL:[NSString stringWithFormat:@"%@%@giftvouchercheckouts/usecreditcheckout", kBaseURL, kSimiConnectorURL] params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
- (void)useGiftCodeWithParams:(NSDictionary *)params {
    keyResponse = @"order";
    [self preDoRequest];
    currentNotificationName = DidUseGiftCodeOnOrder;
    [[self getAPI] requestWithMethod:PUT URL:[NSString stringWithFormat:@"%@%@giftvouchercheckouts/addcodecheckout", kBaseURL, kSimiConnectorURL] params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}

- (void)updateGiftCodeWithParams: (NSDictionary *)params {
    keyResponse = @"order";
    [self preDoRequest];
    currentNotificationName = DidUpdateGiftCodeOnOrder;
    [[self getAPI] requestWithMethod:PUT URL:[NSString stringWithFormat:@"%@%@giftvouchercheckouts/updategiftcode", kBaseURL, kSimiConnectorURL] params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
- (void)removeGiftCodeWithParams:(NSDictionary *)params {
    keyResponse = @"order";
    [self preDoRequest];
    currentNotificationName = DidRemoveGiftCodeOnOrder;
    [[self getAPI] requestWithMethod:PUT URL:[NSString stringWithFormat:@"%@%@giftvouchercheckouts/removegiftcode", kBaseURL, kSimiConnectorURL] params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
@end
