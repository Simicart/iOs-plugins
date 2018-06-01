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
#import "SCPSubCategoryViewController.h"


@interface SCPHomeViewController ()
@property (strong, nonatomic) SimiHomeModel *homeModel;
@end

@implementation SCPHomeViewController{
    SimiHomeBannerModelCollection *phoneBanners;
    SimiHomeBannerModelCollection *padBanners;
}

- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    self.contentTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.contentTableView.showsVerticalScrollIndicator = NO;
    self.contentTableView.backgroundColor = [UIColor clearColor];
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.contentTableView.tableFooterView = [UIView new];
    [self.view addSubview:self.contentTableView];
    expandedRow1s = [NSMutableArray new];
    expandedRow2s = [NSMutableArray new];
    [self getPageData];
}
- (void)viewDidAppearBefore:(BOOL)animated{
    [super viewDidAppearBefore:animated];
    self.contentTableView.frame = self.view.bounds;
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

- (void)getSubCategoriesOfCategory:(SCPCategoryModel *)category level:(NSString *)level{
    self.contentTableView.userInteractionEnabled = NO;
    currentCategory = category;
    SCPCategoryModelCollection *cateCollection = [SCPCategoryModelCollection new];
    [cateCollection getSubCategoriesWithId:category.entityId level:level];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetSubCategories:) name:Simi_DidGetCategoryCollection object:nil];
}

- (void)didGetHomeData:(NSNotification *)noti{
    if ([noti.name isEqualToString:Simi_DidGetHomeData]){
        [self removeObserverForNotification:noti];
        [self stopLoadingData];
        self.contentTableView.hidden = NO;
        SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
        if (responder.status == SUCCESS) {
            [self initShowableBanners];
            [self initCategories];
            [self initCells];
        }else {
            [self showToastMessage:responder.message duration:2];
        }
    }
}

- (void)didGetSubCategories:(NSNotification *)noti{
    [self removeObserverForNotification:noti];
    self.contentTableView.userInteractionEnabled = YES;
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        [self initSubCategories:noti.object];
        SimiSection *section = [self.cells objectAtIndex:loadingRowIndex.section];
        SimiRow *row = [section objectAtIndex:loadingRowIndex.row];
        [section removeRow:row];
        if(loadingRowIndex){
            [self.contentTableView beginUpdates];
            [self.contentTableView deleteRowsAtIndexPaths:@[loadingRowIndex] withRowAnimation:UITableViewRowAnimationFade];
            loadingRowIndex = nil;
            [self.contentTableView endUpdates];
        }
        [self createCells];
        [self.contentTableView beginUpdates];
        if(expandedRow2s.count){
            [self.contentTableView deleteRowsAtIndexPaths:expandedRow2s withRowAnimation:UITableViewRowAnimationFade];
            [expandedRow2s removeAllObjects];
        }
        
        NSInteger sectionIndex = [self.categories indexOfObject:currentCategory.parentCategory];
        if([self.cells getSectionByIdentifier:SCP_HOME_BANNER]){
            sectionIndex += 1;
        }
        SimiSection *sec = [self.cells objectAtIndex:sectionIndex];
        [expandedRow1s removeAllObjects];
        for(int i = 0;i<sec.rows.count;i++){
            SimiRow *row = [sec objectAtIndex:i];
            SCPCategoryModel *cate = (SCPCategoryModel *)row.model;
            if(cate.level == CategoryLevelThree || [row.identifier isEqualToString:SCP_CATEGORY_VIEW_ALL_SUB_CATEGORIES]){
                [expandedRow2s addObject:[NSIndexPath indexPathForRow:i inSection:sectionIndex]];
            }
            [expandedRow1s addObject:[NSIndexPath indexPathForRow:i inSection:sectionIndex]];
        }
        [self.contentTableView insertRowsAtIndexPaths:expandedRow2s withRowAnimation:UITableViewRowAnimationFade];
        [self.contentTableView endUpdates];
        [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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

- (void)initCategories{
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
    [self createBannerCell];
    [self createCategoryCells];
    [self createProductListCells];
}

- (void)createBannerCell{
    if((PHONEDEVICE && phoneBanners.count) || (PADDEVICE && padBanners.count)){
        SimiSection *bannerSection = [self.cells addSectionWithIdentifier:SCP_HOME_BANNER];
        bannerSection.header = [[SimiSectionHeader alloc] initWithTitle:@"" height:SCREEN_WIDTH/2];
    }
}
- (void)createCategoryCells{
    if(self.categories.count > 0){
        for(SCPCategoryModel *category1 in self.categories){
            float contentWidth = CGRectGetWidth(self.contentTableView.frame) - SCP_CATEGORY1_PADDING_X;
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
            if(imageHeight <= 0)
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
                        SimiRow *row = [categorySection addRowWithIdentifier:SCP_CATEGORY_VIEW_ALL_SUB_CATEGORIES];
                        row.model = category2;
                    }
                }
            }
        }
    }
}

