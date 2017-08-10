//
//  SimiGiftCodeModel.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiGiftCodeModel.h"

@implementation SimiGiftCodeModel
- (void)useGiftCodeWithParams:(NSDictionary *)params {
    keyResponse = @"giftcode";
    [self preDoRequest];
    currentNotificationName = DidUseGiftCode;
    [[self getAPI] requestWithMethod:PUT URL:[NSString stringWithFormat:@"%@%@giftvouchercheckouts/usecode", kBaseURL, kSimiConnectorURL] params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
@end
