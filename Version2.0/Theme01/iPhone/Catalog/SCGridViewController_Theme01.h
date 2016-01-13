//
//  SCGridViewController_Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/12/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//


#import <SimiCartBundle/SCProductListViewController.h>
//  Liam UPDATE 150324
#import <SimiCartBundle/ILTranslucentView.h>
//  End
#import "SCCollectionViewController_Theme01.h"
#import "SCProductViewController_Theme01.h"
#import "SCMenuSort_Theme01.h"
#import "WYPopoverController.h"

@interface SCGridViewController_Theme01 : SCProductListViewController<SCMenuSort_Theme01_Delegate,          UIPopoverControllerDelegate, WYPopoverControllerDelegate,
    SCCollectionViewController_Theme01_Delegate, SCFilterViewControllerDelegate>
{
    NSString *keySearchProduct;
    WYPopoverController *sortPopoverController;
}

@property (strong, nonatomic) UIPopoverController *popController;
@property (strong, nonatomic) SCMenuSort_Theme01 *menuSort;
@property (strong, nonatomic) SCCollectionViewController_Theme01 *scCollectionView;
@property (nonatomic) SCCollectionGetProductType scCollectionGetProductType;
@property (strong, nonatomic) NSString *spotKey;
@property (strong, nonatomic) UILabel *lblNumberProducts;
@property (strong, nonatomic) UILabel *lblProducts;
@property (nonatomic) BOOL isFirstLoad;
@property (nonatomic) int sortSelected;


-(void)searchProductWithKey:(NSString *)key;
@end
