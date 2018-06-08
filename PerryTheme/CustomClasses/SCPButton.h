//
//  SCPButton.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/27/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SCPButton : UIButton
- (id)initWithFrame:(CGRect)frame title:(NSString *)title titleFont:(UIFont *)titleFont cornerRadius:(float)cornerRadius borderWidth:(int)borderWidth borderColor:(UIColor *)borderColor shadowOffset:(CGSize)shadowOffset shadowRadius:(float)shadowRadius shadowOpacity:(float)shadowOpacity;
- (id)initWithFrame:(CGRect)frame title:(NSString *)title titleFont:(UIFont *)titleFont cornerRadius:(float)cornerRadius borderWidth:(int)borderWidth borderColor:(UIColor *)borderColor;
@end
