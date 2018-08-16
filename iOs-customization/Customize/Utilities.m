//
//  Utilities.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 1/18/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities
+ (id)sharedInstance{
    static Utilities *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[Utilities alloc] init];
    });
    return _sharedInstance;
}
- (CGFloat)heightOfText:(NSString *)text labelWidth:(CGFloat)width font:(UIFont *)font numberOfLines:(int)numberOfLines{
    SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(0, 0, width, 0) andFont:font];
    label.text = SCLocalizedString(text);
    label.numberOfLines = numberOfLines;
    [label sizeToFit];
    return CGRectGetHeight(label.frame);
}
- (CGFloat)widthOfText:(NSString *)text font:(UIFont *)font{
    SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectZero andFont:font];
    label.text = text;
    [label sizeToFit];
    return CGRectGetWidth(label.frame);
}
- (CGFloat)fontSizeToWrapText:(NSString *)text forLabel:(UILabel *)label{
    float fontSize = label.font.pointSize;
    float textWidth = [self widthOfText:text font:[UIFont fontWithName:label.font.familyName size:fontSize]];
    while (textWidth > CGRectGetWidth(label.frame)) {
        fontSize -= 1;
        textWidth = [self widthOfText:text font:[UIFont fontWithName:label.font.familyName size:fontSize]];
    }
    label.font = [UIFont fontWithName:label.font.familyName size:fontSize];
    return fontSize;
}
@end
