//
//  SCPHomeViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/18/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPHomeViewController.h"
#import "SCPHomeCategoryModel.h"
#import <SimiCartBundle/UIButton+WebCache.h>
#import "SCPGlobalVars.h"
#import <SimiCartBundle/SimiHomeModel.h>
#import <SimiCartBundle/SimiHomeProductListModel.h>
#import <SimiCartBundle/SimiHomeCategoryModel.h>
#import "SCPPadProductsViewController.h"
#import "SCPCategoryViewController.h"
#import "SCPProductViewController.h"
#import "SimiHomeModel+SCP.h"


@interface SCPHomeViewController ()
@property (strong, nonatomic) SimiHomeModel *homeModel;
@end

@implementation SCPHomeViewController{
    SimiHomeBannerModelCollection *phoneBanners;
    SimiHomeBannerModelCollection *padBanners;
    NSMutableArray *expandedRow1s;
    NSIndexPath *loadingRow;
    SCPCategoryModel *currentCategory;
}

- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    self.contentTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    self.contentTableView.tableFooterView = [UIView new];
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.contentTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.contentTableView];
    expandedRow1s = [NSMutableArray new];
//    expandedRow2s = [NSMutableArray new];
    [self getPageData];
}

- (void)getPageData{
    [self getHomeDataLiteWithChildCat];
}

- (void)getHomeDataLiteWithChildCat{
    self.homeModel = [[SimiHomeModel alloc]init];
    [self.homeModel getHomeDataWithParams:@{@"get_child_cat":@"1"}];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetHomeData:) name:Simi_DidGetHomeData object:self.homeModel];
    self.contentTableView.hidden = YES;
    [self startLoadingData];
}
- (void)getSubCategoriesOfCategory:(SCPCategoryModel *)category withLevel:(NSString *)level{
    currentCategory = category;
    SCPCategoryModelCollection *cateCollection = [SCPCategoryModelCollection new];
    [cateCollection getSubCategoriesWithId:category.entityId level:level];
//    [self startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetSubCategories:) name:Simi_DidGetCategoryCollection object:nil];
}
- (void)didGetHomeData:(NSNotification *)noti{
    if ([noti.name isEqualToString:Simi_DidGetHomeData]){
        [self removeObserverForNotification:noti];
        [self stopLoadingData];
        SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
        if (responder.status == SUCCESS) {
            [self initShowableBanners];
            [self initRootCategories];
            [self initCells];
        }else {
            [self showToastMessage:responder.message duration:2];
        }
    }
}
- (void)didGetSubCategories:(NSNotification *)noti{
//    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        [self initSubCategories:noti.object];
        SimiSection *section = [self.cells objectAtIndex:loadingRow.section];
        SimiRow *row = [section objectAtIndex:loadingRow.row];
        [section removeRow:row];
        if(loadingRow){
            [self.contentTableView beginUpdates];
            [self.contentTableView deleteRowsAtIndexPaths:@[loadingRow] withRowAnimation:UITableViewRowAnimationTop];
            [self.contentTableView endUpdates];
            loadingRow = nil;
        }
        [self initCells];
    }else {
        [self showToastMessage:responder.message duration:2];
    }
}
- (void)initShowableBanners{
    phoneBanners = [SimiHomeBannerModelCollection new];
    padBanners = [SimiHomeBannerModelCollection new];
    if(self.homeModel.bannerCollection.count > 0){
        for(SimiHomeBannerModel *banner in self.homeModel.bannerCollection.collectionData){
            if(![banner.imageURL isEqualToString:@""]){
                [phoneBanners.collectionData addObject:banner];
            }
        }
        for(SimiHomeBannerModel *banner in self.homeModel.bannerCollection.collectionData){
            if(![banner.imageURLPad isEqualToString:@""]){
                [padBanners.collectionData addObject:banner];
            }
        }
    }
}

- (void)initRootCategories{
    self.categories = [NSMutableArray new];
    for(SimiHomeCategoryModel *category in self.homeModel.categoryCollection.collectionData){
        SCPHomeCategoryModel *category1 = [[SCPHomeCategoryModel alloc] initWithModelData:category.modelData];
        [self.categories addObject:category1];
        category1.level = CategoryLevelOne;
        category1.isSelected = NO;
        category1.parentCategory = nil;
        if(category1.hasChildren){
            for(SCPHomeCategoryModel *category2 in category1.subCategories){
                category2.level = CategoryLevelTwo;
                category2.isSelected = NO;
                category2.parentCategory = category1;
            }
        }
    }
}

