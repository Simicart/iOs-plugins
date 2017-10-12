//
//  SimiGiftCardModel.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiProductModel.h"
static NSString *const DidGetGiftCardDetail = @"DidGetGiftCardDetail";
static NSString *const DidUploadImage = @"DidUploadImage";

@interface SimiGiftCardModel : SimiProductModel
- (void)getGiftCardWithID:(NSString*)giftcardID params:(NSDictionary*)params;

- (void)uploadImageWithParams:(NSDictionary *)params;
@end