- (void)createProductListCells{
    if(self.homeModel.productListCollection.count > 0){
        for(SimiHomeProductListModel *productList in self.homeModel.productListCollection.collectionData){
            SimiSection *productListSection = [self.cells addSectionWithIdentifier:SCP_HOME_PRODUCT_LIST];
            productListSection.simiObjectIdentifier = productList;
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
            if(imageHeight <= 0)
                imageHeight = 200;
            imageHeight *= scale;
            productListSection.header = [[SimiSectionHeader alloc] initWithTitle:@"" height:imageHeight];
        }
    }
}
- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    if([section.identifier isEqualToString:SCP_CATEGORY]){
        if([row.identifier isEqualToString:SCP_CATEGORY_LOADING]){
            cell = [self addCategoryLoadingCellForRow:row];
        }else if([row.identifier isEqualToString:SCP_CATEGORY]){
            cell = [self addCategoryCellForRow:row inSection:section];
        }else if([row.identifier isEqualToString:SCP_CATEGORY_VIEW_ALL_PRODUCTS]){
            cell =  [self addCategoryViewAllProductsCellForRow: row inSection:section];
        }else if([row.identifier isEqualToString:SCP_CATEGORY_VIEW_ALL_SUB_CATEGORIES]){
            cell =  [self addCategoryViewAllSubCategoriesCellForRow: row inSection:section];
        }
    }
    return cell;
}

