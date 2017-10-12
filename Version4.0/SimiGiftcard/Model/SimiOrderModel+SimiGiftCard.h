//
//  SimiOrderModel+SimiGiftCard.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/11/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiOrderModel.h>

static NSString *const DidUseGiftCardCreditOnOrder = @"DidUseGiftCardCreditOnOrder";
static NSString *const DidUseGiftCodeOnOrder = @"DidUseGiftCodeOnOrder";
static NSString *const DidUpdateGiftCodeOnOrder = @"DidUpdateGiftCodeOnOrder";
static NSString *const DidRemoveGiftCodeOnOrder = @"DidRemoveGiftCodeOnOrder";

@interface SimiOrderModel (SimiGiftCard)
- (void)useGiftCardCreditWithParams: (NSDictionary *)params;
- (void)useGiftCodeWithParams: (NSDictionary *)params;
- (void)updateGiftCodeWithParams: (NSDictionary *)params;
- (void)removeGiftCodeWithParams: (NSDictionary *)params;
@end
