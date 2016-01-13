//
//  ZThemeCollectionViewCell.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/7/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/SimiFormatter.h>

#import "SimiGlobalVar+ZTheme.h"

@interface ZThemeCollectionViewCell : UICollectionViewCell

@property (nonatomic) BOOL isShowOnlyImage;
@property (nonatomic) BOOL isChangeLayOut;
@property (nonatomic, strong) UIImageView *imageProduct;
@property (nonatomic, strong) UILabel *lblNameProduct;
@property (nonatomic, strong) UIImageView *imageFog;
@property (nonatomic, strong) UILabel *lblExcl;
@property (nonatomic, strong) UILabel *lblExclPrice;
@property (nonatomic, strong) UILabel *lblIncl;
@property (nonatomic, strong) UILabel *lblInclPrice;
@property (nonatomic, strong) UIView *viewLine;
@property (nonatomic) BOOL isRelated;
@property (nonatomic, strong) NSDictionary *priceDict;

@property (nonatomic, strong) NSString *stringNameProduct;
@property (nonatomic, strong) NSString *stringStock;
@property (nonatomic, strong) NSString *stringExclPrice;
@property (nonatomic, strong) NSString *stringInclPrice;
@property (nonatomic, strong) NSString *stringPriceRegular;
@property (nonatomic, strong) NSString *stringPriceSpecial;

@property (nonatomic, strong) SimiProductModel *productModel;

- (void)cusSetProductModel:(SimiProductModel *)productModel_;
- (void)setPrice;
- (void)setInterfaceCell;
- (void)cusSetStringExclPrice:(NSString *)stringExclPrice_;
- (void)cusSetStringInclPrice:(NSString *)stringInclPrice_;
- (void)cusSetStringPriceRegular:(NSString *)stringPriceRegular_;
- (void)cusSetStringPriceSpecial:(NSString *)stringPriceSpecial_;
@end
