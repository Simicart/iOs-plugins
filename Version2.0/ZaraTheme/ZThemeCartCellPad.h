//
//  ZThemeCartCellPad.h
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 5/29/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <SimiCartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/SCAppDelegate.h>

#import "ZThemeCartCell.h"


@protocol ZThemeCartCellPad_Delegate <NSObject>

- (void)removeProductFromCart:(NSString *)cartItemId;
- (void)showProductDetail:(NSString*)productID;

@end

@interface ZThemeCartCellPad : UITableViewCell

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) UILabel *stockStatusLabel;
@property (strong, nonatomic) UITextField *qtyTextField;
@property (strong, nonatomic) UIImageView *productImageView;
@property (strong, nonatomic) UIImageView *productBackgroundImage;

@property (strong, nonatomic) UIImageView *deleteImage;
@property (strong, nonatomic) UIButton *deleteButton;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) NSString *qty;
@property (nonatomic) BOOL stockStatus;
@property (nonatomic) NSString *cartItemId;
@property (strong, nonatomic) id<ZThemeCartCellPad_Delegate> delegate;
@property (nonatomic) NSInteger textFieldTag;
@property (nonatomic) CGFloat heightCell;
@property (strong, nonatomic) SimiCartModel *item;
@property (nonatomic) int cellWith;

- (void)deleteButtonClicked:(id)sender;
- (void)setInterfaceCell;
- (void) setCellWith:(int)cellWith_;

@end