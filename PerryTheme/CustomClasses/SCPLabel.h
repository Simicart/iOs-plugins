//
//  SCPLabel.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/27/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "SCPGlobalVars.h"

@interface SCPLabel : SimiLabel
- (void)showHTMLTextWithTitle:(NSString *)title value:(NSString *)value titleFont:(UIFont *)titleFont valueFont:(UIFont *)valueFont;
- (CGFloat)wrapContent;
@end
