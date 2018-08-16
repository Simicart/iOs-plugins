//
//  SCAppWishlistCoreWorker.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 8/25/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCSearchVoiceCoreWorker.h"
#import <SimiCartBundle/SCHomeViewController.h>
#import <SimiCartBundle/SCNavigationBarPad.h>
#import <SimiCartBundle/SCProductListViewController.h>
#import "SCSearchVoiceViewController.h"
#import "SCSearchVoicePadViewController.h"
#import "SCCustomizeCategoryViewController.h"
#import "SCCustomizeSearchViewController.h"

@implementation SCSearchVoiceCoreWorker {
    SimiViewController *viewController;
    SCNavigationBarPad *controller;
    BOOL *showOnPad;
}


- (instancetype)init{
    self = [super init];
    if (self) {
        //Product More View
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearchVoiceBtn:) name:@"SCHomeViewControllerViewWillAppear" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearchVoiceBtn:) name:@"SCProductListViewControllerViewWillAppear" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearchVoiceBtn:) name:@"SCCategoryViewControllerViewWillAppear" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearchVoiceBtn:) name:@"SCCustomizeSearchViewControllerViewWillAppear" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initLeftItemsEnd:) name:@"SCNavigationBarPad-InitLeftItems-End" object:nil];
    }
    return self;
}

