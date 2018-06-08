//
//  SCPButton.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/27/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPButton.h"
#import "SCPGlobalVars.h"

@implementation SCPButton
- (id)initWithFrame:(CGRect)frame title:(NSString *)title titleFont:(UIFont *)titleFont cornerRadius:(float)cornerRadius borderWidth:(int)borderWidth borderColor:(UIColor *)borderColor{
    return [self initWithFrame:frame title:title titleFont:titleFont cornerRadius:cornerRadius borderWidth:borderWidth borderColor:borderColor shadowOffset:CGSizeZero shadowRadius:0 shadowOpacity:0];
}
- (id)initWithFrame:(CGRect)frame title:(NSString *)title titleFont:(UIFont *)titleFont cornerRadius:(float)cornerRadius borderWidth:(int)borderWidth borderColor:(UIColor *)borderColor shadowOffset:(CGSize)shadowOffset shadowRadius:(float)shadowRadius shadowOpacity:(float)shadowOpacity {
    if (self == [super initWithFrame:frame]) {
        [self.layer setMasksToBounds:NO];
        self.layer.cornerRadius = cornerRadius;
        self.layer.borderWidth = borderWidth;
        self.layer.borderColor = borderColor.CGColor;
        [self setBackgroundColor:SCP_BUTTON_BACKGROUND_COLOR];
        [self setTitleColor:SCP_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
        self.titleLabel.font = titleFont;
        [self setTitle:title forState:UIControlStateNormal];
        [self.layer setShadowOffset:shadowOffset];
        [self.layer setShadowRadius:shadowRadius];
        self.layer.shadowOpacity = shadowOpacity;
        NSString *color = SCP_GLOBALVARS.themeConfig.buttonBackgroundColor;
        if ([color isEqualToString:@"#ffffff"]) {
            if(!borderColor) {
                self.layer.borderColor = [UIColor grayColor].CGColor;
            }
            if(borderWidth == -1) {
                self.layer.borderWidth = 1;
            }
        }
    }
    return self;
}

@end
