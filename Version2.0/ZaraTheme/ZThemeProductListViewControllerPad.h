//
//  ZThemeProductListViewControllerPad.h
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 5/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeProductListViewController.h"
#import "ZThemeCollectionViewControllerPad.h"
#import "SCMenuCategory_v2.h"
#import "SCMenuCategory.h"

@interface ZThemeProductListViewControllerPad : ZThemeProductListViewController<UIPopoverControllerDelegate, SCMenuCategory_v2Delegate,
SCMenuCategoryDelegate>

@property (strong, nonatomic) UIButton *btnCategory;

@property (strong, nonatomic) SCMenuCategory_v2 *scMenuCategory_v2;
@property (strong, nonatomic) SCMenuCategory *scMenuCategory;
@property (strong, nonatomic) SimiCategoryModelCollection *categoryCollection;
@property (strong, nonatomic) UIPopoverController *popController;
@property (nonatomic) BOOL isCategory;
@property (strong, nonatomic) NSString *spotKey;
@property (nonatomic) ZThemeCollectioViewGetProductType scCollectionGetProductType;
@property (nonatomic) BOOL isSearch;
@property (nonatomic, strong) UIPopoverController *popControllerFilter;


- (void)initCollectionView;
@end
