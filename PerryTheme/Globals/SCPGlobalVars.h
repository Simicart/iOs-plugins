//
//  SCPGlobalVars.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/18/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCPThemeConfigModel.h"
#import "SCPNavigationBar.h"
#import "SCPWishlistModel.h"
#import "SCPWishlistModelCollection.h"

#define SCP_GLOBALVARS [SCPGlobalVars sharedInstance]
#define SCP_MENU_BACKGROUND_COLOR COLOR_WITH_HEX([SCP_GLOBALVARS.themeConfig menuBackgroudColor])
#define SCP_TITLE_COLOR COLOR_WITH_HEX([SCP_GLOBALVARS.themeConfig titleColor])
#define SCP_ICON_COLOR COLOR_WITH_HEX([SCP_GLOBALVARS.themeConfig iconColor])
#define SCP_ICON_HIGHLIGHT_COLOR COLOR_WITH_HEX([SCP_GLOBALVARS.themeConfig iconHighlightColor])
#define SCP_BUTTON_TEXT_COLOR COLOR_WITH_HEX([SCP_GLOBALVARS.themeConfig buttonTextColor])
#define SCP_BUTTON_BACKGROUND_COLOR COLOR_WITH_HEX([SCP_GLOBALVARS.themeConfig buttonBackgroundColor])

#define SCP_FONT_REGULAR  [SCP_GLOBALVARS getRegularFontName]
#define SCP_FONT_LIGHT  [SCP_GLOBALVARS getLightFontName]
#define SCP_FONT_SEMIBOLD  [SCP_GLOBALVARS getSemiBoldFontName]

@interface SCPGlobalVars : NSObject

@property (strong, nonatomic) SCPThemeConfigModel *themeConfig;
@property (nonatomic) float padding;
@property (nonatomic) float lineSpacing;
@property (nonatomic) float interitemSpacing;
@property (nonatomic) float textPadding;
@property (nonatomic) BOOL wishlistPluginAllow;
@property (strong, nonatomic) SCPWishlistModelCollection *wishListModelCollection;
@property (strong, nonatomic) UINavigationController *shouldSelectNavigationController;
+ (instancetype)sharedInstance;

- (NSString *)getRegularFontName;
- (NSString *)getLightFontName;
- (NSString *)getSemiBoldFontName;
@end
