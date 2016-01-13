//
//  ZThemeNavigationBar.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimiCartBundle/BBBadgeBarButtonItem.h>
#import <SimiCartBundle/SCCountryStateViewController.h>

#import "ZThemeCartViewController.h"
#import "ZThemeLeftMenu.h"
#import "ZThemeCartViewController.h"
#import "ZThemeOrderViewController.h"


static NSString *ZTHEME_TRANSLUCENTVIEW = @"ZTHEME_TRANSLUCENTVIEW";

@interface ZThemeNavigationBar: NSObject<ZThemeLeftMenu_Delegate, SCCountryStateViewDelegate>

@property (strong, nonatomic) BBBadgeBarButtonItem *cartBadge;
@property (nonatomic, strong) ZThemeLeftMenu *zThemeLeftMenu;
@property (nonatomic, strong) ZThemeCartViewController *cartController;
@property (nonatomic, strong) SCCountryStateViewController *countryStateController;
@property (strong, nonatomic) SimiStoreModel *currentStore;
@property (strong, nonatomic) SimiStoreModelCollection *storeCollection;

@property (strong, nonatomic) NSMutableArray *leftButtonItems;
@property (strong, nonatomic) NSMutableArray *rightButtonItems;
@property (strong, nonatomic) UIBarButtonItem *listItem;
@property (strong, nonatomic) UIBarButtonItem *cartItem;
@property (strong, nonatomic) UIBarButtonItem *searchItem;

@property (nonatomic) BOOL isShowingLeftMenu;

+ (instancetype)sharedInstance;

@end
