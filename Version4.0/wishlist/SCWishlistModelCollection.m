//
//  SCWishlistModelCollection.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/25/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCWishlistModelCollection.h"

@implementation SCWishlistModelCollection

- (void)parseData{
    [super parseData];
    if([[self.data objectForKey:@"message"] isKindOfClass:[NSArray class]]){
        NSArray *sharingMessages = [self.data objectForKey:@"message"];
        if(sharingMessages.count > 0){
            self.sharingMessage = [NSString stringWithFormat:@"%@",[sharingMessages objectAtIndex:0]];
        }
    }
    if([[self.data objectForKey:@"sharing_url"] isKindOfClass:[NSArray class]]){
        NSArray *sharingURLs = [self.data objectForKey:@"sharing_url"];
        if(sharingURLs.count > 0){
            self.sharingURL = [NSString stringWithFormat:@"%@",[sharingURLs objectAtIndex:0]];
        }
    }
}

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
- (void)addProductToCartWithWishlistID:(NSString*)wishlistItemID{
    notificationName = DidAddProductFromWishlistToCart;
    actionType = CollectionActionTypeGet;
    self.parseKey = @"wishlistitems";
    self.resource = @"wishlistitems";
    [self addExtendsUrlWithKey:wishlistItemID];
    [self addParamsWithKey:@"add_to_cart" value:@"1"];
    self.method = MethodGet;
    [self request];
}

@end
