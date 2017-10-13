//
//  SimiGiftCardModelCollection.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiProductModelCollection.h"
static NSString *const DidGetGiftCardProductCollection = @"DidGetGiftCardProductCollection";
@interface SimiGiftCardModelCollection : SimiProductModelCollection
- (void)getGiftCardProductCollectionWithParams:(NSDictionary *)params;
@end
