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
    self.parseKey = @"order";
    [self preDoRequest];
    notificationName = DidUseGiftCardCreditOnOrder;
    [[SimiAPI new] requestWithMethod:PUT URL:[NSString stringWithFormat:@"%@%@giftvouchercheckouts/usecreditcheckout", kBaseURL, kSimiConnectorURL] params:params target:self selector:@selector(didGetResponseFromNetwork:) header:nil];
}
- (void)useGiftCodeWithParams:(NSDictionary *)params {
    self.parseKey = @"order";
    [self preDoRequest];
    notificationName = DidUseGiftCodeOnOrder;
    [[SimiAPI new] requestWithMethod:PUT URL:[NSString stringWithFormat:@"%@%@giftvouchercheckouts/addcodecheckout", kBaseURL, kSimiConnectorURL] params:params target:self selector:@selector(didGetResponseFromNetwork:) header:nil];
}

- (void)updateGiftCodeWithParams: (NSDictionary *)params {
    self.parseKey = @"order";
    [self preDoRequest];
    notificationName = DidUpdateGiftCodeOnOrder;
    [[SimiAPI new] requestWithMethod:PUT URL:[NSString stringWithFormat:@"%@%@giftvouchercheckouts/updategiftcode", kBaseURL, kSimiConnectorURL] params:params target:self selector:@selector(didGetResponseFromNetwork:) header:nil];
}
- (void)removeGiftCodeWithParams:(NSDictionary *)params {
    self.parseKey = @"order";
    [self preDoRequest];
    notificationName = DidRemoveGiftCodeOnOrder;
    [[SimiAPI new] requestWithMethod:PUT URL:[NSString stringWithFormat:@"%@%@giftvouchercheckouts/removegiftcode", kBaseURL, kSimiConnectorURL] params:params target:self selector:@selector(didGetResponseFromNetwork:) header:nil];
}
@end
