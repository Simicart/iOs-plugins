//
//  ZThemeRightMenuPad.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 5/21/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeRightMenuPad.h"
#import "SimiGlobalVar+ZTheme.h"
#import "ZThemeCategoryViewControllerPad.h"

@implementation ZThemeRightMenuPad
{
    ZThemeCategoryViewControllerPad * categoryViewController;
}
@synthesize isShowing;

#pragma mark Init List Menu
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setAlpha:0.95f];
        [self setBackgroundColor:[UIColor whiteColor]];
        isShowing = NO;
        frame.origin.x += frame.size.width;
        [self setFrame:frame];
        self.hidden = YES;
        if (categoryViewController == nil) {
            categoryViewController = [[ZThemeCategoryViewControllerPad alloc] init];
            categoryViewController.isInView = YES;
            [self addSubview:categoryViewController.view];
            [categoryViewController.view setFrame:CGRectMake(0, 60, frame.size.width, frame.size.height-60)];
        }
    }
    return self;
}

#pragma mark update Category
//update category list from child list
- (void)updateCategory:(SimiCategoryModelCollection *) categoryModelCollection :(NSString *)categoryId :(NSString *) categoryName
{
    [self displayView];
    categoryViewController.categoryRealName = categoryName;
    categoryViewController.categoryCollection = categoryModelCollection;
    [categoryViewController.tableViewCategory reloadData];
    [categoryViewController updateCategoryTitle:categoryName];
    [categoryViewController setCategoryId:categoryId];
}



//get category list from category id and category name
- (void)updateCategory:(NSString *)categoryId :(NSString *)categoryName
{
    [self  displayView];
    categoryViewController.categoryRealName = categoryName;
    [categoryViewController updateCategoryTitle:categoryName];
    [categoryViewController startLoadingData];
    [categoryViewController setCategoryId:categoryId];
    [categoryViewController getCategories];
}



#pragma mark view Actions hide and show
- (void)displayView
{
    if (!isShowing) {
        isShowing = YES;
        self.hidden = NO;
        CGRect frame = self.frame;
        frame.origin.x -= frame.size.width;
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = frame;
        }];
    }
}

- (void)dismissView
{
    if (isShowing) {
        isShowing = NO;
        CGRect frame = self.frame;
        frame.origin.x += frame.size.width;
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = frame;
        } completion:^(BOOL finished){
            self.hidden = YES;}];
        
    }
}

@end
