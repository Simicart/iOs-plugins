//
//  SCPWishlistModelCollection.h
//  SimiCartPluginFW
//
//  Created by Liam on 5/8/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiModelCollection.h>
//Notification names
#define DidGetWishlistItems @"DidGetWishlistItems"
#define DidRemoveWishlistItem @"DidRemoveWishlistItem"
@interface SCPWishlistModelCollection : SimiModelCollection
- (void)getWishlistItemsWithParams:(NSDictionary*)params;
- (void)removeItemWithWishlistItemID:(NSString*)wishlistItemID;
@end
