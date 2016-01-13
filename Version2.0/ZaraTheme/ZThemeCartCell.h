//
//  ZThemeCartCell.h
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 5/28/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/SCAppDelegate.h>

@protocol ZThemeCartCellDelegate <NSObject>

- (void)removeProductFromCart:(NSString *)cartItemId;

@end

@interface ZThemeCartCell : UITableViewCell


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
@property (strong, nonatomic) id<ZThemeCartCellDelegate> delegate;
@property (nonatomic) NSInteger textFieldTag;
@property (nonatomic) CGFloat heightCell;
@property (strong, nonatomic) SimiCartModel *item;

- (void)deleteButtonClicked:(id)sender;
- (void)setInterfaceCell;

@end
