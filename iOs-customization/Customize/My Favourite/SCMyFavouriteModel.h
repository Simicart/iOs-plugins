//
//  SCMyFavouriteModel.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/26/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

#define DidGetFavouriteDetail @"DidGetFavouriteDetail"
#define DidUpdateSuggestedQty @"DidUpdateSuggestedQty"
#define DidAddAllItemToCart @"DidAddAllItemToCart"
#define DidRemoveHistoryItem @"DidRemoveHistoryItem"
#define DidUpdateFavouriteTitle @"DidUpdateFavouriteTitle"
#define DidAddFolderToCart @"DidAddFolderToCart"

@interface SCMyFavouriteModel : SimiModel
- (void)getFavouriteDetailWithId:(NSString *)favouriteId;
- (void)updateSuggestedQty:(NSString *)qty forItem:(NSDictionary *)item;
- (void)addAllItemToCart:(NSString *)listId;
- (void)removeHistoryWithId:(NSString *)itemId listId:(NSString *)listId;
- (void)updateFavouriteTitle:(NSString *)title listId:(NSString *)listId;
- (void)addFolderToCartWithId:(NSString *)folderId;
@end

