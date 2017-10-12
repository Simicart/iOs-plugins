//
//  SimiCartModelCollection+GiftCard.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/10/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

static NSString *const DidUseGiftCardCreditOnCart = @"DidUseGiftCardCreditOnCart";
static NSString *const DidUseGiftCodeOnCart = @"DidUseGiftCodeOnCart";
static NSString *const DidUpdateGiftCodeOnCart = @"DidUpdateGiftCodeOnCart";
static NSString *const DidRemoveGiftCodeOnCart = @"DidRemoveGiftCodeOnCart";

@interface SimiQuoteItemModelCollection (GiftCard)
- (void)useGiftCardCreditWithParams:(NSDictionary*)params;
- (void)useGiftCodeWithParams:(NSDictionary*)params;
- (void)updateGiftCodeWithParams:(NSDictionary*)params;
- (void)removeGiftCodeWithParams:(NSDictionary*)params;
@end
