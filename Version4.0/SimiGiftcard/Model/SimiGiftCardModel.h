//
//  SimiGiftCardModel.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiProductModel.h"
static NSString *DidGetGiftCardDetail = @"DidGetGiftCardDetail";
@interface SimiGiftCardModel : SimiProductModel
- (void)getGiftCardWithID:(NSString*)giftcardID params:(NSDictionary*)params;
@end
