//
//  SCPWishlistModelCollection.m
//  SimiCartPluginFW
//
//  Created by Liam on 5/8/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPWishlistModelCollection.h"

@implementation SCPWishlistModelCollection
- (void)getWishlistItemsWithParams:(NSDictionary*)params{
    notificationName = DidGetWishlistItems;
    actionType = CollectionActionTypeInsert;
    self.parseKey = @"wishlistitems";
    self.resource = @"wishlistitems";
    if (params.count > 0) {
        [self.params addEntriesFromDictionary:params];
    }
    self.method = MethodGet;
    [self request];
}
- (void)removeItemWithWishlistItemID:(NSString*)wishlistItemID{
    notificationName = DidRemoveWishlistItem;
    actionType = CollectionActionTypeGet;
    self.parseKey = @"wishlistitems";
    self.resource = @"wishlistitems";
    [self addExtendsUrlWithKey:wishlistItemID];
    self.method = MethodDelete;
    [self request];
}
@end
