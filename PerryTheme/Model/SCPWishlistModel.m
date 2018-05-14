//
//  SCPWishlistModel.m
//  SimiCartPluginFW
//
//  Created by Liam on 5/8/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPWishlistModel.h"

@implementation SCPWishlistModel
- (void)parseData{
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

- (void)addProductWithParams:(NSDictionary *)params{
    notificationName = DidAddProductToWishList;
    self.parseKey = @"wishlistitem";
    self.resource = @"wishlistitems";
    if (params.count > 0) {
        [self.body addEntriesFromDictionary:params];
    }
    self.method = MethodPost;
    [self request];
}
@end
