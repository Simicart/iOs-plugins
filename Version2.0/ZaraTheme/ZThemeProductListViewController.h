//
//  ZThemeProductListViewController.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/7/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SCProductListViewController.h>

#import "SCMenuSort.h"
#import "WYPopoverController.h"
#import "ZThemeCollectionViewController.h"
#import "ZThemeProductViewController.h"
#import "SimiViewController+ZTheme.h"

@interface ZThemeProductListViewController : SCProductListViewController<ZThemeCollectionViewController_Delegate, UISearchBarDelegate, WYPopoverControllerDelegate, SCMenuSortDelegate>

@property (strong, nonatomic) ZThemeCollectionViewController *zCollectionView;
@property (nonatomic) ZThemeCollectioViewGetProductType zCollectionGetProductType;
@property (strong, nonatomic) NSString *spot_ID;

@property (strong, nonatomic) UILabel *lblNumberProducts;
@property (strong, nonatomic) UILabel *lblProducts;
@property (nonatomic) BOOL isFirstLoad;

@property (nonatomic) NSString *keySearchProduct;
@property (nonatomic, strong) UISearchBar *searchProduct;
@property (nonatomic, strong) UIImageView *imageFogWhenSearch;
@property (nonatomic) BOOL isOpenSearchFromHome;

@property (strong, nonatomic) SCMenuSort *menuSort;
@property (nonatomic, strong) WYPopoverController *sortPopoverController;
@property (nonatomic) int sortSelected;


@end