#pragma mark Notification Action
- (void)initLeftItemsEnd:(NSNotification*)noti{
    controller = [noti.userInfo valueForKey:@"controller"];
    UIButton *voiceSearchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [voiceSearchButton setImage:[[UIImage imageNamed:@"ic_small_micro"] imageWithColor:THEME_NAVIGATION_ICON_COLOR] forState:UIControlStateNormal];
    [voiceSearchButton setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    [voiceSearchButton addTarget:self action:@selector(searchVoiceStart:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *voiceSearchItem = [[UIBarButtonItem alloc] initWithCustomView:voiceSearchButton];
    voiceSearchItem.sortOrder = navigationbar_pad_search_voice_sort_order;
    UIBarButtonItem *itemSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    itemSpace.sortOrder = navigationbar_pad_search_voice_sort_order - 1;
    itemSpace.width = 20;
    NSMutableArray *rightButtonItems = noti.object;
    [rightButtonItems addObjectsFromArray:@[itemSpace,voiceSearchItem]];
}

- (void)showSearchVoiceBtn:(NSNotification *)noti{
    viewController = noti.object;
    float insetPadding = SCALEVALUE(5);
    if (PHONEDEVICE) {
        if ([noti.object isKindOfClass:[SCHomeViewController class]]) {
            SCHomeViewController *homeViewController = noti.object;
            [homeViewController.searchBarHome setFrame:SCALEFRAME(CGRectMake(5, 5, 310 - 28 - 5, 28))];
            [homeViewController.searchBarBackground setFrame:homeViewController.searchBarHome.frame];
            self.searchVoiceBtn = [[UIButton alloc] initWithFrame:SCALEFRAME(CGRectMake(282, 0, 38, 38))];
            self.searchVoiceBtn.backgroundColor = [UIColor clearColor];
            self.searchVoiceBtn.imageView.backgroundColor = THEME_SEARCH_BOX_BACKGROUND_COLOR;
            [self.searchVoiceBtn setAlpha:0.9f];
            [self.searchVoiceBtn setImage:[UIImage imageNamed:@"ic_small_micro_phone"] forState:UIControlStateNormal];
            [self.searchVoiceBtn setImageEdgeInsets:UIEdgeInsetsMake(insetPadding, insetPadding, insetPadding, insetPadding)];
            self.searchVoiceBtn.imageView.clipsToBounds = YES;
            self.searchVoiceBtn.enabled = YES;
            [self.searchVoiceBtn addTarget:self action:@selector(searchVoiceStart:) forControlEvents:(UIControlEventTouchUpInside)];
            [homeViewController.view addSubview:self.searchVoiceBtn];
        } else if ([noti.object isKindOfClass:[SCProductListViewController class]]) {
            SCProductListViewController *productListViewController = noti.object;
            [productListViewController.productSearchBar setFrame:SCALEFRAME(CGRectMake(5, 5, 310 - 28 - 5, 28))];
            [productListViewController.searchBarBackground setFrame:productListViewController.productSearchBar.frame];
            self.searchVoiceBtn = [[UIButton alloc] initWithFrame:SCALEFRAME(CGRectMake(282, 0, 38, 38))];
            self.searchVoiceBtn.backgroundColor = [UIColor clearColor];
            self.searchVoiceBtn.imageView.backgroundColor = THEME_SEARCH_BOX_BACKGROUND_COLOR;
            [self.searchVoiceBtn setAlpha:0.9f];
            [self.searchVoiceBtn setImage:[UIImage imageNamed:@"ic_small_micro_phone" ] forState:UIControlStateNormal];
            [self.searchVoiceBtn setImageEdgeInsets:UIEdgeInsetsMake(insetPadding, insetPadding, insetPadding, insetPadding)];
            self.searchVoiceBtn.imageView.clipsToBounds = YES;
            self.searchVoiceBtn.enabled = YES;
            [self.searchVoiceBtn addTarget:self action:@selector(searchVoiceStart:) forControlEvents:(UIControlEventTouchUpInside)];
            [productListViewController.view addSubview:self.searchVoiceBtn];
        }else if ([noti.object isKindOfClass:[SCCategoryViewController class]]) {
            SCCustomizeCategoryViewController *cateVC = noti.object;
            [cateVC.searchBarHome setFrame:SCALEFRAME(CGRectMake(5, 5, 310 - 28 - 5, 28))];
            [cateVC.searchBarBackground setFrame:cateVC.searchBarHome.frame];
            self.searchVoiceBtn = [[UIButton alloc] initWithFrame:SCALEFRAME(CGRectMake(282, 0, 38, 38))];
            self.searchVoiceBtn.backgroundColor = [UIColor clearColor];
            self.searchVoiceBtn.imageView.backgroundColor = THEME_SEARCH_BOX_BACKGROUND_COLOR;
            [self.searchVoiceBtn setAlpha:0.9f];
            [self.searchVoiceBtn setImage:[UIImage imageNamed:@"ic_small_micro_phone" ] forState:UIControlStateNormal];
            [self.searchVoiceBtn setImageEdgeInsets:UIEdgeInsetsMake(insetPadding, insetPadding, insetPadding, insetPadding)];
            self.searchVoiceBtn.imageView.clipsToBounds = YES;
            self.searchVoiceBtn.enabled = YES;
            [self.searchVoiceBtn addTarget:self action:@selector(searchVoiceStart:) forControlEvents:(UIControlEventTouchUpInside)];
            [cateVC.view addSubview:self.searchVoiceBtn];
        }else if ([noti.object isKindOfClass:[SCCustomizeSearchViewController class]]) {
            SCCustomizeSearchViewController *searchViewController = noti.object;
            if (![searchViewController.view viewWithTag:1231]) {
                CGRect frame = searchViewController.customSearchBar.frame;
                frame.size.width -= 35;
                [searchViewController.customSearchBar setFrame:frame];
                [searchViewController.searchBarBackground setFrame:frame];
                UIButton *searchVoiceBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40, 0, 40, 40)];
                searchVoiceBtn.tag = 1231;
                searchVoiceBtn.backgroundColor = [UIColor clearColor];
                searchVoiceBtn.imageView.backgroundColor = THEME_SEARCH_BOX_BACKGROUND_COLOR;
                [searchVoiceBtn setAlpha:0.9f];
                [searchVoiceBtn setImage:[UIImage imageNamed:@"ic_small_micro_phone" ] forState:UIControlStateNormal];
                [searchVoiceBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 10)];
                searchVoiceBtn.imageView.clipsToBounds = YES;
                searchVoiceBtn.enabled = YES;
                [searchVoiceBtn addTarget:self action:@selector(searchVoiceStart:) forControlEvents:(UIControlEventTouchUpInside)];
                [searchViewController.view addSubview:searchVoiceBtn];
            }
        }
    }
}

