//
//  SCWishlistModel.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/26/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

#define DidAddProductToWishList @"DidAddProductToWishList"

@interface SCWishlistModel : SimiModel
-(void) addProductWithParams: (NSDictionary*) params;

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
