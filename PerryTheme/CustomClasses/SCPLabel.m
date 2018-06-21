//
//  SCPLabel.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/27/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPLabel.h"

@implementation SCPLabel
- (void)showHTMLTextWithTitle:(NSString *)title value:(NSString *)value titleFont:(UIFont *)titleFont valueFont:(UIFont *)valueFont{
    NSString *html = [NSString stringWithFormat:@"<span style='font-family:%@;font-size:%f'>%@: </span><span style='font-family:%@;font-size:%f'>%@</span>",titleFont.fontName, titleFont.pointSize, SCLocalizedString(title),valueFont.fontName,valueFont.pointSize,SCLocalizedString(value)];
    [self setHTMLContent:html];
    [self wrapContent];
}
- (CGFloat)wrapContent{
    self.numberOfLines = 0;
    [self sizeToFit];
    return CGRectGetHeight(self.frame);
}
@end
