//
//  SimiGiftCardAPI.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiProductAPI.h"

@interface SimiGiftCardAPI : SimiProductAPI

- (void)getGiftCardProductWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

- (void)getGiftCardProductCollectionWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

- (void)uploadImageWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
