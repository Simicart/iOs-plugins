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
#import "SCPCategoryModelCollection.h"

#define SCP_HOME_BANNER @"SCP_HOME_BANNER"
#define SCP_CATEGORY_LOADING @"SCP_CATEGORY_LOADING"
#define SCP_CATEGORY @"SCP_CATEGORY"
#define SCP_CATEGORY_VIEW_ALL_PRODUCTS @"SCP_CATEGORY_VIEW_ALL_PRODUCTS"
#define SCP_CATEGORY_VIEW_ALL_SUB_CATEGORIES @"SCP_CATEGORY_VIEW_ALL_SUB_CATEGORIES"
#define SCP_HOME_PRODUCT_LIST @"SCP_HOME_PRODUCT_LIST"

#define SCP_CATEGORY_TEXT_CELL_PADDING_TOP SCALEVALUE(12)
#define SCP_CATEGORY_TEXT_CELL_HEIGHT SCALEVALUE(30)

#define SCP_CATEGORY1_PADDING_X 0
#define SCP_CATEGORY2_PADDING_X 50
#define SCP_CATEGORY3_PADDING_X 100

@interface SCPHomeViewController : SCPTableViewController<MatrixBannerScrollViewDelegate>{
    NSIndexPath *loadingRowIndex;
    SCPCategoryModel *currentCategory;
    NSMutableArray *expandedRow1s;
    NSMutableArray *expandedRow2s;
}
@property (strong, nonatomic) NSMutableArray *categories;
- (void)initCategories;
- (void)initSubCategories:(SCPCategoryModelCollection *)subCategories;
- (void)createBannerCell;
- (void)createCategoryCells;
- (void)createProductListCells;
- (void)getPageData;

- (UITableViewCell *)addCategoryLoadingCellForRow:(SimiRow *)row;
- (UITableViewCell *)addCategoryCellForRow:(SimiRow *)row inSection:(SimiSection *)section;
- (UITableViewCell *)addCategoryViewAllSubCategoriesCellForRow:(SimiRow *)row inSection:(SimiSection *)section;
- (UITableViewCell *)addCategoryViewAllProductsCellForRow:(SimiRow *)row inSection:(SimiSection *)section;

- (void)didSelectCategoryCellAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isOpenedCMSPageWithCategory:(SCPCategoryModel *)category;

- (void)openProductListWithCategory:(SCPCategoryModel *)category;
- (void)openSubCategoryPageWithCategory:(SCPCategoryModel *)category;

- (void)getSubCategoriesOfCategory:(SCPCategoryModel *)category level:(NSString *)level;
@end
@interface SCPCategoryTextCell:SimiTableViewCell
@property (nonatomic) CGFloat width;
@property (strong,nonatomic) SCPCategoryModel *category;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWidth:(CGFloat)width;
@end
