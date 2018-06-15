//
//  SCPOrderMethodCell.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 6/13/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SCOrderMethodCell.h>

@interface SCPOrderMethodCell : SCOrderMethodCell
- (void)setTitle:(NSString *)title andContent:(NSString *)content andIsSelected:(BOOL)isSelected width:(CGFloat)width;
@end
