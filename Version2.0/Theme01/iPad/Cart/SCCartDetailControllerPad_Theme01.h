//
//  SCCartDetailControllerPad_Theme01.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/11/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <SimiCartBundle/SimiTableView.h>
#import <SimiCartBundle/SimiCartModelCollection.h>
#import <SimiCartBundle/SimiProductModel.h>
#import "SCCartCellPad_Theme01.h"
#import "SCCartViewController_Theme01.h"

@protocol SCCartDetailControllerPad_Theme01_Delegate <NSObject>

- (void) setCartPrices:(NSMutableArray *)cartPrices isCheckoutable:(BOOL) isCheckout cart:(SimiCartModelCollection *)cart;
- (void)showProductDetail:(NSString*)productID;
@end

@interface SCCartDetailControllerPad_Theme01 : SCCartViewController_Theme01 <SCCartCellPadDelegate_Theme01>
@property (strong, nonatomic) id<SCCartDetailControllerPad_Theme01_Delegate> delegate;

- (void) setCart:(SimiCartModelCollection *)cart_;
- (void)addProductToCart:(NSNotification*)noti;
- (void)clearAllProductsInCart;

@end
