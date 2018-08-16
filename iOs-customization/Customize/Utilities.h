//
//  Utilities.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 1/18/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject
+ (id)sharedInstance;
- (CGFloat)heightOfText:(NSString *)text labelWidth:(CGFloat)width font:(UIFont*)font numberOfLines:(int)numberOfLines;
- (CGFloat)widthOfText:(NSString *)text font:(UIFont *)font;
- (CGFloat)fontSizeToWrapText:(NSString *)text forLabel:(UILabel *)label;
@end
