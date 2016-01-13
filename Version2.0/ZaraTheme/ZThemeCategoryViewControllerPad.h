//
//  ZThemeCategoryViewControllerPad.h
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 5/21/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeCategoryViewController.h"
#import "ZThemeHomeViewControllerPad.h"

@interface ZThemeCategoryViewControllerPad : ZThemeCategoryViewController

@property (strong, nonatomic) UILabel * categoryTitle;
@property (nonatomic) BOOL isInView;

-(void)updateCategoryTitle: (NSString *)title;

@end
