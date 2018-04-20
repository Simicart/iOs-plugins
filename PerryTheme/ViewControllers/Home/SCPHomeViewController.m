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

#define SCP_HOME_BANNER @"SCP_HOME_BANNER"
#define SCP_HOME_CATEGORY @"SCP_HOME_CATEGORY"
#define SCP_HOME_PRODUCT_LIST @"SCP_HOME_PRODUCT_LIST"

@interface SCPHomeViewController ()
@property (strong, nonatomic) NSMutableArray *categories;
@end

@implementation SCPHomeViewController
- (void)viewDidLoadBefore{
    self.contentTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    self.contentTableView.tableFooterView = [UIView new];
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.contentTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.contentTableView];
    self.contentTableView.hidden = YES;
    [self getHomeDataLiteWithChildCat];
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
- (void)initCategories{
    self.categories = [NSMutableArray new];
    for(SimiHomeCategoryModel *category in self.homeModel.categoryCollection.collectionData){
        SCPHomeCategoryModel *cateModel = [[SCPHomeCategoryModel alloc] initWithModelData:category.modelData];
        [self.categories addObject:cateModel];
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
            float width = SCREEN_WIDTH;
            float scale = width/category1.width;
            if(PADDEVICE){
                scale = width/category1.widthTablet;
            }
            float height = category1.height * scale;
            if(PADDEVICE){
                height = category1.heightTablet * scale;
            }
            SimiRow *row1 = [categorySection addRowWithIdentifier:SCP_HOME_CATEGORY height:height];
            category1.level = LevelOne;
            row1.model = category1;
            if(category1.isSelected && category1.hasChildren){
                for(SCPHomeCategoryModel *category2 in category1.subCategories){
                    category2.parentCategory = category1;
                    SimiRow *row2 = [categorySection addRowWithIdentifier:SCP_HOME_CATEGORY height:44];
                    category2.level = LevelTwo;
                    row2.model = category2;
                    if(category2.isSelected && category2.hasChildren){
                        for(SCPHomeCategoryModel *category3 in category2.subCategories){
                            category3.parentCategory = category2;
                            SimiRow *row3 = [categorySection addRowWithIdentifier:SCP_HOME_CATEGORY height:44];
                            category3.level = LevelThree;
                            row3.model = category3;
                        }
                    }
                }
            }
        }
    }
    if(self.homeModel.productListCollection.count > 0){
        SimiSection *productListSection = [self.cells addSectionWithIdentifier:SCP_HOME_PRODUCT_LIST];
        for(SimiHomeProductListModel *productList in self.homeModel.productListCollection.collectionData){
            float width = SCREEN_WIDTH;
            float scale = width/PHONEDEVICE?productList.width:productList.widthTablet;
            float height = PHONEDEVICE?productList.height:productList.heightTablet * scale;
            SimiRow *row = [productListSection addRowWithIdentifier:SCP_HOME_PRODUCT_LIST height:height];
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
        return [self addCategoryCellForRow:row];
    }else if([section.identifier isEqualToString:SCP_HOME_PRODUCT_LIST]){
        return [self addProductListCellForRow:row];
    }
    return nil;
}
- (UITableViewCell *)addBannerCellForRow:(SimiRow *)row{
    UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        MatrixBannerScrollView* bannerScrollView = [[MatrixBannerScrollView alloc] initWithFrame:CGRectMake(0, 0 , SCREEN_WIDTH, row.height)];
        bannerScrollView.isShowedItemsView = YES;
        bannerScrollView.selectedImage = [[UIImage imageNamed:@"ic_banner_selected"] imageWithColor:SCP_ICON_COLOR];
        bannerScrollView.unselectedImage = [[UIImage imageNamed:@"ic_banner_unselected"] imageWithColor:SCP_ICON_COLOR];
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
    UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        switch (category.level) {
            case LevelOne:{
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, row.height)];
                [imageView sd_setImageWithURL:[NSURL URLWithString:PHONEDEVICE?category.imageURL:category.imageURLPad] placeholderImage:[UIImage imageNamed:@"logo"]];
                [cell.contentView addSubview:imageView];
            }
                break;
            case LevelTwo:{
                float padding2 = 50;
                SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(padding2, 0, SCREEN_WIDTH - 2*padding2, row.height)];
                label.text = category.name;
                [cell.contentView addSubview:label];
            }
                break;
            case LevelThree:{
                float padding3 = 100;
                SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(padding3, 0, SCREEN_WIDTH - 2*padding3, row.height)];
                label.text = category.name;
                [cell.contentView addSubview:label];
            }
                break;
            default:
                break;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
- (UITableViewCell *)addProductListCellForRow:(SimiRow *)row{
    SimiHomeProductListModel *productList = (SimiHomeProductListModel *)row.model;
    NSString *identifier = [NSString stringWithFormat:@"%@%@",SCP_HOME_PRODUCT_LIST,productList.productListId];
    UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, row.height)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:PHONEDEVICE?productList.imageURL:productList.imageURLPad] placeholderImage:[UIImage imageNamed:@"logo"]];
        [cell.contentView addSubview:imageView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
- (void)contentTableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if([section.identifier isEqualToString:SCP_HOME_CATEGORY]){
        SCPHomeCategoryModel *category = (SCPHomeCategoryModel *)row.model;
        if(category.hasChildren){
            if(category.isSelected){
                category.isSelected = NO;
            }else{
                category.isSelected = YES;
                for(SCPHomeCategoryModel *cate in self.categories){
                    if(![category isEqual:cate]){
                        cate.isSelected = NO;
                        if(cate.hasChildren){
                            for(SCPHomeCategoryModel *cate2 in cate.subCategories){
                                cate2.isSelected = NO;
                            }
                        }
                    }
                }
            }
            [self initCells];
        }else{
            
        }
    }else if([section.identifier isEqualToString:SCP_HOME_PRODUCT_LIST]){
        
    }
}
#pragma mark MatrixBannerScrollViewDelegate
- (void)didTapInBanner:(SimiHomeBannerModel *)banner{
    
}
@end
