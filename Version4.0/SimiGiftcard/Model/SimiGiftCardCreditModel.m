//
//  SimiGiftCardCreditModel.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiGiftCardCreditModel.h"

@implementation SimiGiftCardCreditModel
- (void)useGiftCardCreditWithParams:(NSDictionary *)params {
    keyResponse = @"gift_card";
    [self preDoRequest];
    currentNotificationName = DidUseGiftCard;
    [[self getAPI] requestWithMethod:PUT URL:[NSString stringWithFormat:@"%@%@giftvouchercheckouts/usecredit", kBaseURL, kSimiConnectorURL] params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
@end
