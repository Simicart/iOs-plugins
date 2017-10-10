//
//  SCWishlistModelCollection.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/25/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCWishlistModelCollection.h"

//API URLs
#define kGetWishlistItemsURL @"simiconnector/rest/v2/wishlistitems"
#define kGetWishlistProductDetailURL @"simiconnector/rest/v2/products/"
#define kRemoveWishlistItemURL @"simiconnector/rest/v2/wishlistitems/"
#define kAddProductFromWishlistToCartURL @"simiconnector/rest/v2/wishlistitems/"

@implementation SCWishlistModelCollection

-(void) getWishlistItemsWithParams: (NSDictionary*) params{
    notificationName = DidGetWishlistItems;
    actionType = CollectionActionTypeInsert;
    self.parseKey = @"wishlistitems";
    NSString* url = [NSString stringWithFormat:@"%@%@",kBaseURL,kGetWishlistItemsURL];
    [[SimiAPI new] requestWithMethod:GET URL:url params:params target:self selector:@selector(didGetResponseFromNetwork:) header:nil];
}
-(void) removeItemWithWishlistItemID: (NSString*) wishlistItemID{
    notificationName = DidRemoveWishlistItem;
    self.parseKey = @"wishlistitems";
    actionType = CollectionActionTypeGet;
    NSString* url = [NSString stringWithFormat:@"%@%@%@",kBaseURL,kRemoveWishlistItemURL,wishlistItemID];
    [[SimiAPI new] requestWithMethod:DELETE URL:url params:nil target:self selector:@selector(didGetResponseFromNetwork:) header:nil];
}
-(void) addProductToCartWithWishlistID: (NSString*) wishlistItemID{
    notificationName = DidAddProductFromWishlistToCart;
    self.parseKey = @"wishlistitems";
    actionType = CollectionActionTypeGet;
    NSString* url = [NSString stringWithFormat:@"%@%@%@",kBaseURL,kAddProductFromWishlistToCartURL,wishlistItemID];
    NSDictionary* params = @{@"add_to_cart":@"1"};
    [[SimiAPI new] requestWithMethod:GET URL:url params:params target:self selector:@selector(didGetResponseFromNetwork:) header:nil];
}

@end
