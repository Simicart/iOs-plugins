//
//  SCNavigationBar_Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/13/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimiCartBundle/BBBadgeBarButtonItem.h>
#import <SimiCartBundle/SimiViewController.h>
#import <SimiCartBundle/SCCountryStateViewController.h>

#import "SCListMenu_Theme01.h"
#import "SCCartViewController_Theme01.h"
#import "SCVirtualHomeView_Theme01.h"

@protocol SCNavigationBar_Theme01_Delegate <NSObject>

- (void) didSelectVirtualHome;

@end

@interface SCNavigationBar_Theme01 :SimiViewController<SCListMenu_Theme01_Delegate, SCCountryStateViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) id<SCNavigationBar_Theme01_Delegate> delegate;
@property (strong, nonatomic) BBBadgeBarButtonItem *cartBadge;
@property (nonatomic, strong) SCListMenu_Theme01 *listMenuView;
@property (nonatomic, strong) SCCartViewController_Theme01 *cartController;
@property (nonatomic, strong) SCCountryStateViewController *countryStateController;
@property (strong, nonatomic) SimiStoreModel *currentStore;
@property (strong, nonatomic) SimiStoreModelCollection *storeCollection;

@property (strong, nonatomic) NSMutableArray *leftButtonItems;
@property (strong, nonatomic) NSMutableArray *rightButtonItems;
@property (strong, nonatomic) UIBarButtonItem *listItem;
@property (strong, nonatomic) UIBarButtonItem *cartItem;
@property (strong, nonatomic) UIBarButtonItem *searchItem;
@property (strong, nonatomic) SCVirtualHomeView_Theme01 *virtualHomeView;


+ (instancetype)sharedInstance;
@end
