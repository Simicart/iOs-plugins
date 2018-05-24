//
//  SCPHomeViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/18/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPViewController.h"
#import "SCPTableViewController.h"
#import <SimiCartBundle/MatrixBannerScrollView.h>
#import <SimiCartBundle/MatrixBannerScrollViewPad.h>

#define SCP_HOME_BANNER @"SCP_HOME_BANNER"
#define SCP_CATEGORY @"SCP_CATEGORY"
#define SCP_CATEGORY_VIEW_ALL_PRODUCTS @"SCP_CATEGORY_VIEW_ALL_PRODUCTS"
#define SCP_CATEGORY_VIEW_ALL_SUB_CATEGORIES @"SCP_CATEGORY_VIEW_ALL_SUB_CATEGORIES"
#define SCP_HOME_PRODUCT_LIST @"SCP_HOME_PRODUCT_LIST"

#define TEXT_CATEGORY_CELL_HEIGHT 35

@interface SCPHomeViewController : SCPTableViewController<MatrixBannerScrollViewDelegate>
@property (strong, nonatomic) NSMutableArray *categories;
- (void)initCategories;
- (void)createCategoryCells;
- (void)getPageData;
@end
