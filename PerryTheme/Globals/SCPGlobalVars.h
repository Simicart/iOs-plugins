//
//  SCPGlobalVars.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/18/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCPThemeConfigModel.h"

#define SCP_GLOBALVARS [SCPGlobalVars sharedInstance]
#define SCP_MENU_BACKGROUND_COLOR COLOR_WITH_HEX([SCP_GLOBALVARS.themeConfig menuBackgroudColor])
#define SCP_TITLE_COLOR COLOR_WITH_HEX([SCP_GLOBALVARS.themeConfig titleColor])
#define SCP_ICON_COLOR COLOR_WITH_HEX([SCP_GLOBALVARS.themeConfig iconColor])
#define SCP_ICON_HIGHLIGHT_COLOR COLOR_WITH_HEX([SCP_GLOBALVARS.themeConfig iconHighlightColor])
#define SCP_BUTTON_TEXT_COLOR COLOR_WITH_HEX([SCP_GLOBALVARS.themeConfig buttonTextColor])
#define SCP_BUTTON_BACKGROUND_COLOR COLOR_WITH_HEX([SCP_GLOBALVARS.themeConfig buttonBackgroundColor])

@interface SCPGlobalVars : NSObject

@property (strong, nonatomic) SCPThemeConfigModel *themeConfig;

+ (instancetype)sharedInstance;
@end
