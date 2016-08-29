//
//  SCWishlistModelCollection.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/25/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimiCartBundle/SimiModelCollection.h>

//Notification names
#define DidGetWishlistItems @"DidGetWishlistItems"
#define DidGetWishlistProductDetail @"DidGetWishlistProductDetail"
#define DidRemoveWishlistItem @"DidRemoveWishlistItem"
#define DidAddProductFromWishlistToCart @"DidAddProductFromWishlistToCart"

@interface SCWishlistModelCollection : SimiModelCollection

@property (strong, nonatomic) NSString* sharingURL;
@property (strong, nonatomic) NSString* sharingMessage;
-(void) getWishlistItems;
-(void) getProductDetailWithProductID: (NSString*) productID;
-(void) removeItemWithWishlistItemID: (NSString*) wishlistItemID;
-(void) addProductToCartWithWishlistID: (NSString*) wishlistItemID;
@end