- (UITableViewCell *)addCategoryCellForRow:(SimiRow *)row inSection:(SimiSection *)section{
    SCPCategoryModel *category = (SCPCategoryModel *)row.model;
    NSString *identifier = @"tableViewCell";
    SCPCategoryTextCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[SCPCategoryTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier andWidth:CGRectGetWidth(self.contentTableView.frame)];
    }
    cell.category = category;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if([section.identifier isEqualToString:SCP_CATEGORY]){
        if(indexPath.row == 0 || [section.rows indexOfObject:row] == section.count  -1){
            return SCP_CATEGORY_TEXT_CELL_HEIGHT + SCP_CATEGORY_TEXT_CELL_PADDING_TOP;
        }
        return SCP_CATEGORY_TEXT_CELL_HEIGHT;
    }else{
        return row.height;
    }
}
- (UITableViewCell *)addCategoryViewAllSubCategoriesCellForRow:(SimiRow *)row inSection:(SimiSection *)section{
    SCPCategoryModel *category = (SCPCategoryModel *)row.model;
    NSString *identifier = [NSString stringWithFormat:@"%@%@",SCP_CATEGORY_VIEW_ALL_SUB_CATEGORIES,category.entityId];
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        float contentWidth = CGRectGetWidth(self.contentTableView.frame) - SCP_CATEGORY3_PADDING_X;
        SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(SCP_CATEGORY3_PADDING_X, 0, contentWidth, SCP_CATEGORY_TEXT_CELL_HEIGHT) andFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:FONT_SIZE_LARGE]];
        label.text = @"View all";
        label.textColor = SCP_ICON_COLOR;
        [cell.contentView addSubview:label];
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
        float contentWidth = CGRectGetWidth(self.contentTableView.frame) - SCP_CATEGORY2_PADDING_X;
        SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(SCP_CATEGORY2_PADDING_X, SCP_CATEGORY_TEXT_CELL_PADDING_TOP, contentWidth, SCP_CATEGORY_TEXT_CELL_HEIGHT) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_LARGE andTextColor:SCP_ICON_COLOR text:@"All Products"];
        [cell.contentView addSubview:label];
    }
    return cell;
}
- (UITableViewCell *)addCategoryLoadingCellForRow:(SimiRow *)row{
   UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(SCP_CATEGORY3_PADDING_X, 0, row.height, row.height)];
    loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [loadingView startAnimating];
    [cell.contentView addSubview:loadingView];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    SimiSection *sec = [self.cells objectAtIndex:section];
    if([sec.identifier isEqualToString:SCP_CATEGORY]){
        return [self addCategoryHeaderViewInSection:sec];
    }else if([sec.identifier isEqualToString:SCP_HOME_PRODUCT_LIST]){
        return [self addProductListHeaderViewInSection:sec];
    }else if([sec.identifier isEqualToString:SCP_HOME_BANNER]){
        return [self addBannerHeaderViewInSection:sec];
    }
    return nil;
}
- (UITableViewHeaderFooterView *)addBannerHeaderViewInSection:(SimiSection *)section{
    UITableViewHeaderFooterView *headerView = [self.contentTableView dequeueReusableHeaderFooterViewWithIdentifier:section.identifier];
    if (!headerView) {
        headerView = [UITableViewHeaderFooterView new];
        MatrixBannerScrollView* bannerScrollView = [[MatrixBannerScrollView alloc] initWithFrame:CGRectMake(0, 0 , SCREEN_WIDTH, section.header.height)];
        bannerScrollView.bannerItemPosition = Middle;
        bannerScrollView.isShowedItemsView = YES;
        bannerScrollView.selectedItemImage = [[UIImage imageNamed:@"scp_ic_banner_selected"] imageWithColor:COLOR_WITH_HEX(@"#838383")];
        bannerScrollView.unselectedItemImage = [[UIImage imageNamed:@"scp_ic_banner_unselected"] imageWithColor:COLOR_WITH_HEX(@"#838383")];
        if(PHONEDEVICE)
            bannerScrollView.banners = phoneBanners;
        else if(PADDEVICE)
            bannerScrollView.banners = padBanners;
        bannerScrollView.delegate = self;
        [headerView addSubview:bannerScrollView];
    }
    return headerView;
}
- (UITableViewHeaderFooterView *)addCategoryHeaderViewInSection:(SimiSection *)section{
    SCPCategoryModel *category = (SCPCategoryModel *)section.simiObjectIdentifier;
    NSString *identifier = [NSString stringWithFormat:@"%@%@",SCP_CATEGORY,category.entityId];
    UITableViewHeaderFooterView *headerView = [self.contentTableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    if (!headerView) {
        headerView = [UITableViewHeaderFooterView new];
        float contentWidth = CGRectGetWidth(self.contentTableView.frame) - 2*SCP_CATEGORY1_PADDING_X;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCP_CATEGORY1_PADDING_X, 0, contentWidth, section.header.height)];
        imageView.simiObjectIdentifier = section;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapToCategoryImage:)]];
        imageView.userInteractionEnabled = YES;
        [imageView sd_setImageWithURL:[NSURL URLWithString:PHONEDEVICE?category.imageURL:category.imageURLPad] placeholderImage:[UIImage imageNamed:@"logo"]];
        [imageView setContentMode: UIViewContentModeScaleAspectFill];
        imageView.clipsToBounds = YES;
        [headerView addSubview:imageView];
    }
    return headerView;
}

- (UITableViewHeaderFooterView *)addProductListHeaderViewInSection:(SimiSection *)section{
    SimiHomeProductListModel *productList = (SimiHomeProductListModel *)section.simiObjectIdentifier;
    NSString *identifier = [NSString stringWithFormat:@"%@%@",SCP_HOME_PRODUCT_LIST,productList.entityId];
    UITableViewHeaderFooterView *headerView = [self.contentTableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    if (!headerView) {
        headerView = [UITableViewHeaderFooterView new];
        headerView = [UITableViewHeaderFooterView new];
        float contentWidth = CGRectGetWidth(self.contentTableView.frame) - 2*SCP_CATEGORY1_PADDING_X;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCP_CATEGORY1_PADDING_X, 0, contentWidth, section.header.height)];
        imageView.simiObjectIdentifier = section;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapToProductListImage:)]];
        imageView.userInteractionEnabled = YES;
        [imageView sd_setImageWithURL:[NSURL URLWithString:PHONEDEVICE?productList.imageURL:productList.imageURLPad] placeholderImage:[UIImage imageNamed:@"logo"]];
        [imageView setContentMode: UIViewContentModeScaleAspectFill];
        imageView.clipsToBounds = YES;
        [headerView addSubview:imageView];
    }
    return headerView;
}

