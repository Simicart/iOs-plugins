//
//  SCAppWishlist.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 11/10/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimiCartBundle/SimiProductModel.h>
#import "SCAppWishlistModelCollection.h"
#import <SimiCartBundle/SCMoreViewController.h>
#import <SimiCartBundle/SimiSection.h>
#import "SCLeftMenuView.h"
#import <SimiCartBundle/SCProductViewController.h>
#import <SimiCartBundle/SCAccountViewController.h>

static NSString * MY_WISHLIST_ROW    = @"mywishlist";

@interface SCAppWishlist : NSObject <UIPopoverControllerDelegate>

#pragma mark flags

@property (nonatomic) BOOL addorremoveprocessing;
@property (nonatomic) BOOL reloadAddToWishlistIcon;
@property (nonatomic) BOOL updateProductViewControllerWhileAppears;

#pragma mark wishlist item info

@property (strong, nonatomic) NSNumber * wishlistItemsQty;
@property (strong, nonatomic) NSString * currentProductIdOnWishlist;

#pragma mark productViewController properties

@property (strong, nonatomic) SimiProductModel *product;

@property (strong, nonatomic) SCProductViewController *productViewController;
@property (strong, nonatomic) SCProductViewController *CurrentProductViewController;

#pragma mark -
#pragma mark property for inside using

@property (strong, nonatomic) UIImageView * imageView;
@property (strong, nonatomic) SCAppWishlistModelCollection *wishlistProductCollection;
@property (strong, nonatomic) NSString *imageUrl;



@property (strong, nonatomic) SCMoreViewController * moreViewController;
@property (strong, nonatomic) SimiRow *myWishlistRow;
@property (strong, nonatomic) SCLeftMenuView *leftMenuView;


@property (strong, nonatomic) SCAccountViewController *accountViewController;

#pragma mark - 
#pragma mark add to wishlist button

@property (strong, nonatomic) UIButton * addToWishlistButton;
@property (strong, nonatomic) UIButton * currentAddToWishlistButton;

#pragma mark button images

@property (strong, nonatomic) UIImage * notAddedYetButtonImage;
@property (strong, nonatomic) UIImage * addedByNowButtonImage;
@property (strong, nonatomic) UIImage * addOrRemoveProcessingButtonImage;

#pragma mark button

@property (strong, nonatomic) UIButton *addToWishlistButtonFrame;


#pragma mark functions

-(IBAction) addToWishList:(id)sender;
-(IBAction) removeFromWishlist:(id)sender;
-(UIButton *)addAddToWishlistButtonToProductView:(UIImageView*)inputImageView :(SimiProductModel *) inputProduct;

+(UIImage *)imageWithName:(NSString *)name withColor:(UIColor *)color;
+(UIColor *)lighterColorForColor:(UIColor *)c;




@end
