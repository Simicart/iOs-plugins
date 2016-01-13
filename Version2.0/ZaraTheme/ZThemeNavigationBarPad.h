//
//  ZThemeNavigationBar.h
//  SimiCartPluginFW
//
//  Created by Cody on 5/12/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimiCartBundle/BBBadgeBarButtonItem.h>
#import <SimiCartBundle/SCCountryStateViewController.h>

#import "ZThemeLeftMenuPad.h"
#import "ZThemeCartViewControllerPad.h"

@interface ZThemeNavigationBarPad :  NSObject<UISearchBarDelegate, UIPopoverControllerDelegate, ZThemeLeftMenu_Delegate, SCCountryStateViewDelegate>




//@property (strong, nonatomic) SimiStoreModel *currentStore;
@property (strong, nonatomic) BBBadgeBarButtonItem *cartBadge;
@property (strong, nonatomic) SimiStoreModel *storeModel;

@property (nonatomic, strong) ZThemeLeftMenuPad *zThemeLeftMenu;
@property (nonatomic, strong) ZThemeCartViewController *cartController;
@property (strong, nonatomic) SimiStoreModel *currentStore;
@property (strong, nonatomic) SimiStoreModelCollection *storeCollection;
@property (nonatomic, strong) SCCountryStateViewController *countryStateController;

@property (strong, nonatomic) NSMutableArray *leftButtonItems;
@property (strong, nonatomic) NSMutableArray *rightButtonItems;
@property (strong, nonatomic) UIBarButtonItem *listItem;
@property (strong, nonatomic) UIBarButtonItem *cartItem;
@property (strong, nonatomic) UIBarButtonItem *searchItem;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIPopoverController *popController;
@property (strong, nonatomic) NSString *currentKeySearch;
@property (strong, nonatomic) UIButton *cartButton;
@property (nonatomic) BOOL isShowSearchBar;

@property (strong, nonatomic) ZThemeCartViewControllerPad * cartViewController;

@property (strong, nonatomic) UIView * searchBarHolder;
@property (strong, nonatomic) UISearchBar * searchBarPad;


@property (nonatomic) BOOL isShowingLeftMenu;

+ (instancetype)sharedInstance;
- (void)didSelectListBarItem:(id)sender;

@end
