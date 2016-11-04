//
//  SCWishlistCollectionViewCell.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/25/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCWishlistCollectionViewCell.h"

@implementation SCWishlistCollectionViewCell
{
    UIImageView* wishlistImageView;
    UIView* wishlistItemInfoView;
    SCPriceView* priceView;
    UILabel* itemNameLabel;
    UIButton* deleteButton;
    UIButton* shareButton;
    UIButton* addToCartButton;
}

-(void) setWishlistItem:(NSDictionary *)wishlistItem{
    _wishlistItem = wishlistItem;
    float paddingLeft = 5;
    float paddingTop = 5;
    float rightButtonWidth = 30;
    float wishlistCellWidth = CGRectGetWidth(self.frame) - rightButtonWidth - paddingLeft;
    float wishlistCellHeight =CGRectGetHeight(self.frame);
    if(!wishlistImageView){
        wishlistImageView = [[UIImageView alloc] initWithFrame:CGRectMake(paddingLeft, paddingTop, wishlistCellWidth/3 - paddingLeft, wishlistCellHeight - paddingTop)];
        wishlistImageView.layer.borderColor = [[SimiGlobalVar sharedInstance]colorWithHexString:@"#e8e8e8"].CGColor;
        wishlistImageView.layer.borderWidth = 1;
        wishlistImageView.contentMode = UIViewContentModeScaleAspectFit;
        [wishlistImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wishlistImageViewTapped:)]];
        wishlistImageView.userInteractionEnabled = YES;
        [self addSubview:wishlistImageView];
    }
    [wishlistImageView sd_setImageWithURL:[NSURL URLWithString:[wishlistItem objectForKey:@"product_image"]] placeholderImage:[UIImage imageNamed:@"logo"]];
    float wishlistItemY = 0;
    float labelHeight = 25;
    if(!wishlistItemInfoView){
        wishlistItemInfoView = [[UIView alloc] initWithFrame:CGRectMake(wishlistCellWidth/3+paddingLeft, paddingTop, 2*wishlistCellWidth/3 - paddingLeft, wishlistCellHeight - paddingTop)];
        float wishlistItemWidth = CGRectGetWidth(wishlistItemInfoView.frame);
        [self addSubview:wishlistItemInfoView];
        itemNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, wishlistItemY, wishlistItemWidth, labelHeight)];
        itemNameLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
        [wishlistItemInfoView addSubview:itemNameLabel];
        wishlistItemY += itemNameLabel.frame.size.height;
        priceView = [[SCPriceView alloc] initWithFrame:CGRectMake(0, wishlistItemY, wishlistItemWidth, 0)];
        [wishlistItemInfoView addSubview:priceView];
        addToCartButton = [[UIButton alloc] init];
        [addToCartButton setBackgroundColor:THEME_BUTTON_BACKGROUND_COLOR];
        addToCartButton.titleLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
        [addToCartButton setTitleColor:THEME_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
        [addToCartButton addTarget:self action:@selector(addToCartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        addToCartButton.layer.cornerRadius = 3;
        [wishlistItemInfoView addSubview:addToCartButton];
        if([[wishlistItem objectForKey:@"stock_status"] boolValue])
            [addToCartButton setTitle:SCLocalizedString(@"Add To Cart") forState:UIControlStateNormal];
        else{
            [addToCartButton setTitle:SCLocalizedString(@"Out Of Stock") forState:UIControlStateNormal];
            addToCartButton.enabled = NO;
            addToCartButton.alpha = 0.5f;
        }
    }
    itemNameLabel.text = [wishlistItem objectForKey:@"product_name"];
    SimiProductModel* productModel = [[SimiProductModel alloc] initWithDictionary:wishlistItem];
    [priceView setProductModel:productModel andWidthView:CGRectGetWidth(wishlistItemInfoView.frame)];
    [addToCartButton setFrame:CGRectMake(0, priceView.frame.origin.y + priceView.frame.size.height + paddingTop, CGRectGetWidth(wishlistItemInfoView.frame), 30)];
    
    float rightButtonY = paddingTop;
    if(!deleteButton){
        deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - rightButtonWidth, rightButtonY, rightButtonWidth, rightButtonWidth)];
        [deleteButton setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [deleteButton setImage:[UIImage imageNamed:@"wishlist_remove_icon"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteButton];
        rightButtonY += CGRectGetHeight(deleteButton.frame) + paddingTop;
    }
    if(!shareButton){
        shareButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - rightButtonWidth, rightButtonY, rightButtonWidth, rightButtonWidth)];
        [shareButton setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [shareButton setImage:[UIImage imageNamed:@"wishlist_share_icon"] forState:UIControlStateNormal];
        [shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:shareButton];
    }
    [SimiGlobalVar sortViewForRTL:self andWidth:CGRectGetWidth(self.frame)];
}


-(void) wishlistImageViewTapped: (id) sender{
    [self.delegate tapToWishlistItem:_wishlistItem];
}

-(void) addToCartButtonClicked: (id) sender{
    [self.delegate addToCartWithWishlistItem:_wishlistItem];
}

-(void) deleteButtonClicked:(id) sender{
    [self.delegate deleteWishlistItem:_wishlistItem];
}


-(void) shareButtonClicked: (id) sender{
    UIButton* wishlistShareButton = (UIButton*) sender;
    [self.delegate shareWishlistItem:_wishlistItem inView:wishlistShareButton];
}

-(void) didAddProductFromWishlistToCart:(NSNotification*)noti{
}

@end
