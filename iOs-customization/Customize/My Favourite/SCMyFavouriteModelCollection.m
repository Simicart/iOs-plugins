//
//  SCMyFavouriteModelCollection.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/26/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCMyFavouriteModelCollection.h"

@implementation SCMyFavouriteModelCollection
- (void)getMyFavouriteCollection{
    notificationName = DidGetMyFavouriteCollection;
    self.parseKey = @"favourites";
    self.resource = @"favourites";
    self.method = MethodGet;
    [self request];
}

- (void)setFavouriteDefaultWithId:(NSString *)favouriteId{
    notificationName = DidMakeFavouriteDefault;
    self.parseKey = @"favourites";
    self.resource = [NSString stringWithFormat:@"favourites/%@/default",favouriteId];
    self.method = MethodPut;
    [self request];
    [self preDoRequest];
}
- (void)removeFavouriteWithId:(NSString *)favouriteId{
    notificationName = DidRemoveFavourite;
    self.parseKey = @"favourites";
    self.resource = [NSString stringWithFormat:@"favourites/%@/favourite",favouriteId];
    self.method = MethodDelete;
    [self request];
}
- (void)addProductToFavourite:(NSDictionary *)params{
    notificationName = DidAddProductToFavourite;
    self.parseKey = @"favourites";
    self.method = MethodPost;
    [self.body addEntriesFromDictionary:params];
    self.resource = @"favourites/items";
    [self request];
}

- (void)addNewFolder:(NSString *)name{
    notificationName = DidAddNewFolder;
    self.parseKey = @"favourites";
    self.method = MethodPost;
    self.resource = @"favourites";
    [self.body addEntriesFromDictionary:@{@"title":name}];
    [self request];
}


@end

