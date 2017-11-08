//
//  SimiGiftCardModel.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiProductModel.h>
static NSString *DidGetGiftCardDetail = @"DidGetGiftCardDetail";
static NSString *DidUploadImage = @"DidUploadImage";

@interface SimiGiftCardModel : SimiProductModel
- (void)getGiftCardWithID:(NSString*)giftcardID params:(NSDictionary*)params;

- (void)uploadImageWithParams:(NSDictionary *)params;
@end
