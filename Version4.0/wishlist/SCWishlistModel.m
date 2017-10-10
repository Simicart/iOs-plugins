//
//  SCWishlistModel.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/26/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCWishlistModel.h"

#define kAddProductToWishlistURL @"simiconnector/rest/v2/wishlistitems"

@implementation SCWishlistModel

- (void)parseData {
    [super parseData];
    self.wishlistItemId = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"wishlist_item_id"]];
    self.wishlistId = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"wishlist_id"]];
    self.productId = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"product_id"]];
    self.name = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"name"]];
    self.price = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"price"]];
    self.qty = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"qty"]];
    self.productSKU = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"product_sku"]];
    self.productSharingMessage = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"product_sharing_message"]];
    self.productSharingUrl = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"product_sharing_url"]];
    self.productImage = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"product_image"]];
    self.selectedAllRequiredOptions = [[self.modelData objectForKey:@"selected_all_required_options"] boolValue];
    self.stockStatus = [[self.modelData objectForKey:@"stock_status"] boolValue];
}

-(void) addProductWithParams:(NSDictionary *)params{
    notificationName = DidAddProductToWishList;
    self.parseKey = @"wishlistitem";
    NSMutableDictionary *currentParams = [[NSMutableDictionary alloc]initWithDictionary:params];
    if (![SimiGlobalVar sharedInstance].isLogin) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *quoteID = @"";
        if ([userDefaults objectForKey:@"simi_quote_id"]) {
            quoteID = [userDefaults objectForKey:@"simi_quote_id"];
            if (![quoteID isEqualToString:@""] && quoteID != nil) {
                [currentParams setValue:quoteID forKey:@"quote_id"];
            }
        }
    }
    NSString* url = [NSString stringWithFormat:@"%@%@",kBaseURL,kAddProductToWishlistURL];
    [[SimiAPI new] requestWithMethod:POST URL:url params:currentParams target:self selector:@selector(didGetResponseFromNetwork:) header:nil];
}
@end