#pragma mark SearchVoiceViewController Delegate
- (void)finishAction:(NSString *)result {
    SimiViewController *currentViewController = [GLOBALVAR.currentlyNavigationController.viewControllers lastObject];
    SCCustomizeSearchViewController *searchViewController = [SCCustomizeSearchViewController new];
    if ([currentViewController isKindOfClass:[SCCustomizeSearchViewController class]]) {
        searchViewController = (SCCustomizeSearchViewController*)currentViewController;
    }
    searchViewController.keySearch = result;
    [currentViewController dismissViewControllerAnimated:YES completion:^{
        if (![currentViewController isKindOfClass:[SCCustomizeSearchViewController class]]) {
            [GLOBALVAR.currentlyNavigationController pushViewController:searchViewController animated:YES];
        }
    }];
    /**
    if (PADDEVICE) {
        [self.searchVoicePadViewController dismissViewControllerAnimated:YES completion:nil];
        if (controller.searchBar ==nil) {
            controller.searchBar = [UISearchBar new];
            controller.searchBar.placeholder = SCLocalizedString(@"Search");
            for ( UIView * subview in [[controller.searchBar.subviews objectAtIndex:0] subviews] )
            {
                if ([subview isKindOfClass:NSClassFromString(@"UISearchBarTextField") ] ) {
                    UITextField *searchView = (UITextField *)subview ;
                    if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
                        [searchView setTextAlignment:NSTextAlignmentRight];
                    }
                }
            }
        }

        controller.searchBar.tintColor = THEME_SEARCH_TEXT_COLOR;
        controller.searchBar.text = result;
        [controller searchBarSearchButtonClicked:controller.searchBar];
    } else {
        [self.searchVoiceViewController dismissViewControllerAnimated:YES completion:nil];
        if ([viewController isKindOfClass:[SCHomeViewController class]]) {
            SCHomeViewController *homeViewController = (SCHomeViewController *)viewController;
            homeViewController.searchBarHome.text = result;
            [homeViewController searchBarSearchButtonClicked:homeViewController.searchBarHome];
        }else if ([viewController isKindOfClass:[SCProductListViewController class]]) {
            SCProductListViewController *productListViewController = (SCProductListViewController *)viewController;
            productListViewController.productSearchBar.text = result;
            [productListViewController searchBarSearchButtonClicked:productListViewController.productSearchBar];
        }
    }
     */
}

- (void)searchTextAction{
    SimiViewController *currentViewController = [GLOBALVAR.currentlyNavigationController.viewControllers lastObject];
    [currentViewController dismissViewControllerAnimated:YES completion:^{
        if (![currentViewController isKindOfClass:[SCCustomizeSearchViewController class]]) {
            SCCustomizeSearchViewController *searchViewController = [SCCustomizeSearchViewController new];
            [GLOBALVAR.currentlyNavigationController pushViewController:searchViewController animated:YES];
        }
    }];
    /**
    if (PHONEDEVICE) {
        [self.searchVoiceViewController dismissViewControllerAnimated:YES completion:^{
            if ([viewController isKindOfClass:[SCHomeViewController class]]) {
                SCHomeViewController *homeViewController = (SCHomeViewController *)viewController;
                [homeViewController.searchBarHome becomeFirstResponder];
            } else if ([viewController isKindOfClass:[SCProductListViewController class]]) {
                SCProductListViewController *productListViewController = (SCProductListViewController*)viewController;
                [productListViewController.productSearchBar becomeFirstResponder];
            }
        }];
    }else{
        [self.searchVoicePadViewController dismissViewControllerAnimated:YES completion:^{
            [controller didSelectSearchButton:controller.searchBar];
        }];
    }
     */
}

- (void)tryAgainAction {
    
}

- (void)cancelAction {
    if (PHONEDEVICE) {
        [self.searchVoiceViewController dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.searchVoicePadViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)searchVoiceStart:(UIButton*)sender{
    SimiViewController *currentViewController = [GLOBALVAR.currentlyNavigationController.viewControllers lastObject];
    if (PADDEVICE) {
        if (self.searchVoicePadViewController == nil) {
            self.searchVoicePadViewController = [[SCSearchVoicePadViewController alloc] init];
        }
        self.searchVoicePadViewController.delegate = self;
        [currentViewController presentViewController:self.searchVoicePadViewController animated:YES completion:nil];
    } else {
        if (self.searchVoiceViewController == nil) {
            self.searchVoiceViewController = [[SCSearchVoiceViewController alloc] init];
        }
        self.searchVoiceViewController.delegate = self;
        [currentViewController presentViewController:self.searchVoiceViewController animated:YES completion:nil];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
