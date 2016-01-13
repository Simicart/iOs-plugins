//
//  SCOptionGroupViewCell_Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/26/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiView.h>

@interface SCOptionGroupViewCell_Theme01 : SimiView
- (void)setPriceOption:(NSDictionary*)optionDictionary;

@property (nonatomic, strong) UILabel *lblOptionName;
@property (nonatomic, strong) UILabel *lblRegular;
@property (nonatomic, strong) UILabel *lblRegularPrice;
@property (nonatomic, strong) UILabel *lblSpecial;
@property (nonatomic, strong) UILabel *lblSpecialPrice;
@property (nonatomic, strong) UILabel *lblExclSpecial;
@property (nonatomic, strong) UILabel *lblExclSpecialPrice;
@property (nonatomic, strong) UILabel *lblInclSpecial;
@property (nonatomic, strong) UILabel *lblInclSpecialPrice;

@property (nonatomic, strong) NSString *stringRegularPrice;
@property (nonatomic, strong) NSString *stringSpecialPrice;
@property (nonatomic, strong) NSString *stringExclSpecialPrice;
@property (nonatomic, strong) NSString *stringInclSpecialPrice;
@property (nonatomic, strong) NSDictionary *optionDict;
@property (nonatomic, strong) NSDictionary *dictPrice;
@property (nonatomic, strong) UIColor *priceColor;
@property (nonatomic, strong) UIColor *labelColor;
@property (nonatomic, strong) NSString *themeFontName;
@property (nonatomic) CGFloat themeSize;
@end
