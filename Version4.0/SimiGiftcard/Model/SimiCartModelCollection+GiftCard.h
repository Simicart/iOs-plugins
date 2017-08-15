//
//  SimiCartModelCollection+GiftCard.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/10/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

#define DidUseGiftCardCreditOnCart @"DidUseGiftCardCreditOnCart"
#define DidUseGiftCodeOnCart @"DidUseGiftCodeOnCart"
#define DidUpdateGiftCodeOnCart @"DidUpdateGiftCodeOnCart"
#define DidRemoveGiftCodeOnCart @"DidRemoveGiftCodeOnCart"

@interface SimiCartModelCollection (GiftCard)
- (void)useGiftCardCreditWithParams: (NSDictionary *)params;
- (void)useGiftCodeWithParams: (NSDictionary *)params;
- (void)updateGiftCodeWithParams: (NSDictionary *)params;
- (void)removeGiftCodeWithParams: (NSDictionary *)params;
@end
