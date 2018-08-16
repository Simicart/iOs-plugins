//
//  SCMyFavouriteModelCollection.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/26/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#define DidMakeFavouriteDefault @"DidMakeFavouriteDefault"
#define DidGetMyFavouriteCollection @"DidGetMyFavouriteCollection"
#define DidRemoveFavourite @"DidRemoveFavourite"
#define DidAddProductToFavourite @"DidAddProductToFavourite"
#define DidAddNewFolder @"DidAddNewFolder"

@interface SCMyFavouriteModelCollection : SimiModelCollection
- (void)getMyFavouriteCollection;
- (void)setFavouriteDefaultWithId:(NSString *)favouriteId;
- (void)removeFavouriteWithId:(NSString *)favouriteId;
- (void)addProductToFavourite:(NSDictionary *)params;
- (void)addNewFolder:(NSString *)name;
@end

