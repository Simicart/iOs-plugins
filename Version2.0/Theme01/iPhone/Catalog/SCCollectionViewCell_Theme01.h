//
//  SCCollectionViewCell_Theme01
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/SimiProductModel.h>
#import "SCTheme01_APIKey.h"
#import "SimiGlobalVar+Theme01.h"

@protocol SCCollectionViewCell_Theme01_Delegate <NSObject>
- (void) didSelectRelatedProduct: (id) sender;

@end

@interface SCCollectionViewCell_Theme01 : UICollectionViewCell

@property (nonatomic, strong) id<SCCollectionViewCell_Theme01_Delegate> delegate;
@property (nonatomic, strong) UIImageView *imageProduct;
@property (nonatomic, strong) UIImageView *imageBackgroundProduct;
@property (nonatomic, strong) UIImageView *imageBackgroundNameFirst;
@property (nonatomic, strong) UIImageView *imageBackgroundNameSecond;
@property (nonatomic, strong) UIImageView *imageBackGroundPrice;
@property (nonatomic, strong) UIImageView *imageShowProductLabel;
@property (nonatomic, strong) UIImageView *imageStar1;
@property (nonatomic, strong) UIImageView *imageStar2;
@property (nonatomic, strong) UIImageView *imageStar3;
@property (nonatomic, strong) UIImageView *imageStar4;
@property (nonatomic, strong) UIImageView *imageStar5;

@property (nonatomic, strong) UILabel *lblNameProduct;
@property (nonatomic, strong) UILabel *lblExcl;
@property (nonatomic, strong) UILabel *lblExclPrice;
@property (nonatomic, strong) UILabel *lblIncl;
@property (nonatomic, strong) UILabel *lblInclPrice;
@property (nonatomic, strong) UILabel *lblStock;
@property (nonatomic) BOOL isRelated;
@property (nonatomic, strong) NSDictionary *priceDict;

@property (nonatomic, strong) NSString *stringNameProduct;
@property (nonatomic, strong) NSString *stringStock;
@property (nonatomic, strong) NSString *stringExclPrice;
@property (nonatomic, strong) NSString *stringInclPrice;
@property (nonatomic, strong) NSString *stringPriceRegular;
@property (nonatomic, strong) NSString *stringPriceSpecial;
@property (nonatomic) float productRate;
@property (nonatomic, strong) SimiProductModel *productModel;

- (id)initWithNibName:(NSString *)nibNameOrNil;
- (void)cusSetProductModel:(SimiProductModel *)productModel_;
- (void)setPrice;
- (void)setInterfaceCell;
- (void)cusSetStringExclPrice:(NSString *)stringExclPrice_;
- (void)cusSetStringInclPrice:(NSString *)stringInclPrice_;
- (void)cusSetStringPriceRegular:(NSString *)stringPriceRegular_;
- (void)cusSetStringPriceSpecial:(NSString *)stringPriceSpecial_;
- (void)cusSetProductRate:(float)pr;
- (void) didSelectRelatedProduct:(id)sender;
@end
