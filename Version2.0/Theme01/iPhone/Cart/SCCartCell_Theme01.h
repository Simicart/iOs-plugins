//
//  SCCartCell_Theme01.h
//  SimiCart
//
//  Created by Tan on 5/16/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/SCAppDelegate.h>

@protocol SCCartCellDelegate_Theme01 <NSObject>

- (void)removeProductFromCart:(NSString *)cartItemId;

@end

@interface SCCartCell_Theme01 : UITableViewCell

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) UILabel *stockStatusLabel;
@property (strong, nonatomic) UITextField *qtyTextField;
@property (strong, nonatomic) UIImageView *productImageView;
@property (strong, nonatomic) UIImageView *deleteImage;
@property (strong, nonatomic) UIButton *deleteButton;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) NSString *qty;
@property (nonatomic) BOOL stockStatus;
@property (nonatomic) NSString *cartItemId;
@property (strong, nonatomic) id<SCCartCellDelegate_Theme01> delegate;
@property (nonatomic) NSInteger textFieldTag;
@property (nonatomic) CGFloat heightCell;
@property (strong, nonatomic) SimiCartModel *item;

- (void)deleteButtonClicked:(id)sender;
- (void)setInterfaceCell;

@end
