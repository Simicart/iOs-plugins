//
//  SCPProductCollectionViewCell.h
//  SimiCartPluginFW
//
//  Created by Liam on 4/27/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SCProductCollectionViewCell.h>

@interface SCPProductCollectionViewCell : SCProductCollectionViewCell
@property (nonatomic) BOOL onListMode;
@property (nonatomic, strong) UIButton *addWishlistButton;
@property (strong, nonatomic) UIImageView *saleImageView;
@property (strong, nonatomic) UIImageView *playImageView;
@end