- (void)didTapToCategoryImage:(UIGestureRecognizer *)sender{
    UIImageView *imageView = (UIImageView *)sender.view;
    SimiSection *section = (SimiSection *)imageView.simiObjectIdentifier;
    SCPCategoryModel *category = (SCPCategoryModel *)section.simiObjectIdentifier;
    if([self isOpenedCMSPageWithCategory:category]){
        return;
    }
    if(category.hasChildren){
        if(category.isSelected){
            category.isSelected = NO;
            if(expandedRow2s.count){
                [expandedRow2s removeAllObjects];
            }
            if(expandedRow1s.count){
                [self createCells];
                [self.contentTableView beginUpdates];
                [self.contentTableView deleteRowsAtIndexPaths:expandedRow1s withRowAnimation:UITableViewRowAnimationFade];
                [self.contentTableView endUpdates];
                NSInteger sectionIndex = [self.categories indexOfObject:category];
                if([self.cells getSectionByIdentifier:SCP_HOME_BANNER]){
                    sectionIndex += 1;
                }
                [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
            NSInteger sectionIndex = [self.categories indexOfObject:category];
            if([self.cells getSectionByIdentifier:SCP_HOME_BANNER]){
                sectionIndex += 1;
            }
            [self.contentTableView beginUpdates];
            if(expandedRow1s.count){
                [self.contentTableView deleteRowsAtIndexPaths:expandedRow1s withRowAnimation:UITableViewRowAnimationFade];
                [expandedRow1s removeAllObjects];
            }
            [expandedRow2s removeAllObjects];
            [self createCells];
            SimiSection *sec = [self.cells objectAtIndex:sectionIndex];
            for(int i = 0; i < sec.count;i++){
                [expandedRow1s addObject:[NSIndexPath indexPathForRow:i inSection:sectionIndex]];
            }
            [self.contentTableView insertRowsAtIndexPaths:expandedRow1s withRowAnimation:UITableViewRowAnimationFade];
            [self.contentTableView endUpdates];
            [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
        }
    }
}
- (void)didTapToProductListImage:(UIGestureRecognizer *)sender{
    UIImageView *imageView = (UIImageView *)sender.view;
    SimiSection *section = (SimiSection *)imageView.simiObjectIdentifier;
    SimiHomeProductListModel *productListModel = (SimiHomeProductListModel*)section.simiObjectIdentifier;
    [self openProductListWithProductList:productListModel];
}
- (void)contentTableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    if([section.identifier isEqualToString:SCP_CATEGORY]){
        [self didSelectCategoryCellAtIndexPath:indexPath];
    }
}
- (void)didSelectCategoryCellAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    SCPCategoryModel *category = (SCPCategoryModel *)row.model;
    if([self isOpenedCMSPageWithCategory:category]){
        return;
    }
    if([row.identifier isEqualToString:SCP_CATEGORY]){
        SCPCategoryModel *parentCategory = category.parentCategory;
        NSInteger sectionIndex = 0;
        if(category.level == CategoryLevelTwo){
            sectionIndex = [self.categories indexOfObject:parentCategory];
        }
        if(category.level == CategoryLevelThree){
            SCPCategoryModel *grandCategory = parentCategory.parentCategory;
            sectionIndex = [self.categories indexOfObject:grandCategory];
        }
        if([self.cells getSectionByIdentifier:SCP_HOME_BANNER]){
            sectionIndex += 1;
        }
        if(category.hasChildren){
            switch (category.level) {
                case CategoryLevelTwo:{
                    if(category.isSelected){
                        category.isSelected = NO;
                        [self.contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        if(expandedRow2s.count){
                            [self createCells];
                            [self.contentTableView beginUpdates];
                            [self.contentTableView deleteRowsAtIndexPaths:expandedRow2s withRowAnimation:UITableViewRowAnimationFade];
                            [self.contentTableView endUpdates];
                            [expandedRow2s removeAllObjects];
                            [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                            SimiSection *sec = [self.cells objectAtIndex:sectionIndex];
                            [expandedRow1s removeAllObjects];
                            for(int i = 0;i<sec.rows.count;i++){
                                [expandedRow1s addObject:[NSIndexPath indexPathForRow:i inSection:sectionIndex]];
                            }
                        }
                    }else{
                        category.isSelected = YES;
                        SCPCategoryModel *parent = category.parentCategory;
                        NSInteger rowIndex = 0;
                        for(int i = 0; i < parent.subCategories.count; i++){
                            SCPCategoryModel *cate = [parent.subCategories objectAtIndex:i];
                            if(![cate isEqual:category] && cate.isSelected){
                                cate.isSelected = NO;
                                rowIndex = i + 1;
                                break;
                            }
                        }
                        NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath];
                        if(rowIndex > 0){
                            [indexPaths addObject:[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]];
                        }
                        [self.contentTableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        
                        if(!category.subCategories){
                            [section addRowWithIdentifier:SCP_CATEGORY_LOADING height:SCP_CATEGORY_TEXT_CELL_HEIGHT sortOrder:row.sortOrder + 1];
                            [section sortItems];
                            NSInteger rowIndex = [section.rows indexOfObject:row];
                            loadingRowIndex = [NSIndexPath indexPathForRow:rowIndex + 1 inSection:sectionIndex];
                            [self.contentTableView beginUpdates];
                            [self.contentTableView insertRowsAtIndexPaths:@[loadingRowIndex] withRowAnimation:UITableViewRowAnimationFade];
                            [self.contentTableView endUpdates];
                            [self getSubCategoriesOfCategory:category level:@"0"];
                            return;
                        }
                        [self createCells];
                        [self.contentTableView beginUpdates];
                        if(expandedRow2s.count){
                            [self.contentTableView deleteRowsAtIndexPaths:expandedRow2s withRowAnimation:UITableViewRowAnimationFade];
                            [expandedRow2s removeAllObjects];
                        }
                        SimiSection *sec = [self.cells objectAtIndex:sectionIndex];
                        [expandedRow1s removeAllObjects];
                        for(int i = 0;i<sec.rows.count;i++){
                            SimiRow *row = [sec objectAtIndex:i];
                            SCPCategoryModel *cate = (SCPCategoryModel *)row.model;
                            if(cate.level == CategoryLevelThree || [row.identifier isEqualToString:SCP_CATEGORY_VIEW_ALL_SUB_CATEGORIES]){
                                [expandedRow2s addObject:[NSIndexPath indexPathForRow:i inSection:sectionIndex]];
                            }
                            [expandedRow1s addObject:[NSIndexPath indexPathForRow:i inSection:sectionIndex]];
                        }
                        [self.contentTableView insertRowsAtIndexPaths:expandedRow2s withRowAnimation:UITableViewRowAnimationFade];
                        [self.contentTableView endUpdates];
                        [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    }
                }
                    break;
                case CategoryLevelThree:{
                    [self openSubCategoryPageWithCategory:category];
                }
                    break;
                default:
                    break;
            }
        }else{
            if(category.level == CategoryLevelTwo){
                SCPCategoryModel *parent = category.parentCategory;
                NSInteger rowIndex = 0;
                for(int i = 0; i < parent.subCategories.count; i++){
                    SCPCategoryModel *cate = [parent.subCategories objectAtIndex:i];
                    if(![cate isEqual:category] && cate.isSelected){
                        cate.isSelected = NO;
                        rowIndex = i + 1;
                        break;
                    }
                }
                if(rowIndex > 0){
                    [self.contentTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]] withRowAnimation:UITableViewRowAnimationFade];
                }
                if(expandedRow2s.count){
                    [self createCells];
                    [self.contentTableView beginUpdates];
                    [self.contentTableView deleteRowsAtIndexPaths:expandedRow2s withRowAnimation:UITableViewRowAnimationFade];
                    [self.contentTableView endUpdates];
                    [expandedRow2s removeAllObjects];
                    [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    SimiSection *sec = [self.cells objectAtIndex:sectionIndex];
                    [expandedRow1s removeAllObjects];
                    for(int i = 0;i<sec.rows.count;i++){
                        [expandedRow1s addObject:[NSIndexPath indexPathForRow:i inSection:sectionIndex]];
                    }
                }
            }
            [self openProductListWithCategory:category];
        }
    }else if([row.identifier isEqualToString:SCP_CATEGORY_VIEW_ALL_PRODUCTS]){
        SCPCategoryModel *parentCategory = (SCPCategoryModel *)section.simiObjectIdentifier;
        NSInteger sectionIndex = [self.categories indexOfObject:parentCategory];
        if([self.cells getSectionByIdentifier:SCP_HOME_BANNER]){
            sectionIndex += 1;
        }
        NSInteger rowIndex = 0;
        for(int i = 0; i < parentCategory.subCategories.count; i++){
            SCPCategoryModel *cate = [parentCategory.subCategories objectAtIndex:i];
            if(![cate isEqual:category] && cate.isSelected){
                cate.isSelected = NO;
                rowIndex = i + 1;
                break;
            }
        }
        if(rowIndex > 0){
            [self.contentTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]] withRowAnimation:UITableViewRowAnimationFade];
        }
        if(expandedRow2s.count){
            [self createCells];
            [self.contentTableView beginUpdates];
            [self.contentTableView deleteRowsAtIndexPaths:expandedRow2s withRowAnimation:UITableViewRowAnimationFade];
            [self.contentTableView endUpdates];
            [expandedRow2s removeAllObjects];
            [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            SimiSection *sec = [self.cells objectAtIndex:sectionIndex];
            [expandedRow1s removeAllObjects];
            for(int i = 0;i<sec.rows.count;i++){
                [expandedRow1s addObject:[NSIndexPath indexPathForRow:i inSection:sectionIndex]];
            }
        }
        [self openProductListWithCategory:category];
    }else if([row.identifier isEqualToString:SCP_CATEGORY_VIEW_ALL_SUB_CATEGORIES]){
        [self openSubCategoryPageWithCategory:category];
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
- (void)openProductListWithProductList:(SimiHomeProductListModel *)productListModel{
    SCPProductsViewController *productsViewController = [SCPProductsViewController new];
    if (PADDEVICE) {
        productsViewController = [SCPPadProductsViewController new];
    }
    productsViewController.productListGetProductType = ProductListGetProductTypeFromSpot;
    productsViewController.spotID = productListModel.productListId;
    productsViewController.nameOfProductList = productListModel.title;
    [self.navigationController pushViewController:productsViewController animated:YES];
}
- (void)openProductListWithCategory:(SCPCategoryModel *)category{
    SCPProductsViewController *productsViewController = [SCPProductsViewController new];
    if (PADDEVICE) {
        productsViewController = [SCPPadProductsViewController new];
    }
    productsViewController.productListGetProductType = ProductListGetProductTypeFromCategory;
    productsViewController.categoryID = category.entityId;
    productsViewController.nameOfProductList = category.name;
    [self.navigationController pushViewController:productsViewController animated:YES];
}

- (void)openSubCategoryPageWithCategory:(SCPCategoryModel *)category{
    SCPSubCategoryViewController *subCateVC = [SCPSubCategoryViewController new];
    subCateVC.categoryModel = category;
    [self.navigationController pushViewController:subCateVC animated:YES];
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
@implementation SCPCategoryTextCell{
    SimiLabel *label;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWidth:(CGFloat)width{
    _width = width;
    if(self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor whiteColor];
        label = [[SimiLabel alloc] initWithFrame:CGRectMake(0, self.heightCell, width, 25)];
        [self.contentView addSubview:label];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setCategory:(SCPCategoryModel *)category{
    _category = category;
    float contentWidth;
    switch (category.level) {
        case CategoryLevelTwo:{
            contentWidth = _width - SCP_CATEGORY2_PADDING_X;
            label.frame = CGRectMake(SCP_CATEGORY2_PADDING_X, 0, contentWidth, SCP_CATEGORY_TEXT_CELL_HEIGHT);
            label.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:FONT_SIZE_LARGE];
            label.text = category.name;
            if(category.isSelected){
                label.textColor = SCP_ICON_HIGHLIGHT_COLOR;
            }else{
                label.textColor = SCP_ICON_COLOR;
            }
        }
            break;
        case CategoryLevelThree:{
            contentWidth = _width - SCP_CATEGORY3_PADDING_X;
            label.frame = CGRectMake(SCP_CATEGORY3_PADDING_X, 0, contentWidth, SCP_CATEGORY_TEXT_CELL_HEIGHT);
            label.font = [UIFont fontWithName:THEME_FONT_NAME size:FONT_SIZE_LARGE];
            label.text = category.name;
            label.textColor = SCP_ICON_COLOR;
        }
            break;
        default:
            break;
    }
}
@end
