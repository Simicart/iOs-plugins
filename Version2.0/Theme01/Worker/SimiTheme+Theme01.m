//
//  SimiTheme+Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 12/11/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiTheme+Theme01.h"
#import "SimiGlobalVar+Theme01.h"
@implementation SimiTheme (Theme01)

- (NSString *)getFontName
{
    return THEME01_FONT_NAME_REGULAR;
}

- (UIColor *)priceColor
{
    return THEME01_PRICE_COLOR;
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

- (NSString *)formatTitleString:(NSString *)title
{
    return [title uppercaseString];
}

@end
