//
//  SimiViewController+ZTheme.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiViewController+ZTheme.h"
#import "ZThemeWorker.h"

@implementation SimiViewController (ZTheme)

#pragma mark RightBar Item Reload
- (void)zThemeReloadRightBarItemPad
{
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItems = [[[ZThemeWorker sharedInstance]navigationBarPad] rightButtonItems];
    if ([[[ZThemeWorker sharedInstance]navigationBarPad] isShowSearchBar]) {
        [[[[ZThemeWorker sharedInstance]navigationBarPad] searchBar] becomeFirstResponder];
    }
}


#pragma mark Gesture Recognizer Functions

- (void)addGestureRecognizer
{
    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftEdgeGesture:)];
    leftEdgeGesture.edges = UIRectEdgeLeft;
    leftEdgeGesture.delegate = self;
    [self.view addGestureRecognizer:leftEdgeGesture];
    
}

- (void)handleLeftEdgeGesture:(UIScreenEdgePanGestureRecognizer *)gesture {
    if(UIGestureRecognizerStateBegan != gesture.state && UIGestureRecognizerStateChanged != gesture.state)
        [[[ZThemeWorker sharedInstance]navigationBarPad] didSelectListBarItem:nil];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
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

#pragma mark Navigation Bar Event
- (void)setNavigationBarOnViewDidLoadForZTheme
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        self.hidesBottomBarWhenPushed = YES;
        if (SIMI_SYSTEM_IOS >= 7.0) {
            self.automaticallyAdjustsScrollViewInsets = NO;
            self.edgesForExtendedLayout = UIRectEdgeBottom;
            self.navigationController.navigationBar.barTintColor = THEME_COLOR;
        }
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:17], NSFontAttributeName, nil]];
    }
}

- (void)setNavigationBarOnViewWillAppearForZTheme:(BOOL)isShowLeftMenu isShowRightItems:(BOOL)isShowRightItems
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (isShowRightItems) {
            self.navigationItem.rightBarButtonItems = [[[ZThemeWorker sharedInstance]navigationBar] rightButtonItems];
        }else
            self.navigationItem.rightBarButtonItems = nil;
        
        if (isShowLeftMenu) {
            self.navigationItem.leftBarButtonItems = [[[ZThemeWorker sharedInstance]navigationBar]leftButtonItems];
        }else
            self.navigationItem.leftBarButtonItems = nil;
        
        self.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

@end
