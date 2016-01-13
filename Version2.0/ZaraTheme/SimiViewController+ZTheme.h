//
//  SimiViewController+ZTheme.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

static int tagViewFog = 12345;

@interface SimiViewController (ZTheme) <UIGestureRecognizerDelegate>

- (void)addGestureRecognizer;
- (void)zThemeReloadRightBarItemPad;
- (void)hiddenScreenWhenShowPopOver;
- (void)showScreenWhenHiddenPopOver;
- (void)setNavigationBarOnViewDidLoadForZTheme;
- (void)setNavigationBarOnViewWillAppearForZTheme:(BOOL)isShowLeftMenu isShowRightItems:(BOOL)isShowRightItems;
@end
