//
//  SCWishlistModelCollection.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 11/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCAppWishlistModelCollection.h"

@implementation SCAppWishlistModelCollection


- (void)getWishlistProducts:(NSInteger)offset limit:(NSInteger)limit sortType:(ProductCollectionSortType)sortType otherParams:(NSDictionary *)otherParams{

    currentNotificationName = @"DidGetWishlist";
    [self preDoRequest];
    modelActionType = ModelActionTypeInsert;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:otherParams];
    [params setValue:[NSString stringWithFormat:@"%ld", (long)offset] forKey:@"offset"];
    [params setValue:[NSString stringWithFormat:@"%ld", (long)limit] forKey:@"limit"];
    [params setValue:[NSString stringWithFormat:@"%ld", (long)sortType] forKey:@"sort_option"];
    
    [(SCAppWishlistAPI *)[self getAppWishlistAPI] getWishlistProductsWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
    
}


- (void)removeProductFromWishlist:(NSString *)itemId otherParams:(NSDictionary *)otherParams
{
    currentNotificationName = @"DidRemoveProductFromWishlist";
    [self preDoRequest];
    modelActionType = ModelActionTypeInsert;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:otherParams];
    [params setValue:itemId forKey:@"wishlist_item_id"];
    
    [(SCAppWishlistAPI *)[self getAppWishlistAPI] removeProductFromWishlistWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)addProductToWishlist:(SimiProductModel*)params otherParams:(NSDictionary *)otherParams
{
    currentNotificationName = @"DidAddProductToWishlist";
    [self preDoRequest];
    modelActionType = ModelActionTypeInsert;
    
    //NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:otherParams];
    //[params setValue:[NSString stringWithFormat:@"%ld", (long)productId] forKey:@"product_id"];
    
    [(SCAppWishlistAPI *)[self getAppWishlistAPI] addProductToWishlistWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}


- (void)getWishlistQty
{
    currentNotificationName = @"DidGetWishlistQty";
    [self preDoRequest];
    modelActionType = ModelActionTypeInsert;
    [(SCAppWishlistAPI *)[self getAppWishlistAPI] getWishlistQty:self selector:@selector(didFinishRequest:responder:)];
}


- (void) addWishlistProductToCart:(NSString *)itemId otherParams:(NSDictionary *)otherParams
{
    currentNotificationName = @"DidAddWishlistProductToCart";
    [self preDoRequest];
    modelActionType = ModelActionTypeInsert;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:otherParams];
    [params setValue:itemId forKey:@"wishlist_item_id"];
    
    [(SCAppWishlistAPI *)[self getAppWishlistAPI] addWishlistProductToCartWithParams:params target:self selector:@selector(didFinishRequest:responder:)];

}




- (SCAppWishlistAPI *)getAppWishlistAPI{
    NSString *className = [self.class description];
    Class api = NSClassFromString([className stringByReplacingOccurrencesOfString:@"ModelCollection" withString:@"API"]);
    SCAppWishlistAPI *simiApi;
    if (api != nil) {
        simiApi = [api new];
    }else{
        simiApi = [[SCAppWishlistAPI alloc] init];
    }
    return simiApi;
}




@end
