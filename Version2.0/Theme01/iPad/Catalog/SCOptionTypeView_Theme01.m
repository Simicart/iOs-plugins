//
//  SCOptionTypeView_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/29/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCOptionTypeView_Theme01.h"

@implementation SCOptionTypeView_Theme01

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _lblOptionName = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, 240, frame.size.height)];
        [_lblOptionName setFont:[UIFont fontWithName:THEME01_FONT_NAME_BOLD size:15]];
        [_lblOptionName setTextColor:[UIColor blackColor]];
        _lblOptionName.numberOfLines = 3;
        
        _lblRequire = [[UILabel alloc]initWithFrame:CGRectMake(200, 0, 20, frame.size.height)];
        [_lblRequire setFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:14]];
        _lblRequire.textColor = THEME01_PRICE_COLOR;
        
        _lblOptionPrice = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width - 100, 0, 100, frame.size.height)];
        [_lblOptionPrice setFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:14]];
        _lblOptionPrice.textColor = THEME01_PRICE_COLOR;
        
        _imageDropdown = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width - 100, 0, 40, frame.size.height)];
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [_lblOptionName setFrame:CGRectMake(150, 0, 240, frame.size.height)];
            [_lblOptionPrice setFrame:CGRectMake(20, 0, 100, frame.size.height)];
        }
        //  End RTL
        [self addSubview:_lblOptionName];
        [self addSubview:_lblRequire];
        [self addSubview:_lblOptionPrice];
        [self addSubview:_imageDropdown];
    }
    return self;
}

- (void)changeLocation
{
    CGFloat labelWidth = [_lblOptionName.text sizeWithAttributes:@{NSFontAttributeName:_lblOptionName.font}].width;
    if (labelWidth > 240) {
        labelWidth = 240;
    }
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        CGRect frame = _lblOptionName.frame;
        frame.origin.x += frame.size.width - labelWidth;
         [_lblOptionName setFrame:frame];
        
        frame = _lblRequire.frame;
        frame.origin.x = _lblOptionName.frame.origin.x - 20;
        frame.origin.y = 0;
        frame.size.width = 15;
        frame.size.height = self.frame.size.height;
        [_lblRequire  setFrame:frame];
        return;
    }
    CGRect frame = _lblOptionName.frame;
    frame.size.width = labelWidth;
    [_lblOptionName setFrame:frame];
    
    frame.origin.x = _lblOptionName.frame.origin.x + labelWidth + 12;
    frame.origin.y = 0;
    frame.size.width = 15;
    frame.size.height = self.frame.size.height;
    [_lblRequire  setFrame:frame];
}
@end
