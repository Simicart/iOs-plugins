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
#import "SCPCategoryModel.h"

#define SCP_HOME_BANNER @"SCP_HOME_BANNER"
#define SCP_HOME_LOADING @"SCP_HOME_LOADING"
#define SCP_CATEGORY @"SCP_CATEGORY"
#define SCP_CATEGORY_VIEW_ALL_PRODUCTS @"SCP_CATEGORY_VIEW_ALL_PRODUCTS"
#define SCP_CATEGORY_VIEW_ALL_SUB_CATEGORIES @"SCP_CATEGORY_VIEW_ALL_SUB_CATEGORIES"
#define SCP_HOME_PRODUCT_LIST @"SCP_HOME_PRODUCT_LIST"

#define SCP_CATEGORY_TEXT_CELL_PADDING_TOP 15

@interface SCPHomeViewController : SCPTableViewController<MatrixBannerScrollViewDelegate>
@property (strong, nonatomic) NSMutableArray *categories;
- (void)initRootCategories;
- (void)createCategoryCells;
- (void)getPageData;
@end
@interface SCPHomeCategoryTextCell:SimiTableViewCell
@property (strong,nonatomic) SCPCategoryModel *category;
@property (nonatomic) BOOL isHighlight;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCategory:(SCPCategoryModel *)category andWidth:(CGFloat)width;
@end
