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
    currentNotificationName = DidGetWishlistItems;
    modelActionType = ModelActionTypeInsert;
    keyResponse = @"wishlistitems";
    NSString* url = [NSString stringWithFormat:@"%@%@",kBaseURL,kGetWishlistItemsURL];
    [[SimiAPI new] requestWithMethod:@"GET" URL:url params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
-(void) getProductDetailWithProductID: (NSString*) productID{
    currentNotificationName = DidGetWishlistProductDetail;
    NSString* url = [NSString stringWithFormat:@"%@%@%@",kBaseURL,kGetWishlistProductDetailURL,productID];
    [[SimiAPI new] requestWithMethod:@"GET" URL:url params:nil target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
-(void) removeItemWithWishlistItemID: (NSString*) wishlistItemID{
    currentNotificationName = DidRemoveWishlistItem;
    keyResponse = @"wishlistitems";
    NSString* url = [NSString stringWithFormat:@"%@%@%@",kBaseURL,kRemoveWishlistItemURL,wishlistItemID];
    [[SimiAPI new] requestWithMethod:@"DELETE" URL:url params:nil target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
-(void) addProductToCartWithWishlistID: (NSString*) wishlistItemID{
    currentNotificationName = DidAddProductFromWishlistToCart;
    keyResponse = @"wishlistitems";
    NSString* url = [NSString stringWithFormat:@"%@%@%@",kBaseURL,kAddProductFromWishlistToCartURL,wishlistItemID];
    NSDictionary* params = @{@"add_to_cart":@"1"};
    [[SimiAPI new] requestWithMethod:@"GET" URL:url params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}

//Override this method for keeping MODELCOLLECTION template of CORE instead of writing this class to MODEL template
-(void) didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder{
    if (responder.simiObjectName) {
        currentNotificationName = responder.simiObjectName;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
    if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
        NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
        switch (modelActionType) {
            case ModelActionTypeInsert:{
                [self addData:[responseObjectData valueForKey:keyResponse]];
            }
                break;
            default:{
                [self setData:[responseObjectData valueForKey:keyResponse]];
            }
                break;
        }
        if ([[responseObjectData valueForKey:@"all_ids"] isKindOfClass:[NSArray class]]) {
            self.ids = [[NSMutableArray alloc]initWithArray:[responseObjectData valueForKey:@"all_ids"]];
        }
        if ([responseObjectData valueForKey:@"total"]) {
            self.total = [NSString stringWithFormat:@"%@",[responseObjectData valueForKey:@"total"]];
        }
        //Add this part for getting sharing Message and URL
        if([responseObjectData objectForKey:@"sharing_url"]){
            self.sharingURL = [NSString stringWithFormat:@"%@",[responseObjectData valueForKey:@"sharing_url"]];
        }
        if([responseObjectData objectForKey:@"message"]){
            self.sharingMessage = [NSString stringWithFormat:@"%@",[[responseObjectData objectForKey:@"message"] objectAtIndex:0]];
        }
        //End
        [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
    }else if (responseObject == nil){
        [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
    }
}

@end
