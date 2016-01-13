//
//  SCNavigationBar_Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/13/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimiCartBundle/BBBadgeBarButtonItem.h>
#import <SimiCartBundle/SimiStoreModelCollection.h>
#import <SimiCartBundle/SimiStoreModel.h>
#import <SimiCartBundle/SCCountryStateViewController.h>

#import "SCListMenuPad_Theme01.h"
#import "SCGridViewControllerPad_Theme01.h"
#import "SCCartViewControllerPad_Theme01.h"
#import "SCOrderViewControllerPad_Theme01.h"

@interface SCNavigationBarPad_Theme01 : NSObject<UISearchBarDelegate, SCListMenuPad_Theme01Delegate, UIPopoverControllerDelegate, SCCountryStateViewDelegate, SCLoginViewController_Theme01_Delegate>

@property (strong, nonatomic) SimiStoreModelCollection *storeCollection;
//  Liam ADD 150417
@property (strong, nonatomic) SimiStoreModel *storeModel;
//  End 150417
@property (strong, nonatomic) SimiStoreModel *currentStore;
@property (strong, nonatomic) BBBadgeBarButtonItem *cartBadge;
@property (nonatomic, strong) SCListMenuPad_Theme01 *listMenuView;
@property (strong, nonatomic) NSMutableArray *leftButtonItems;
@property (strong, nonatomic) NSMutableArray *rightButtonItems;
@property (strong, nonatomic) UIBarButtonItem *listItem;
@property (strong, nonatomic) UIBarButtonItem *cartItem;
@property (strong, nonatomic) UIBarButtonItem *searchItem;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIPopoverController *popController;
@property (strong, nonatomic) NSString *currentKeySearch;
@property (strong, nonatomic) SCCartViewControllerPad_Theme01 *cartViewController;
@property (strong, nonatomic) UIButton *cartButton;
@property (nonatomic) BOOL isShowSearchBar;

+ (instancetype)sharedInstance;
@end
