//
//  SimiGiftCardCreditModel.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

#define DidUseGiftCard @"DidUseGiftCard"

@interface SimiGiftCardCreditModel : SimiModel
- (void)useGiftCardCreditWithParams: (NSDictionary *)params;
@end
