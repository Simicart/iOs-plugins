//
//  SCMyFavouriteModel.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/26/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCMyFavouriteModel.h"

@implementation SCMyFavouriteModel
- (void)getFavouriteDetailWithId:(NSString *)favouriteId{
    notificationName = DidGetFavouriteDetail;
    self.parseKey = @"favourite";
    self.resource = [NSString stringWithFormat:@"favourites/%@",favouriteId];
    self.method = MethodGet;
    [self request];
}
- (void)updateSuggestedQty:(NSString *)qty forItem:(NSDictionary *)item{
    self.resource = @"favourites/items/";
    self.method = MethodPut;
    notificationName = DidUpdateSuggestedQty;
    self.parseKey = @"favourite";
    [self.body addEntriesFromDictionary:@{@"list_id":[item objectForKey:@"list_id"],@"qty":qty,@"item_id":[item objectForKey:@"item_id"]}];
    [self request];
}

- (void)removeHistoryWithId:(NSString *)itemId listId:(NSString *)listId{
    self.resource = @"favourites/items/";
    notificationName = DidRemoveHistoryItem;
    self.parseKey = @"favourite";
    self.method = MethodPut;
    [self.body addEntriesFromDictionary:@{@"list_id":listId,@"qty":@"0",@"item_id":itemId}];
    [self request];
}
- (void)addFolderToCartWithId:(NSString *)folderId{
    self.resource = [NSString stringWithFormat:@"favourites/%@/addtocart",folderId];
    self.parseKey = @"favourite";
    notificationName = DidAddFolderToCart;
    self.method = MethodPut;
    [self request];
}
- (void)addAllItemToCart:(NSString *)listId{
    self.resource = [NSString stringWithFormat:@"favourites/%@",listId];
    self.method = MethodPut;
    notificationName = DidAddAllItemToCart;
    self.parseKey = @"favourite";
    [self request];
}
- (void)updateFavouriteTitle:(NSString *)title listId:(NSString *)listId{
    notificationName = DidUpdateFavouriteTitle;
    self.parseKey = @"favourite";
    self.resource = [NSString stringWithFormat:@"favourites/%@/",listId];
    self.method = MethodPut;
    [self.body addEntriesFromDictionary:@{@"title":title}];
    [self request];
}

@end

