//
//  SCWishlistModelCollection.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 11/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiProductModel.h>
#import <SimiCartBundle/SimiProductModelCollection.h>
#import <SimiCartBundle/SimiProductAPI.h>
#import "SCAppWishlistAPI.h"

@interface SCAppWishlistModelCollection: SimiProductModelCollection

/*
 Notification name: DidGetWishlist
 */
- (void)getWishlistProducts:(NSInteger)offset limit:(NSInteger)limit sortType:(ProductCollectionSortType)sortType otherParams:(NSDictionary *)otherParams;

/*
 Notification name: DidRemoveProductFromWishlist
 */
- (void)removeProductFromWishlist:(NSString *)itemId otherParams:(NSDictionary *)otherParams;

/*
 Notification name: DidAddProductToWishlist
 */
- (void)addProductToWishlist:(SimiProductModel*)params otherParams:(NSDictionary *)otherParams;

/*
 Notification name: DidGetWishlistQty
 */
- (void)getWishlistQty ;

/*
 Notification name: DidAddWishlistProductToCart
 */
- (void)addWishlistProductToCart:(NSString *)itemId otherParams:(NSDictionary *)otherParams;





- (SCAppWishlistAPI *)getAppWishlistAPI;

@end