- (void)initSubCategories:(SCPCategoryModelCollection *)categoryCollection{
    for(SCPCategoryModel *category1 in self.categories){
        for(SCPCategoryModel *category2 in category1.subCategories){
            if(currentCategory == category2){
                category2.subCategories = [NSMutableArray new];
                for(SCPCategoryModel *category3 in categoryCollection.collectionData){
                    category3.level = CategoryLevelThree;
                    category3.isSelected = NO;
                    category3.parentCategory = category2;
                    [category2.subCategories addObject:category3];
                }
                category2.isSelected = YES;
                return;
            }
        }
    }
}

#pragma mark Set Cells
- (void)createCells{
    self.cells = [SimiTable new];
    [self.contentTableView setHidden:NO];
    if (phoneBanners.count > 0) {
        SimiSection *bannerSection = [self.cells addSectionWithIdentifier:SCP_HOME_BANNER];
        float bannerHeight = SCREEN_WIDTH/2;
        if(PHONEDEVICE){
            if(phoneBanners.count > 0){
                [bannerSection addRowWithIdentifier:SCP_HOME_BANNER height:bannerHeight];
            }
        }else if(PADDEVICE){
            if(padBanners.count > 0){
                if(padBanners.count < 2){
                    bannerHeight = SCREEN_WIDTH/2;
                }else{
                    bannerHeight = SCREEN_WIDTH/4;
                }
                [bannerSection addRowWithIdentifier:SCP_HOME_BANNER height:bannerHeight];
            }
        }
    }
    [self createCategoryCells];
    if(self.homeModel.productListCollection.count > 0){
        SimiSection *productListSection = [self.cells addSectionWithIdentifier:SCP_HOME_PRODUCT_LIST];
        for(SimiHomeProductListModel *productList in self.homeModel.productListCollection.collectionData){
            SimiRow *row = [productListSection addRowWithIdentifier:SCP_HOME_PRODUCT_LIST];
            row.model = productList;
        }
    }
}

- (void)createCategoryCells{
    if(self.categories.count > 0){
        for(SCPCategoryModel *category1 in self.categories){
            float paddingX1 = 0;
            float contentWidth = CGRectGetWidth(self.contentTableView.frame) - paddingX1;
            float imageWidth = category1.width;
            if(PADDEVICE){
                imageWidth = category1.widthTablet;
            }
            if(imageWidth == 0){
                imageWidth = contentWidth;
            }
            float scale = 0;
            if(imageWidth > 0){
                scale = contentWidth/imageWidth;
            }
            float imageHeight = category1.height;
            if(PADDEVICE){
                imageHeight = category1.heightTablet;
            }
            if(imageHeight == 0)
                imageHeight = 200;
            imageHeight *= scale;
            SimiSection *categorySection = [self.cells addSectionWithIdentifier:SCP_CATEGORY];
            categorySection.header = [[SimiSectionHeader alloc] initWithTitle:@"" height:imageHeight];
            categorySection.simiObjectIdentifier = category1;
            if(category1.isSelected && category1.hasChildren){
                SimiRow *row = [categorySection addRowWithIdentifier:SCP_CATEGORY_VIEW_ALL_PRODUCTS];
                row.model = category1;
                for(SCPCategoryModel *category2 in category1.subCategories){
                    SimiRow *row2 = [categorySection addRowWithIdentifier:SCP_CATEGORY];
                    row2.model = category2;
                    if(category2.isSelected && category2.hasChildren){
                        for(int i = 0;i<category2.subCategories.count;i++){
                            if(i < 3){
                                SCPCategoryModel *category3 = [category2.subCategories objectAtIndex:i];
                                SimiRow *row3 = [categorySection addRowWithIdentifier:SCP_CATEGORY];
                                row3.model = category3;
                            }
                        }
                        if(category2.subCategories.count > 3){
                            SimiRow *row = [categorySection addRowWithIdentifier:SCP_CATEGORY_VIEW_ALL_SUB_CATEGORIES];
                            row.model = category2;
                        }
                    }
                }
            }
        }
    }
}

- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if([row.identifier isEqualToString:SCP_HOME_LOADING]){
        UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
            float paddingX2 = CGRectGetWidth(self.contentTableView.frame) / 6 + 50;
            SimiLabel *loadingLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX2, 0, CGRectGetWidth(self.contentTableView.frame), row.height) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_LARGE andTextColor:SCP_ICON_COLOR text:@"Loadding ..."];
            [cell.contentView addSubview:loadingLabel];
        }
        return cell;
    }
    if([section.identifier isEqualToString:SCP_HOME_BANNER]){
        return [self addBannerCellForRow:row];
    }else if([section.identifier isEqualToString:SCP_CATEGORY]){
        if([row.identifier isEqualToString:SCP_CATEGORY]){
            return [self addCategoryCellForRow:row inSection:section];
        }else if([row.identifier isEqualToString:SCP_CATEGORY_VIEW_ALL_PRODUCTS]){
            return  [self addCategoryViewAllProductsCellForRow: row inSection:section];
        }else if([row.identifier isEqualToString:SCP_CATEGORY_VIEW_ALL_SUB_CATEGORIES]){
            return  [self addCategoryViewAllSubCategoriesCellForRow: row inSection:section];
        }
    }
    else if([section.identifier isEqualToString:SCP_HOME_PRODUCT_LIST]){
        return [self addProductListCellForRow:row];
    }
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    SimiSection *sec = [self.cells objectAtIndex:section];
    SCPCategoryModel *category = (SCPCategoryModel *)sec.simiObjectIdentifier;
    NSString *identifier = [NSString stringWithFormat:@"%@%@",SCP_CATEGORY,category.entityId];
    UITableViewHeaderFooterView *headerView = [self.contentTableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    if (!headerView) {
        headerView = [UITableViewHeaderFooterView new];
        float paddingX1 = 0;
        float contentWidth = CGRectGetWidth(self.contentTableView.frame) - 2*paddingX1;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(paddingX1, 0, contentWidth, sec.header.height)];
        button.simiObjectIdentifier = sec;
        [button addTarget:self action:@selector(didTapToCategoryImage:) forControlEvents:UIControlEventTouchUpInside];
        [button sd_setImageWithURL:[NSURL URLWithString:category.imageURL] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"logo"]];
        [button.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [headerView addSubview:button];
    }
    return headerView;
}
- (void)didTapToCategoryImage:(UIButton *)sender{
    SimiSection *section = (SimiSection *)sender.simiObjectIdentifier;
    SCPCategoryModel *category = (SCPCategoryModel *)section.simiObjectIdentifier;
    if([self isOpenedCMSPageWithCategory:category]){
        return;
    }
    if(category.hasChildren){
        if(category.isSelected){
            category.isSelected = NO;
            [self createCells];
            if(expandedRow1s.count){
                [self.contentTableView beginUpdates];
                [self.contentTableView deleteRowsAtIndexPaths:expandedRow1s withRowAnimation:UITableViewRowAnimationTop];
                [self.contentTableView endUpdates];
                [expandedRow1s removeAllObjects];
            }
        }else{
            for(SCPCategoryModel *cate in self.categories){
                if(![category isEqual:cate]){
                    if(cate.isSelected){
                        cate.isSelected = NO;
                    }
                }
                if(cate.hasChildren){
                    for(SCPCategoryModel *cate2 in cate.subCategories){
                        cate2.isSelected = NO;
                    }
                }
            }
            category.isSelected = YES;
            NSUInteger sectionIndex = [self.categories indexOfObject:category];
            if(phoneBanners.count){
                sectionIndex += 1;
            }
            [self createCells];
            [self.contentTableView beginUpdates];
            if(expandedRow1s.count){
                [self.contentTableView deleteRowsAtIndexPaths:expandedRow1s withRowAnimation:UITableViewRowAnimationTop];
                [expandedRow1s removeAllObjects];
            }
            SimiSection *sec = [self.cells objectAtIndex:sectionIndex];
            for(int i = 0; i < sec.count;i++){
                [expandedRow1s addObject:[NSIndexPath indexPathForRow:i inSection:sectionIndex]];
            }
            [self.contentTableView insertRowsAtIndexPaths:expandedRow1s withRowAnimation:UITableViewRowAnimationBottom];
            [self.contentTableView endUpdates];
            [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}
- (UITableViewCell *)addBannerCellForRow:(SimiRow *)row{
    UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        MatrixBannerScrollView* bannerScrollView = [[MatrixBannerScrollView alloc] initWithFrame:CGRectMake(0, 0 , SCREEN_WIDTH, row.height)];
        bannerScrollView.bannerItemPosition = Middle;
        bannerScrollView.isShowedItemsView = YES;
        bannerScrollView.selectedItemImage = [[UIImage imageNamed:@"scp_ic_banner_selected"] imageWithColor:SCP_ICON_COLOR];
        bannerScrollView.unselectedItemImage = [[UIImage imageNamed:@"scp_ic_banner_unselected"] imageWithColor:SCP_ICON_COLOR];
        bannerScrollView.banners = phoneBanners;
        if(PADDEVICE){
            if(padBanners.count >= 2){
                bannerScrollView = [[MatrixBannerScrollViewPad alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, row.height)];
            }
            bannerScrollView.banners = padBanners;
        }
        bannerScrollView.delegate = self;
        [cell.contentView addSubview:bannerScrollView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
- (UITableViewCell *)addCategoryCellForRow:(SimiRow *)row inSection:(SimiSection *)section{
    SCPCategoryModel *category = (SCPCategoryModel *)row.model;
    NSString *identifier = [NSString stringWithFormat:@"%@%@",SCP_CATEGORY,category.entityId];
    SCPHomeCategoryTextCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[SCPHomeCategoryTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier withCategory:category andWidth:CGRectGetWidth(self.contentTableView.frame)];
    }
    cell.isHighlight = category.isSelected;
    row.height = cell.heightCell;
    if(row == section.rows.lastObject){
        row.height += SCP_CATEGORY_TEXT_CELL_PADDING_TOP;
    }
    return cell;
}
- (UITableViewCell *)addCategoryViewAllSubCategoriesCellForRow:(SimiRow *)row inSection:(SimiSection *)section{
    SCPCategoryModel *category = (SCPCategoryModel *)row.model;
    NSString *identifier = [NSString stringWithFormat:@"%@%@",SCP_CATEGORY_VIEW_ALL_PRODUCTS,category.entityId];
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.heightCell = SCP_CATEGORY_TEXT_CELL_PADDING_TOP;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        float paddingX2 = CGRectGetWidth(self.contentTableView.frame) / 6 + 50;
        float contentWidth = CGRectGetWidth(self.contentTableView.frame) - paddingX2;
        SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX2, cell.heightCell, contentWidth, 25) andFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:FONT_SIZE_MEDIUM]];
        label.text = @"View all";
        label.textColor = SCP_ICON_COLOR;
        [label sizeToFit];
        [cell.contentView addSubview:label];
        cell.heightCell += CGRectGetHeight(label.frame);
    }
    row.height = cell.heightCell;
    if(row == section.rows.lastObject){
        row.height += SCP_CATEGORY_TEXT_CELL_PADDING_TOP;
    }
    return cell;
}
- (UITableViewCell *)addCategoryViewAllProductsCellForRow:(SimiRow *)row inSection:(SimiSection *)section{
    SCPCategoryModel *category = (SCPCategoryModel *)row.model;
    NSString *identifier = [NSString stringWithFormat:@"%@%@",SCP_CATEGORY_VIEW_ALL_PRODUCTS,category.entityId];
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        float paddingX1 = CGRectGetWidth(self.contentTableView.frame) / 6;
        cell.heightCell = SCP_CATEGORY_TEXT_CELL_PADDING_TOP;
        float contentWidth = CGRectGetWidth(self.contentTableView.frame) - paddingX1;
        SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX1, cell.heightCell, contentWidth, 25) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_LARGE andTextColor:SCP_ICON_COLOR text:@"All Products"];
        [cell.contentView addSubview:label];
        [label sizeToFit];
        cell.heightCell += CGRectGetHeight(label.frame);
    }
    row.height = cell.heightCell;
    if(row == section.rows.lastObject){
        row.height += SCP_CATEGORY_TEXT_CELL_PADDING_TOP;
    }
    return cell;
}
- (UITableViewCell *)addProductListCellForRow:(SimiRow *)row{
    SimiHomeProductListModel *productList = (SimiHomeProductListModel *)row.model;
    NSString *identifier = [NSString stringWithFormat:@"%@%@",SCP_HOME_PRODUCT_LIST,productList.productListId];
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        float contentWidth = CGRectGetWidth(self.contentTableView.frame);
        float imageWidth = productList.width;
        if(PADDEVICE){
            imageWidth = productList.widthTablet;
        }
        float scale = 0;
        if(imageWidth > 0){
            scale = contentWidth/imageWidth;
        }
        float imageHeight = productList.height;
        imageWidth = contentWidth;
        if(PADDEVICE){
            imageHeight = productList.heightTablet;
        }
        imageHeight *= scale;
        cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.heightCell = 0;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, cell.heightCell, imageWidth, imageHeight)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:PHONEDEVICE?productList.imageURL:productList.imageURLPad] placeholderImage:[UIImage imageNamed:@"logo"]];
        [cell.contentView addSubview:imageView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.heightCell += imageHeight;
    }
    row.height = cell.heightCell;
    return cell;
}
- (void)contentTableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    SCPCategoryModel *category = (SCPCategoryModel *)row.model;
    if([self isOpenedCMSPageWithCategory:category]){
        return;
    }
    if([section.identifier isEqualToString:SCP_CATEGORY]){
        if([row.identifier isEqualToString:SCP_CATEGORY]){
            SCPCategoryModel *parentCategory = category.parentCategory;
            NSInteger sectionIndex = 0;
            if([self.categories containsObject:parentCategory]){
                sectionIndex = [self.categories indexOfObject:parentCategory];
                if(phoneBanners.count){
                    sectionIndex += 1;
                }
            }
            if(category.hasChildren){
                switch (category.level) {
                    case CategoryLevelTwo:{
                        if(category.isSelected){
                            category.isSelected = NO;
                        }else{
                            category.isSelected = YES;
                            SCPCategoryModel *parent = category.parentCategory;
                            for(SCPCategoryModel *cate in parent.subCategories){
                                if(![cate isEqual:category]){
                                    cate.isSelected = NO;
                                }
                            }
                            if(!category.subCategories){
                                [section addRowWithIdentifier:SCP_HOME_LOADING height:44 sortOrder:row.sortOrder + 1];
                                [section sortItems];
                                NSInteger rowIndex = [section.rows indexOfObject:row];
                                loadingRow = [NSIndexPath indexPathForRow:rowIndex + 1 inSection:sectionIndex];
                                [self.contentTableView beginUpdates];
                                [self.contentTableView insertRowsAtIndexPaths:@[loadingRow] withRowAnimation:UITableViewRowAnimationBottom];
                                [self.contentTableView endUpdates];
                                [self getSubCategoriesOfCategory:category withLevel:@"0"];
                                return;
                            }
                        }
                        [self initCells];
                        [expandedRow1s removeAllObjects];
                        SimiSection *sec = [self.cells objectAtIndex:sectionIndex];
                        for(int i = 0; i < sec.count;i++){
                            [expandedRow1s addObject:[NSIndexPath indexPathForRow:i inSection:sectionIndex]];
                        }
                    }
                        break;
                    case CategoryLevelThree:{
                        SCPCategoryViewController *categoryVC = [SCPCategoryViewController new];
                        categoryVC.categoryModel = [[SCPCategoryModel alloc] initWithModelData:category.modelData];
                        [self.navigationController pushViewController:categoryVC animated:YES];
                    }
                        break;
                    default:
                        break;
                }
            }else{
                //Open list product
                SCPProductsViewController *productsViewController = [SCPProductsViewController new];
                if (PADDEVICE) {
                    productsViewController = [SCPPadProductsViewController new];
                }
                productsViewController.productListGetProductType = ProductListGetProductTypeFromCategory;
                productsViewController.categoryID = category.entityId;
                productsViewController.nameOfProductList = category.name;
                [self.navigationController pushViewController:productsViewController animated:YES];
            }
        }else if([row.identifier isEqualToString:SCP_CATEGORY_VIEW_ALL_PRODUCTS]){
            SCPProductsViewController *productsViewController = [SCPProductsViewController new];
            if (PADDEVICE) {
                productsViewController = [SCPPadProductsViewController new];
            }
            productsViewController.productListGetProductType = ProductListGetProductTypeFromCategory;
            productsViewController.categoryID = category.entityId;
            productsViewController.nameOfProductList = category.name;
            [self.navigationController pushViewController:productsViewController animated:YES];
            //Open list product
        }else if([row.identifier isEqualToString:SCP_CATEGORY_VIEW_ALL_SUB_CATEGORIES]){
            SCPCategoryViewController *categoryVC = [SCPCategoryViewController new];
            categoryVC.isSubCategory = YES;
            categoryVC.categoryModel = category;
            [self.navigationController pushViewController:categoryVC animated:YES];
        }
    }
    else if([section.identifier isEqualToString:SCP_HOME_PRODUCT_LIST]){
        //Open list product
        SimiHomeProductListModel *productListModel = (SimiHomeProductListModel*)row.model;
        SCPProductsViewController *productsViewController = [SCPProductsViewController new];
        if (PADDEVICE) {
            productsViewController = [SCPPadProductsViewController new];
        }
        productsViewController.productListGetProductType = ProductListGetProductTypeFromSpot;
        productsViewController.spotID = productListModel.entityId ;
        productsViewController.nameOfProductList = productListModel.title;
        [self.navigationController pushViewController:productsViewController animated:YES];
    }
}
#pragma mark MatrixBannerScrollViewDelegate
- (void)didTapInBanner:(SimiHomeBannerModel *)banner{
    if (banner.type == BannerCategoryInApp) {
        SCPProductsViewController *productsVC = [SCPProductsViewController new];
        if (PADDEVICE) {
            productsVC = [SCPPadProductsViewController new];
        }
        productsVC.categoryID = banner.categoryId;
        productsVC.nameOfProductList = banner.categoryName;
        [self.navigationController pushViewController:productsVC animated:YES];
    }else if(banner.type == BannerProductInApp){
        SCProductViewController *productVC = [SCPProductViewController new];
        productVC.productId = banner.productId;
        [self.navigationController pushViewController:productVC animated:YES];
    }else if(banner.type == BannerWebsitePage) {
        [[SCAppController sharedInstance] openURL:banner.bannerURL withNavigationController:self.navigationController];
    }
}
- (BOOL)isOpenedCMSPageWithCategory:(SCPCategoryModel *)category{
    if (GLOBALVAR.storeView.categoryCmspages) {
        NSArray *categoryCMSPages = GLOBALVAR.storeView.categoryCmspages;
        for (int i = 0; i < categoryCMSPages.count; i++) {
            NSDictionary *categoryCMSPageUnit = [categoryCMSPages objectAtIndex:i];
            if ([[NSString stringWithFormat:@"%@",[categoryCMSPageUnit valueForKey:@"category_id"]] isEqualToString:category.entityId] && [[categoryCMSPageUnit objectForKey:@"cms_status"] boolValue]) {
                SCPProductsViewController *productsVC = [SCPProductsViewController new];
                productsVC.categoryID = category.entityId;
                [self.navigationController pushViewController:productsVC animated:YES];
                return YES;
            }
        }
    }
    return NO;
}
@end
@implementation SCPHomeCategoryTextCell{
    SimiLabel *label;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCategory:(SCPCategoryModel *)category andWidth:(CGFloat)width{
    if(self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        _category = category;
        float paddingX2 = width / 6;
        float paddingX3 = paddingX2 + 50;
        float contentWidth;
        self.heightCell = SCP_CATEGORY_TEXT_CELL_PADDING_TOP;
        switch (category.level) {
            case CategoryLevelTwo:{
                contentWidth = width - paddingX2;
                label = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX2, self.heightCell, contentWidth, 25) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_LARGE andTextColor:SCP_ICON_COLOR text:category.name];
                if(category.isSelected){
                    label.textColor = SCP_ICON_HIGHLIGHT_COLOR;
                }
                [label sizeToFit];
                [self.contentView addSubview:label];
                self.heightCell += CGRectGetHeight(label.frame);
            }
                break;
            case CategoryLevelThree:{
                contentWidth = width - paddingX3;
                label = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX3, self.heightCell, contentWidth, 25) andFontName:THEME_FONT_NAME andFontSize:FONT_SIZE_MEDIUM andTextColor:SCP_ICON_COLOR text:category.name];
                [label sizeToFit];
                [self.contentView addSubview:label];
                self.heightCell += CGRectGetHeight(label.frame);
            }
                break;
            default:
                break;
        }
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}
- (void)setIsHighlight:(BOOL)isHighlight{
    _isHighlight = isHighlight;
    if(isHighlight){
        label.textColor = SCP_ICON_HIGHLIGHT_COLOR;
    }else{
        label.textColor = SCP_ICON_COLOR;
    }
}
@end
