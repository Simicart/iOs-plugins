//
//  SCHomeViewController_ThemeOne.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/8/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiBannerModelCollection.h>
#import <SimiCartBundle/SimiTableView.h>
#import <SimiCartBundle/SimiCategoryModel.h>
#import <SimiCartBundle/SimiProductModel.h>
#import <SimiCartBundle/SCHomeViewController.h>

#import "SCTheme01SlideShow.h"
#import "SCListMenu_Theme01.h"
#import "SCTheme01SpotProductModelCollection.h"
#import "SCTheme01CategoryModelCollection.h"
#import "SCCategoryProductCell_Theme01.h"
#import "SCSpotProductCell_Theme01.h"

@interface SCHomeViewController_Theme01:SCHomeViewController <UITableViewDataSource, UITableViewDelegate, SCCategoryProductCell_Theme01_Delegate, SCSpotProductCell_Theme01_Delegate>


@property (strong, nonatomic) UIImageView *imageViewLogo;
@property (strong, nonatomic) SCTheme01SpotProductModelCollection *spotProductCollection;
@property (strong, nonatomic) SCTheme01CategoryModelCollection *cateCollection;
@property (strong, nonatomic) SCTheme01SlideShow *themeBannerSlider;

@property (strong, nonatomic) SCCategoryProductCell_Theme01 *viewCate01;
@property (strong, nonatomic) SCCategoryProductCell_Theme01 *viewCate02;
@property (strong, nonatomic) SCCategoryProductCell_Theme01 *viewCate03;
@property (strong, nonatomic) SCCategoryProductCell_Theme01 *viewAllCate;

//  Liam ADD 150319
@property (nonatomic) BOOL isDidGetBanner;
@property (nonatomic) BOOL isDidGetCategory;
@property (nonatomic) BOOL isDidGetSpotProduct;
//  End 150319

- (void)setViewCategory;
- (void)getCategorys:(NSDictionary *)param;
- (void)getOrderSpots:(NSDictionary *)param;
- (void)didReceiveNotification:(NSNotification*)noti;
@end
