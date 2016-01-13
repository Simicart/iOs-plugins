//
//  ZThemeHomeViewControllerPad.h
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 5/7/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeHomeViewController.h"
#import "ZThemeRightMenuPad.h"

@interface ZThemeHomeViewControllerPad : ZThemeHomeViewController <UIGestureRecognizerDelegate>

@property ZThemeRightMenuPad * rightMenu;
@property (nonatomic) int currentSection;

@end
