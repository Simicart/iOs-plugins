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
    SimiButton* addToCartButton;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    float paddingLeft = 10;
    float paddingTop = 5;
    float rightButtonWidth = 30;
    float wishlistCellWidth = CGRectGetWidth(frame) - rightButtonWidth - paddingLeft;
    float wishlistCellHeight =CGRectGetHeight(frame);
    wishlistImageView = [[UIImageView alloc] initWithFrame:CGRectMake(paddingLeft, paddingTop, wishlistCellWidth/3 - paddingLeft, wishlistCellHeight - paddingTop)];
    wishlistImageView.contentMode = UIViewContentModeScaleAspectFit;
    [wishlistImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wishlistImageViewTapped:)]];
    wishlistImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:wishlistImageView];
    
    float wishlistItemY = 0;
    float labelHeight = 25;
    wishlistItemInfoView = [[UIView alloc] initWithFrame:CGRectMake(wishlistCellWidth/3+paddingLeft, paddingTop, 2*wishlistCellWidth/3 - paddingLeft, wishlistCellHeight - paddingTop)];
    float wishlistItemWidth = CGRectGetWidth(wishlistItemInfoView.frame);
    [self.contentView addSubview:wishlistItemInfoView];
    
    itemNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, wishlistItemY, wishlistItemWidth, labelHeight)];
    itemNameLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:FONT_SIZE_LARGE];
    [wishlistItemInfoView addSubview:itemNameLabel];
    wishlistItemY += itemNameLabel.frame.size.height;
    priceView = [[SCPriceView alloc] initWithFrame:CGRectMake(0, wishlistItemY, wishlistItemWidth, 0)];
    [wishlistItemInfoView addSubview:priceView];
    
    addToCartButton = [[SimiButton alloc] init];
    [addToCartButton.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:FONT_SIZE_MEDIUM]];
    [addToCartButton addTarget:self action:@selector(addToCartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [wishlistItemInfoView addSubview:addToCartButton];
    
    float rightButtonY = paddingTop;
    deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - rightButtonWidth, rightButtonY, rightButtonWidth, rightButtonWidth)];
    [deleteButton setContentEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [deleteButton setImage:[UIImage imageNamed:@"wishlist_remove_icon"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:deleteButton];
    rightButtonY += CGRectGetHeight(deleteButton.frame) + paddingTop;
    
    shareButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - rightButtonWidth, rightButtonY, rightButtonWidth, rightButtonWidth)];
    [shareButton setContentEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [shareButton setImage:[UIImage imageNamed:@"wishlist_share_icon"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:shareButton];
    
    [SimiGlobalFunction sortViewForRTL:self.contentView andWidth:CGRectGetWidth(self.frame)];
    return self;
}

- (void)setWishlistItem:(SCWishlistModel *)wishlistItem{
    _wishlistItem = wishlistItem;
    [wishlistImageView sd_setImageWithURL:[NSURL URLWithString:wishlistItem.productImage] placeholderImage:[UIImage imageNamed:@"logo"]];

    if(wishlistItem.stockStatus)
        [addToCartButton setTitle:SCLocalizedString(@"Add To Cart") forState:UIControlStateNormal];
    else{
        [addToCartButton setTitle:SCLocalizedString(@"Out of stock") forState:UIControlStateNormal];
        addToCartButton.enabled = NO;
        addToCartButton.alpha = 0.5f;
    }

    itemNameLabel.text = wishlistItem.name;
    SimiProductModel* productModel = [[SimiProductModel alloc] initWithModelData:wishlistItem.modelData];
    [priceView showPriceWithProduct:productModel widthView:CGRectGetWidth(wishlistItemInfoView.frame)];
    [addToCartButton setFrame:CGRectMake(0, priceView.frame.origin.y + priceView.frame.size.height + 5, CGRectGetWidth(wishlistItemInfoView.frame), 30)];
}


- (void)wishlistImageViewTapped: (id) sender{
    [self.delegate tapToWishlistItem:_wishlistItem];
}

- (void)addToCartButtonClicked: (id) sender{
    [self.delegate addToCartWithWishlistItem:_wishlistItem];
}

- (void)deleteButtonClicked:(id) sender{
    [self.delegate deleteWishlistItem:_wishlistItem];
}


- (void)shareButtonClicked: (id) sender{
    UIButton* wishlistShareButton = (UIButton*) sender;
    [self.delegate shareWishlistItem:_wishlistItem inView:wishlistShareButton];
}

- (void)didAddProductFromWishlistToCart:(NSNotification*)noti{
}

@end
