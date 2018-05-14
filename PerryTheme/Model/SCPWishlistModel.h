//
//  SCPWishlistModel.h
//  SimiCartPluginFW
//
//  Created by Liam on 5/8/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiModel.h>
#define DidAddProductToWishList @"DidAddProductToWishList"
@interface SCPWishlistModel : SimiModel
- (void)addProductWithParams:(NSDictionary *)params;
@property (strong, nonatomic) NSString *wishlistItemId;
@property (strong, nonatomic) NSString *wishlistId;
@property (strong, nonatomic) NSString *productId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *qty;
@property (strong, nonatomic) NSString *productSKU;
@property (strong, nonatomic) NSString *productSharingMessage;
@property (strong, nonatomic) NSString *productSharingUrl;
@property (strong, nonatomic) NSString *productImage;
@property (nonatomic) BOOL selectedAllRequiredOptions;
@property (nonatomic) BOOL stockStatus;
@end
