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
#import "SCPCategoryModel.h"
#import "SCPProductViewController.h"
#import "SimiHomeModel+SCP.h"

#define SCP_HOME_BANNER @"SCP_HOME_BANNER"
#define SCP_HOME_CATEGORY @"SCP_HOME_CATEGORY"
#define SCP_HOME_CATEGORY_VIEW_ALL @"SCP_HOME_CATEGORY_VIEW_ALL"
#define SCP_HOME_PRODUCT_LIST @"SCP_HOME_PRODUCT_LIST"

@interface SCPHomeViewController ()
@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) SimiHomeModel *homeModel;
@end

@implementation SCPHomeViewController{
    SimiHomeBannerModelCollection *phoneBanners;
    SimiHomeBannerModelCollection *padBanners;
}
- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    self.contentTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    self.contentTableView.tableFooterView = [UIView new];
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.contentTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.contentTableView];
    self.contentTableView.hidden = YES;
    [self getHomeDataLiteWithChildCat];
}

- (void)getHomeDataLiteWithChildCat{
    self.homeModel = [[SimiHomeModel alloc]init];
    [self.homeModel getHomeDataWithParams:@{@"get_child_cat":@"2"}];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetHomeData:) name:Simi_DidGetHomeData object:self.homeModel];
    [self startLoadingData];
}
- (void)didGetHomeData:(NSNotification *)noti{
    if ([noti.name isEqualToString:Simi_DidGetHomeData]){
        [self removeObserverForNotification:noti];
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
        category1.level = HomeCategoryLevelOne;
        category1.isSelected = NO;
        category1.parentCategory = nil;
        if(category1.hasChildren){
            for(SCPHomeCategoryModel *category2 in category1.subCategories){
                category2.level = HomeCategoryLevelTwo;
                category2.isSelected = NO;
                category2.parentCategory = category1;
                if(category2.hasChildren){
                    for(SCPHomeCategoryModel *category3 in category2.subCategories){
                        category3.level = HomeCategoryLevelThree;
                        category3.isSelected = NO;
                        category3.parentCategory = category2;
                    }
                }
            }
        }
    }
}
#pragma mark Set Cells
- (void)createCells{
    [self stopLoadingData];
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
    if(self.categories.count > 0){
        SimiSection *categorySection = [self.cells addSectionWithIdentifier:SCP_HOME_CATEGORY];
        for(SCPHomeCategoryModel *category1 in self.categories){
            SimiRow *row1 = [categorySection addRowWithIdentifier:SCP_HOME_CATEGORY];
            row1.model = category1;
            if(category1.isSelected && category1.hasChildren){
                SimiRow *row = [categorySection addRowWithIdentifier:SCP_HOME_CATEGORY_VIEW_ALL];
                row.model = category1;
                for(SCPHomeCategoryModel *category2 in category1.subCategories){
                    SimiRow *row2 = [categorySection addRowWithIdentifier:SCP_HOME_CATEGORY];
                    row2.model = category2;
                    if(category2.isSelected && category2.hasChildren){
                        for(SCPHomeCategoryModel *category3 in category2.subCategories){
                            SimiRow *row3 = [categorySection addRowWithIdentifier:SCP_HOME_CATEGORY];
                            row3.model = category3;
                        }
                        SimiRow *row = [categorySection addRowWithIdentifier:SCP_HOME_CATEGORY_VIEW_ALL];
                        row.model = category2;
                    }
                }
            }
        }
    }
    if(self.homeModel.productListCollection.count > 0){
        SimiSection *productListSection = [self.cells addSectionWithIdentifier:SCP_HOME_PRODUCT_LIST];
        for(SimiHomeProductListModel *productList in self.homeModel.productListCollection.collectionData){
            SimiRow *row = [productListSection addRowWithIdentifier:SCP_HOME_PRODUCT_LIST];
            row.model = productList;
        }
    }
}
- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if([section.identifier isEqualToString:SCP_HOME_BANNER]){
        return [self addBannerCellForRow:row];
    }else if([section.identifier isEqualToString:SCP_HOME_CATEGORY]){
        if([row.identifier isEqualToString:SCP_HOME_CATEGORY]){
            return [self addCategoryCellForRow:row];
        }else if([row.identifier isEqualToString:SCP_HOME_CATEGORY_VIEW_ALL]){
            return  [self addCategoryViewAllCellForRow: row];
        }
    }
    else if([section.identifier isEqualToString:SCP_HOME_PRODUCT_LIST]){
        return [self addProductListCellForRow:row];
    }
    return nil;
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
- (UITableViewCell *)addCategoryCellForRow:(SimiRow *)row{
    SCPHomeCategoryModel *category = (SCPHomeCategoryModel *)row.model;
    NSString *identifier = [NSString stringWithFormat:@"%@%@",SCP_HOME_CATEGORY,category.categoryId];
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        float paddingX1 = 0;
        float paddingX2 = CGRectGetWidth(self.contentTableView.frame) / 6;
        float paddingX3 = paddingX2 + 50;
        float contentWidth;
        cell.heightCell = 0;
        switch (category.level) {
            case HomeCategoryLevelOne:{
                contentWidth = CGRectGetWidth(self.contentTableView.frame) - paddingX1;
                float imageWidth = category.width;
                if(PADDEVICE){
                    imageWidth = category.widthTablet;
                }
                if(imageWidth == 0){
                    imageWidth = contentWidth;
                }
                float scale = 0;
                if(imageWidth > 0){
                    scale = contentWidth/imageWidth;
                }
                float imageHeight = category.height;
                if(PADDEVICE){
                    imageHeight = category.heightTablet;
                }
                imageHeight *= scale;
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(paddingX1, cell.heightCell, contentWidth, imageHeight)];
                [imageView sd_setImageWithURL:[NSURL URLWithString:PHONEDEVICE?category.imageURL:category.imageURLPad] placeholderImage:[UIImage imageNamed:@"logo"]];
                imageView.contentMode = UIViewContentModeScaleToFill;
                [cell.contentView addSubview:imageView];
                cell.heightCell += CGRectGetHeight(imageView.frame);
            }
                break;
            case HomeCategoryLevelTwo:{
                contentWidth = CGRectGetWidth(self.contentTableView.frame) - paddingX2;
                SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX2, cell.heightCell, contentWidth, 44)];
                label.text = category.name;
                label.textColor = SCP_ICON_COLOR;
                if(category.isSelected){
                    label.textColor = SCP_ICON_HIGHLIGHT_COLOR;
                }
                [cell.contentView addSubview:label];
                cell.heightCell += CGRectGetHeight(label.frame);
            }
                break;
            case HomeCategoryLevelThree:{
                contentWidth = CGRectGetWidth(self.contentTableView.frame) - paddingX3;
                SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX3, cell.heightCell, contentWidth, 44)];
                label.text = category.name;
                [cell.contentView addSubview:label];
                cell.heightCell += CGRectGetHeight(label.frame);
            }
                break;
            default:
                break;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if(category.level == HomeCategoryLevelTwo){
        if([cell.contentView.subviews.firstObject isKindOfClass:[SimiLabel class]]){
            SimiLabel *label = (SimiLabel *)cell.contentView.subviews.firstObject;
            label.textColor = SCP_ICON_COLOR;
            if(category.isSelected){
                label.textColor = SCP_ICON_HIGHLIGHT_COLOR;
            }
        }
    }
    row.height = cell.heightCell;
    return cell;
}
- (UITableViewCell *)addCategoryViewAllCellForRow:(SimiRow *)row{
    SCPHomeCategoryModel *category = (SCPHomeCategoryModel *)row.model;
    NSString *identifier = [NSString stringWithFormat:@"%@%@",SCP_HOME_CATEGORY_VIEW_ALL,category.categoryId];
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        float paddingX1 = CGRectGetWidth(self.contentTableView.frame) / 6;
        float paddingX2 = paddingX1 + 50;
        float contentWidth;
        cell.heightCell = 0;
        switch (category.level) {
            case HomeCategoryLevelOne:
            {
                contentWidth = CGRectGetWidth(self.contentTableView.frame) - paddingX1;
                SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX1, cell.heightCell, contentWidth, 44) andFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
                label.text = @"All Products";
                [cell.contentView addSubview:label];
                cell.heightCell += CGRectGetHeight(label.frame);
            }
                break;
            case HomeCategoryLevelTwo:
            {
                contentWidth = CGRectGetWidth(self.contentTableView.frame) - paddingX2;
                SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX2, cell.heightCell, contentWidth, 44) andFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
                label.text = @"View all";
                [cell.contentView addSubview:label];
                cell.heightCell += CGRectGetHeight(label.frame);
            }
                break;
                
            default:
                break;
        }
    }
    row.height = cell.heightCell;
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
    if([section.identifier isEqualToString:SCP_HOME_CATEGORY]){
        if([row.identifier isEqualToString:SCP_HOME_CATEGORY]){
            SCPHomeCategoryModel *category = (SCPHomeCategoryModel *)row.model;
            if(category.hasChildren){
                switch (category.level) {
                    case HomeCategoryLevelOne:{
                        if(category.isSelected){
                            category.isSelected = NO;
                        }else{
                            category.isSelected = YES;
                            for(SCPHomeCategoryModel *cate in self.categories){
                                if(![category isEqual:cate]){
                                    cate.isSelected = NO;
                                }
                                if(cate.hasChildren){
                                    for(SCPHomeCategoryModel *cate2 in cate.subCategories){
                                        cate2.isSelected = NO;
                                    }
                                }
                            }
                        }
                    }
                        break;
                    case HomeCategoryLevelTwo:{
                        if(category.isSelected){
                            category.isSelected = NO;
                        }else{
                            category.isSelected = YES;
                            SCPHomeCategoryModel *parent = category.parentCategory;
                            for(SCPHomeCategoryModel *cate in parent.subCategories){
                                if(![cate isEqual:category]){
                                    cate.isSelected = NO;
                                }
                            }
                        }
                    }
                        break;
                    case HomeCategoryLevelThree:{
                        SCPCategoryViewController *categoryVC = [SCPCategoryViewController new];
                        categoryVC.categoryModel = [[SCPCategoryModel alloc] initWithModelData:category.modelData];
                        [self.navigationController pushViewController:categoryVC animated:YES];
                    }
                        break;
                    default:
                        break;
                }
                [self initCells];
            }else{
                //Open list product
                SCPProductsViewController *productsViewController = [SCPProductsViewController new];
                if (PADDEVICE) {
                    productsViewController = [SCPPadProductsViewController new];
                }
                productsViewController.productListGetProductType = ProductListGetProductTypeFromCategory;
                productsViewController.categoryID = category.categoryId;
                [self.navigationController pushViewController:productsViewController animated:YES];
            }
        }else if([row.identifier isEqualToString:SCP_HOME_CATEGORY_VIEW_ALL]){
            SCPHomeCategoryModel *category = (SCPHomeCategoryModel *)row.model;
            SCPProductsViewController *productsViewController = [SCPProductsViewController new];
            if (PADDEVICE) {
                productsViewController = [SCPPadProductsViewController new];
            }
            productsViewController.productListGetProductType = ProductListGetProductTypeFromCategory;
            productsViewController.categoryID = category.categoryId;
            [self.navigationController pushViewController:productsViewController animated:YES];
            //Open list product
        }
        
    }
    else if([section.identifier isEqualToString:SCP_HOME_PRODUCT_LIST]){
        //Open list product
        SCPProductsViewController *productsViewController = [SCPProductsViewController new];
        if (PADDEVICE) {
            productsViewController = [SCPPadProductsViewController new];
        }
        productsViewController.productListGetProductType = ProductListGetProductTypeFromSpot;
        productsViewController.spotID = row.model.entityId ;
        [self.navigationController pushViewController:productsViewController animated:YES];
    }
}

#pragma mark MatrixBannerScrollViewDelegate
- (void)didTapInBanner:(SimiHomeBannerModel *)banner{
    if (banner.type == BannerCategoryInApp) {
        SCPProductsViewController *productsVC = [SCPProductsViewController new];
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
@end
