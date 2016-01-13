//
//  SCGridViewControllerPad_Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/12/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//


#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SCProductListViewController.h>
//  Liam UPDATE 150324
#import <SimiCartBundle/ILTranslucentView.h>
//  End
#import "SCCollectionViewControllerPad_Theme01.h"
#import "SCMenuSort_Theme01.h"
#import "SCProductViewControllerPad_Theme01.h"
#import "SCMenuCategory_Theme01.h"
#import "SCMenuCategory_v2.h"

@interface SCGridViewControllerPad_Theme01 : SCProductListViewController<SCCollectionViewController_Theme01_Delegate, SCMenuSort_Theme01_Delegate,
    UIPopoverControllerDelegate, SCMenuCategory_v2Delegate,
    SCMenuCategory_Theme01Delegate>

@property (strong, nonatomic) NSString *spotKey;
@property (strong, nonatomic) SCCollectionViewControllerPad_Theme01 *scCollectionView;
@property (nonatomic) SCCollectionGetProductType scCollectionGetProductType;
@property (nonatomic) BOOL isCategory;
@property (nonatomic) BOOL isSearch;
//  Liam ADD 150325 Feature Filter
@property (nonatomic, strong) UIPopoverController *popControllerFilter;
//  End

-(void)searchProductWithKey:(NSString *)key;
@end
