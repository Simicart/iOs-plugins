//
//  SimiViewController+Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 12/22/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <SimiCartBundle/UIImage+SimiCustom.h>
#import "SimiViewController+Theme01.h"
#import "SimiThemeWorker.h"

@implementation SimiViewController (Theme01)

- (void)setNavigationBarOnViewDidLoadForTheme01
{
    if (SIMI_SYSTEM_IOS >= 7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.edgesForExtendedLayout = UIRectEdgeBottom;
        self.navigationController.navigationBar.barTintColor = THEME_COLOR;
    }
    self.hidesBottomBarWhenPushed = YES;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:17], NSFontAttributeName, nil]];
    }
}

- (void)setNavigationBarOnViewWillAppearForTheme01
{
    UIBarButtonItem *backItem;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.navigationItem.titleView = imageView;
        self.navigationItem.titleView.contentMode = UIViewContentModeCenter;
        
        if ((self != [self.navigationController.viewControllers objectAtIndex:0]) && (self.navigationController.viewControllers != NULL) ){
            backItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_back"] imageWithColor:THEME_COLOR] style:UIBarButtonItemStyleBordered target:self action:@selector(didSelectBackBarItem:)];
            backItem.tag = BACK_ITEM;
        }
        NSMutableArray *leftItems = [[[[SimiThemeWorker sharedInstance] navigationBarPad] leftButtonItems] mutableCopy];
        CGFloat width = 0;
        if (backItem) {
            [leftItems addObject:backItem];
            width += 32;
        }else{
            UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            space.width = 40;
            space.tag = SPACE_ITEM;
            width += space.width;
            [leftItems addObject:space];
        }
        self.navigationItem.rightBarButtonItems = [[[SimiThemeWorker sharedInstance]navigationBarPad] rightButtonItems];
        self.navigationItem.leftBarButtonItems = leftItems;
    }else
    {
        self.navigationItem.rightBarButtonItems = [[[SimiThemeWorker sharedInstance]navigationBar] rightButtonItems];
        [self.navigationController.view addSubview:[[[SimiThemeWorker sharedInstance]navigationBar] virtualHomeView]];
    }
}


- (void)didSelectBackBarItem:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteBackItemForTheme01
{
    self.navigationItem.rightBarButtonItems = nil;
    if (([[[[[SimiThemeWorker sharedInstance] navigationBarPad] leftButtonItems] lastObject] tag] == BACK_ITEM) || ([[[[[SimiThemeWorker sharedInstance] navigationBarPad] leftButtonItems] lastObject] tag] == SPACE_ITEM)) {
        //Remove back item
        [[[[SimiThemeWorker sharedInstance] navigationBarPad] leftButtonItems] removeLastObject];
    }
}

- (void)reloadRightBarItem
{
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItems = [[[SimiThemeWorker sharedInstance]navigationBarPad] rightButtonItems];
    if ([[[SimiThemeWorker sharedInstance]navigationBarPad] isShowSearchBar]) {
        [[[[SimiThemeWorker sharedInstance]navigationBarPad] searchBar] becomeFirstResponder];
    }
}
- (void)hiddenScreenWhenShowPopOver
{
    UIImageView *imageFogView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [imageFogView setBackgroundColor:[UIColor whiteColor]];
    [imageFogView setAlpha:0.5];
    imageFogView.tag = tagViewFog;
    [self.view addSubview:imageFogView];
}

- (void)showScreenWhenHiddenPopOver
{
    for (UIView *imageFogView in self.view.subviews) {
        if (imageFogView.tag == tagViewFog) {
            [imageFogView removeFromSuperview];
        }
    }
}
@end
