//
//  SimiViewController+Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 12/22/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController.h>

static int BACK_ITEM = 123;
static int SPACE_ITEM = 134;
static int tagViewFog = 12345;
@interface SimiViewController (Theme01)

- (void)setNavigationBarOnViewDidLoadForTheme01;
- (void)setNavigationBarOnViewWillAppearForTheme01;
- (void)deleteBackItemForTheme01;
- (void)hiddenScreenWhenShowPopOver;
- (void)showScreenWhenHiddenPopOver;
- (void)reloadRightBarItem;
@end
