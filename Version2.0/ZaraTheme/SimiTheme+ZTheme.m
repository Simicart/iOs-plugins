//
//  SimiTheme+ZTheme.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiTheme+ZTheme.h"

@implementation SimiTheme (ZTheme)
- (NSString *)getFontName
{
    return ZTHEME_FONT_NAME_REGULAR;
}

- (CGFloat)getFontSizeRegular
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 14;
    }else
    {
        return 18;
    }
}
@end
