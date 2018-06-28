//
//  SCWishlistCollectionViewCell.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/25/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/SCPriceView.h>
#import <SimiCartBundle/UIImageView+WebCache.h>
#import "SCWishlistModel.h"

@protocol SCWishlistCollectionViewCellDelegate <NSObject>
- (void)deleteWishlistItem: (SCWishlistModel*) wishlistItem;
- (void)addToCartWithWishlistItem: (SCWishlistModel*) wishlistItem;
- (void)shareWishlistItem: (SCWishlistModel*) wishlistItem inView:(UIView*) view;
- (void)tapToWishlistItem: (SCWishlistModel*) wishlistItem;
@end

@interface SCWishlistCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) SCWishlistModel *wishlistItem;
@property (weak, nonatomic) id<SCWishlistCollectionViewCellDelegate> delegate;
@end
