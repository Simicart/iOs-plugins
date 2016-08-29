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
@end
