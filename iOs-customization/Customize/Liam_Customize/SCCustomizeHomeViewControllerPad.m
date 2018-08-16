//
//  SCCustomizeHomeViewControllerPad.m
//  SimiCartPluginFW
//
//  Created by Liam on 4/10/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCustomizeHomeViewControllerPad.h"
#import "SCCustomizeHomeViewController.h"
#import <SimiCartBundle/MatrixBannerScrollViewPad.h>

@interface SCCustomizeHomeViewControllerPad ()<MatrixBannerScrollViewDelegate>

@end

@implementation SCCustomizeHomeViewControllerPad
- (void)createCells{
    [self stopLoadingData];
    [self.contentTableView setHidden:NO];
    float rowHeight = 44;
    float bannerHeight = 0;
    if (padBanners.count > 0) {
        if(padBanners.count < 2){
            bannerHeight = SCREEN_WIDTH/2 + SCALEVALUE(5);
        }else{
            bannerHeight = SCREEN_WIDTH/4 + SCALEVALUE(5);
        }
        SimiSection* section = [self.cells addSectionWithIdentifier:ZARA_HOME_BANNER];
        [section addRowWithIdentifier:ZARA_HOME_BANNER height:bannerHeight];
    }
    
    if (self.homeModel.categoryCollection.count > 0) {
        for (int i = 0; i < self.homeModel.categoryCollection.count; i++) {
            SimiHomeCategoryModel *categoryModel = [self.homeModel.categoryCollection objectAtIndex:i];
            ZaraHomeViewSection *section = [[ZaraHomeViewSection alloc]initWithIdentifier:HOME_CATEGORY_CELL];
            section.sectionContent = categoryModel.modelData;
            section.header = [[SimiSectionHeader alloc]initWithTitle:categoryModel.name height:44]; ;
            if (categoryModel.hasChildren) {
                section.hasChild = YES;
            }
            section.isSelected = NO;
            
            if (categoryModel.width > 0 && categoryModel.height > 0 ) {
                section.header.height = categoryModel.height *SCREEN_WIDTH/categoryModel.width;
            }else
                section.header.height = HEIGHTBANNER;
            if (section.hasChild) {
                if ([[categoryModel.modelData valueForKey:@"children"]isKindOfClass:[NSArray class]]) {
                    NSMutableArray *categoryChildrenArray = [[NSMutableArray alloc]initWithArray:[categoryModel.modelData valueForKey:@"children"]];
                    if (categoryChildrenArray.count > 0) {
                        if (GLOBALVAR.isShowLinkAllProduct) {
                            ZaraHomeViewRow *row = [[ZaraHomeViewRow alloc]initWithIdentifier:section.identifier  height:rowHeight];
                            row.hasChild = NO;
                            row.data = [[NSMutableDictionary alloc]initWithDictionary:section.sectionContent];
                            [row.data setValue:SCLocalizedString(@"All products") forKey:@"name"];
                            [section addObject:row];
                        }
                        for (int j = 0; j < categoryChildrenArray.count; j++) {
                            NSDictionary *cateChild = [categoryChildrenArray objectAtIndex:j];
                            ZaraHomeViewRow *simiRow = [[ZaraHomeViewRow alloc]initWithIdentifier:section.identifier height:rowHeight];
                            simiRow.hasChild = [[cateChild valueForKey:@"has_children"]boolValue];
                            simiRow.data = [[NSMutableDictionary alloc]initWithDictionary: cateChild];
                            [section addObject:simiRow];
                        }
                    }
                }
            }
            [self.cells addObject:section];
        }
    }
    
    if (self.homeModel.productListCollection.count > 0) {
        for (int i = 0; i < self.homeModel.productListCollection.count; i++) {
            SimiHomeProductListModel *spotModel = [self.homeModel.productListCollection objectAtIndex:i];
            ZaraHomeViewSection *section = [[ZaraHomeViewSection alloc]initWithIdentifier:HOME_SPOT_CELL];
            section.header = [SimiSectionHeader new];
            section.sectionContent = spotModel.modelData;
            if (spotModel.width > 0 && spotModel.height > 0) {
                section.header.height = spotModel.height *SCREEN_WIDTH/spotModel.width;
            }else
                section.header.height = HEIGHTBANNER;
            [self.cells addObject:section];
        }
    }
}

#pragma mark Create Cells For Row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    if ([row.identifier isEqualToString:ZARA_HOME_BANNER]) {
        cell = [self createBannerCellForRow:row];
    }else{
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SimiSection *simiSection = [self.cells objectAtIndex:section];
    if ([simiSection.identifier isEqualToString:ZARA_HOME_BANNER]) {
        return 1;
    }else{
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (UIView *)contentTableViewViewForHeaderInSection:(NSInteger)section{
    ZaraHomeViewSection *zThemeSection = [self.cells objectAtIndex:section];
    if ([zThemeSection.identifier isEqualToString:ZARA_HOME_BANNER]) {
        return nil;
    }else{
        return [super contentTableViewViewForHeaderInSection:section];
    }
}

- (UITableViewCell *)createBannerCellForRow:(SimiRow *)bannerRow{
    UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:bannerRow.identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bannerRow.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
        MatrixBannerScrollView* bannerScrollView = [[MatrixBannerScrollViewPad alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, bannerRow.height)];
        if(padBanners.count < 2){
            bannerScrollView = [[MatrixBannerScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, bannerRow.height)];
        }
        bannerScrollView.banners = phoneBanners;
        bannerScrollView.delegate = self;
        [cell.contentView addSubview:bannerScrollView];
    }
    return cell;
}

#pragma mark MatrixBannerScrollViewDelegate
- (void)didTapInBanner:(SimiHomeBannerModel *) banner{
    [self trackingBanner:banner];
    if (banner.type == BannerCategoryInApp) {
        [[SCAppController sharedInstance]openProductListWithNavigationController:self.navigationController productsId:banner.categoryId productsName:
         banner.categoryName getProductsFrom:ProductListGetProductTypeFromCategory moreParams:nil];
    }else if(banner.type == BannerProductInApp){
        [[SCAppController sharedInstance] openProductWithNavigationController:self.navigationController productId:banner.productId moreParams:nil];
    }else if(banner.type == BannerWebsitePage) {
        [[SCAppController sharedInstance] openURL:banner.bannerURL withNavigationController:self.navigationController];
    }
}
@end
