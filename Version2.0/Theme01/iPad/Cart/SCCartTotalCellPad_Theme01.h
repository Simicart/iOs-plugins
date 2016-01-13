//
//  SCCartTotalCellPad_Theme01.h
//  SimiCart
//
//  Created by Tân Hoàng on 8/8/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SimiOrderModel.h>

@interface SCCartTotalCellPad_Theme01 : UITableViewCell

@property (strong, nonatomic) UILabel *discountLabel;
@property (strong, nonatomic) UILabel *totalLabel;
@property (strong, nonatomic) UILabel *shippingLabel;
@property (strong, nonatomic) UILabel *taxLabel;
@property (strong, nonatomic) UILabel *subTotalLabel;
@property (strong, nonatomic) UILabel *subTotalExclLabel;
@property (strong, nonatomic) UILabel *subTotalInclLabel;
@property (strong, nonatomic) UILabel *totalExclLabel;
@property (strong, nonatomic) UILabel *totalInclLabel;
@property (strong, nonatomic) UILabel *shippingExclLabel;
@property (strong, nonatomic) UILabel *shippingInclLabel;
@property (strong, nonatomic) UILabel *discountValueLabel;
@property (strong, nonatomic) UILabel *totalValueLabel;
@property (strong, nonatomic) UILabel *shippingValueLabel;
@property (strong, nonatomic) UILabel *taxValueLabel;
@property (strong, nonatomic) UILabel *subTotalValueLabel;
@property (strong, nonatomic) UILabel *subTotalExclValueLabel;
@property (strong, nonatomic) UILabel *subTotalInclValueLabel;
@property (strong, nonatomic) UILabel *totalExclValueLabel;
@property (strong, nonatomic) UILabel *totalInclValueLabel;
@property (strong, nonatomic) UILabel *shippingExclValueLabel;
@property (strong, nonatomic) UILabel *shippingInclValueLabel;

@property (strong, nonatomic) NSString *subTotal;
@property (strong, nonatomic) NSString *tax;
@property (strong, nonatomic) NSString *shipping;
@property (strong, nonatomic) NSString *total;
@property (strong, nonatomic) NSString *discount;
@property (strong, nonatomic) NSString *subTotalExcl;
@property (strong, nonatomic) NSString *subTotalIncl;
@property (strong, nonatomic) NSString *totalExcl;
@property (strong, nonatomic) NSString *totalIncl;
@property (strong, nonatomic) NSString *shippingExcl;
@property (strong, nonatomic) NSString *shippingIncl;
@property (strong, nonatomic) SimiOrderModel *order;
@property (nonatomic) int heightCell;
@property (strong, nonatomic) NSArray *totalV2;
@property (nonatomic) int cellWith;

- (void)setOrder:(SimiOrderModel *)order;
- (void)setData:(NSMutableArray*)cartPrices;
- (void)setInterfaceCell;

@end
