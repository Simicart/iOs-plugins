//
//  SimiGlobalVar+ZTheme.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

extern NSString *const kZThemeGetHomeCategory;
extern NSString *const kZThemeGetSpotProducts;

static NSString* ZTHEME_FONT_NAME_BOLD = @"RobotoCondensed-Bold";
static NSString* ZTHEME_FONT_NAME_LIGHT = @"RobotoCondensed-Light";
static NSString* ZTHEME_FONT_NAME_REGULAR = @"RobotoCondensed-Regular";

#define zThemeSizeFontPrice (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?14:11)

#define ZTHEME_PRICE_COLOR [[SimiGlobalVar sharedInstance] colorWithHexString:@"#090809"]
#define ZTHEME_SPECIAL_PRICE_COLOR [[SimiGlobalVar sharedInstance] colorWithHexString:@"#ff7425"]
#define ZTHEME_OPTION_COLOR [[SimiGlobalVar sharedInstance] colorWithHexString:@"#f0f2f2"]
#define ZTHEME_SUB_PART_COLOR [[SimiGlobalVar sharedInstance] colorWithHexString:@"#FF7E00"]
#define ZTHEME_BTN_ADD_TO_CART_COLOR THEME_COLOR
#define ZTHEME_BTN_COLOR [[SimiGlobalVar sharedInstance] colorWithHexString:@"#f0f2f2"]

@interface SimiGlobalVar (ZTheme)

@end
