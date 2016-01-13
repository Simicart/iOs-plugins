//
//  SimiGlobalVar+Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/15/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiGlobalVar.h>
@class SimiViewController;
extern NSString *const kSimiTheme01GetOrderCategories;
extern NSString *const kSimiTheme01GetOrderSpots;
extern NSString *const kSimiTheme01GetSpotProducts;

static NSString* THEME01_FONT_NAME_BOLD = @"SegoeUI-Semibold";
static NSString* THEME01_FONT_NAME_LIGHT = @"SegoeUI-Light";
static NSString* THEME01_FONT_NAME_REGULAR = @"SegoeUI";

#define THEME01_PRICE_COLOR [[SimiGlobalVar sharedInstance] colorWithHexString:@"#ff7425"];
#define THEME01_SPECIAL_PRICE_COLOR [[SimiGlobalVar sharedInstance] colorWithHexString:@"#ff7425"];
#define THEME01_OPTION_COLOR [[SimiGlobalVar sharedInstance] colorWithHexString:@"#f0f2f2"];
#define THEME01_SUB_PART_COLOR [[SimiGlobalVar sharedInstance] colorWithHexString:@"#FF7E00"]
#define sizeFontPrice (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?14:11)

@interface SimiGlobalVar (Theme01)

@end
