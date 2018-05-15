//
//  SCPProductCollectionViewCell.m
//  SimiCartPluginFW
//
//  Created by Liam on 4/27/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPProductCollectionViewCell.h"
#import "SCPGlobalVars.h"
#import "SCPPriceView.h"
#import "SCPWishlistModel.h"
#import "SCPWishlistModelCollection.h"

@implementation SCPProductCollectionViewCell
- (void)createCellViewWithFrame:(CGRect)frame{
    if (PHONEDEVICE && CGRectGetWidth(frame) > (SCREEN_WIDTH/2)) {
        self.onListMode = YES;
    }
    [super createCellViewWithFrame:frame];
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
}

- (void)createProductImageView{
    self.imageProduct = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imageSize, imageSize)];
    self.imageProduct.contentMode = UIViewContentModeScaleAspectFill;
    self.imageProduct.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
    [self.contentView addSubview:self.imageProduct];
    self.imageProduct.clipsToBounds = YES;
    
    self.imageStockStatus = [[UIImageView alloc]initWithFrame:self.imageProduct.bounds];
    [self.imageStockStatus setBackgroundColor:COLOR_WITH_HEX(@"#919191")];
    [self.imageStockStatus setAlpha:0.7];
    
    
    self.lblStockStatus = [[SimiLabel alloc]initWithFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_MEDIUM andTextColor:[UIColor whiteColor]];
    if (self.onListMode) {
        [self.lblStockStatus setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:FONT_SIZE_LARGE]];
    }
    self.lblStockStatus.adjustsFontSizeToFitWidth = YES;
    [self.lblStockStatus setText:[SCLocalizedString(@"Out of stock") uppercaseString]];
    [self.lblStockStatus setFrame:CGRectMake(0,(imageSize - 30)/2,imageSize,30)];
    [self.lblStockStatus setTextAlignment:NSTextAlignmentCenter];
    [self.imageProduct addSubview:self.imageStockStatus];
    [self.imageStockStatus addSubview:self.lblStockStatus];
    [self.imageStockStatus setHidden:YES];
    [self.lblStockStatus setHidden:YES];
    heightCell += imageSize + 5;
    
    
}

- (void)createProductNameLabel{
    self.lblNameProduct = [[SimiLabel alloc]initWithFrame:CGRectMake(SCP_GLOBALVARS.textPadding, heightCell, imageSize - SCP_GLOBALVARS.textPadding *2, 20) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_MEDIUM];
    if (self.onListMode) {
        self.lblNameProduct  = [[SimiLabel alloc]initWithFrame:CGRectMake(SCP_GLOBALVARS.textPadding*2, heightCell, imageSize - SCP_GLOBALVARS.textPadding *4, 20) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_LARGE];
    }
    [self.lblNameProduct setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:self.lblNameProduct];
    heightCell += 25;
}

- (void)createPriceView{
    float wishlistIconSize = 0;
    float padding = SCP_GLOBALVARS.textPadding;
    if (self.onListMode) {
        padding = padding*2;
    }
    if (SCP_GLOBALVARS.wishlistPluginAllow) {
        wishlistIconSize = 30;
        if (self.onListMode) {
            wishlistIconSize = 40;
        }
        self.addWishlistButton = [[UIButton alloc]initWithFrame:CGRectMake(imageSize - wishlistIconSize - padding, heightCell, wishlistIconSize, wishlistIconSize)];
        [self.addWishlistButton setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 10, 5)];
        [self.addWishlistButton setImage:[UIImage imageNamed:@"wishlist_color_icon"] forState:UIControlStateNormal];
        [self.addWishlistButton addTarget:self action:@selector(updateWishlist:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.addWishlistButton];
    }
    if (wishlistIconSize > 0) {
        wishlistIconSize += padding;
    }
    self.priceView = [[SCPPriceView alloc]initWithFrame:CGRectMake(padding, heightCell, imageSize - padding - wishlistIconSize, 20)];
    [self.contentView addSubview:self.priceView];
}

- (void)setProductModelForCell:(SimiProductModel *)productModel{
    if (![self.productModel isEqual:productModel]) {
        self.productModel = productModel;
        if (self.productModel.images.count > 0) {
            NSArray *images = self.productModel.images;
            if (images.count > 0) {
                NSDictionary *image = [images objectAtIndex:0];
                [self.imageProduct sd_setImageWithURL:[NSURL URLWithString:[image valueForKey:@"url"]]placeholderImage:[UIImage imageNamed:@"logo"]];
            }
        }
        if (self.productModel.name) {
            [self.lblNameProduct setText:self.productModel.name];
        }
        if (!self.productModel.isSalable) {
            [self.imageStockStatus setHidden:NO];
            [self.lblStockStatus setHidden:NO];
        }else{
            [self.imageStockStatus setHidden:YES];
            [self.lblStockStatus setHidden:YES];
        }
        float priceFontSize = FONT_SIZE_LARGE;
        if (self.onListMode) {
            priceFontSize = FONT_SIZE_HEADER;
        }
        [(SCPPriceView*)self.priceView showPriceWithProduct:self.productModel widthView:CGRectGetWidth(self.priceView.frame) fontSize:priceFontSize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidDrawProductImageView" object:self.imageProduct userInfo:@{@"imageView": self.imageProduct, @"product": self.productModel}];
        if (SCP_GLOBALVARS.wishlistPluginAllow) {
            [self updateWishlistIcon];
        }
    }
}

- (void)updateWishlist:(UIButton*)sender{
    if (!GLOBALVAR.isLogin) {
        [SimiGlobalFunction showAlertWithTitle:@"" message:@"Please login before use this feature"];
        return;
    }
    sender.enabled = NO;
    SCPWishlistModel *wishlistModel = [self getWishListModel:self.productModel];
    if (wishlistModel != nil) {
        
    }else{
        SCPWishlistModel *wishlistModel = [SCPWishlistModel new];
        [wishlistModel addProductWithParams:@{@"product":self.productModel.entityId}];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didAddProductToWishlist:) name:DidAddProductToWishList object:wishlistModel];
    }
}

- (SCPWishlistModel*)getWishListModel:(SimiProductModel*)productModel{
    for (SCPWishlistModel *wishListModel in SCP_GLOBALVARS.wishListModelCollection.collectionData) {
        if ([wishListModel.productId isEqualToString:productModel.entityId]) {
            return wishListModel;
        }
    }
    return nil;
}

- (void)didAddProductToWishlist:(NSNotification*)noti{
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        SCPWishlistModel *wishListModel = noti.object;
        [SCP_GLOBALVARS.wishListModelCollection addObject:wishListModel];
    }
    [self updateWishlistIcon];
    [self.addWishlistButton setEnabled:YES];
}

- (void)updateWishlistIcon{
    SCPWishlistModel *wishlistModel = [self getWishListModel:self.productModel];
    if (wishlistModel != nil) {
        [self.addWishlistButton setImage:[UIImage imageNamed:@"wishlist_color_icon"] forState:UIControlStateNormal];
    }else{
        [self.addWishlistButton setImage:[UIImage imageNamed:@"wishlist_empty_icon"] forState:UIControlStateNormal];
    }
}

@end
