//
//  SimiGlobalVar+RefineAttributeSets.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 10/31/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//
//


#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiGlobalVar.h>
#import <SimiCartBundle/SCCartViewController.h>
#import "SCAppWishlistViewController.h"
#import "SCAppWishlistModelCollection.h"
#import "AppWishlistiPadViewController.h"

extern AppWishlistiPadViewController * globalAppWishlistiPadViewController;
extern SCAppWishlistViewController * globalAppWishlistViewController;
extern SCCartViewController * globalCartViewController;
extern NSMutableArray * ipadProductDetailsViews;
extern UIImage * addToCartButtonBackgroundImage;
//
////SimiCart Wishlist API
//extern NSString *const kSimiAddProductToWishlist;
//extern NSString *const kSimiGetWishlistProductList;
//extern NSString *const kSimiRemoveProductFromWishlist;





@interface SimiGlobalVar (WishlistVar)


@end