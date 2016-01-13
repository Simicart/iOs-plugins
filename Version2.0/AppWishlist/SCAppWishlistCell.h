//
//  SCProductListCell.h
//  SimiCart
//
//  Created by Tan on 4/30/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/SimiProductModel.h>


// Device Info
#define SIMI_DEBUG_ENABLE [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"SIMI_DEBUG_ENABLE"] boolValue]
#define SIMI_DEVELOPMENT_ENABLE [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"SIMI_DEVELOPMENT_ENABLE"] boolValue]
#define SIMI_THEME_ENABLE [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"SIMI_THEME_ENABLE"] boolValue]
#define SIMI_SYSTEM_IOS [[UIDevice currentDevice].systemVersion floatValue]
#define SCREEN_WIDTH    ((SIMI_SYSTEM_IOS >= 8)?[[UIScreen mainScreen] bounds].size.width:[[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT   ((SIMI_SYSTEM_IOS >= 8)?[[UIScreen mainScreen] bounds].size.height:[[UIScreen mainScreen] bounds].size.width)

// Theme Information
#define THEME_COLOR [SimiGlobalVar getThemeColor:@selector(themeColor)] ? [SimiGlobalVar getThemeColor:@selector(themeColor)] : [[SimiGlobalVar sharedInstance] themeColor]

#define THEME_ADD_CART_COLOR [SimiGlobalVar getThemeColor:@selector(addToCartColor)] ? [SimiGlobalVar getThemeColor:@selector(addToCartColor)] : [[SimiGlobalVar sharedInstance] themeColor]
#define THEME_IMAGE_COLOR_OVERLAY [SimiGlobalVar getThemeConfig:@selector(isColorOverlay)]

// Store and theme utilities
#define CURRENCY_SYMBOL [[SimiGlobalVar sharedInstance] currencySymbol]
#define CURRENCY_CODE [[SimiGlobalVar sharedInstance] currencyCode]
#define LOCALE_IDENTIFIER [[SimiGlobalVar sharedInstance] localeIdentifier]
#define COUNTRY_CODE [[SimiGlobalVar sharedInstance] countryCode]
#define COUNTRY_NAME [[SimiGlobalVar sharedInstance] countryName]
#define COLOR_WITH_HEX(hex) [[SimiGlobalVar sharedInstance] colorWithHexString:hex]
#define THEME_COLOR_IS_LIGHT ([[SimiGlobalVar sharedInstance] getLightDegreeOfColor: THEME_COLOR]) <= 0.81 ? YES : NO

// Customer config
#define PREFIX_SHOW [[SimiGlobalVar sharedInstance] prefixShow]
#define SUFFIX_SHOW [[SimiGlobalVar sharedInstance] suffixShow]
#define DOBFIX_SHOW [[SimiGlobalVar sharedInstance] dobShow]
#define TAXVAT_SHOW [[SimiGlobalVar sharedInstance] taxvatShow]
#define GENDER_SHOW [[SimiGlobalVar sharedInstance] genderShow]

//Re-define localize string macro
#define SCLocalizedString(key) [[SimiGlobalVar sharedInstance] localizedStringForKey:key]


@interface SCAppWishlistCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *addToCartButton;

@property (strong, nonatomic) SimiProductModel *product;

@property (strong, nonatomic) IBOutlet UIImageView *moreOptionNarrow;
@property (strong, nonatomic) IBOutlet UIView *moreOptionAnchor;

@property (strong, nonatomic) IBOutlet UIImageView *imageBorder;
@property (strong, nonatomic) IBOutlet UIImageView *triangle;
@property (strong, nonatomic) IBOutlet UIButton *moreOptionButton;
@property(nonatomic, strong) IBOutlet UILabel *productNameLabel;
@property(nonatomic, strong) IBOutlet UILabel *stockStatusLabel;
@property(nonatomic, strong) IBOutlet UIImageView *productImageView;
@property (nonatomic) int heightCell;
@property (strong, nonatomic) IBOutlet UILabel *option1Title;
@property (strong, nonatomic) IBOutlet UILabel *option2Title;
@property (strong, nonatomic) IBOutlet UILabel *option1Value;
@property (strong, nonatomic) IBOutlet UILabel *option2Value;
@property (strong, nonatomic) IBOutlet UILabel *haveMoreOptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) NSString * sharingMessage;
@property (strong, nonatomic) NSString * sharingUrl;



@property (strong, nonatomic) NSNumber * productPrice;

@property (strong, nonatomic) UIImageView *moreOptionsFrame;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UIButton * deleteButton;


- (void)hideButtons;
- (void)showButtons;
- (void)hideButtonsNoEffect;
- (void)setInterfaceCell;
@end
