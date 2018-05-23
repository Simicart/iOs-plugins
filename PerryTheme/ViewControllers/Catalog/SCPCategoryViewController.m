//
//  SCPCategoryViewController.m
//  SimiCartPluginFW
//
//  Created by Axe on 4/24/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPCategoryViewController.h"
#import "SCPGlobalVars.h"
#import "SCPPadProductsViewController.h"
#import <SimiCartBundle/UIButton+WebCache.h>

#define SCP_CATEGORY @"ROOT_CATEGORY"
#define SCP_CATEGORY_VIEW_ALL @"ROOT_CATEGORY_VIEW_ALL"

@interface SCPCategoryViewController ()

@end

@implementation SCPCategoryViewController{
    NSMutableArray *categories;
    NSMutableArray *expandedRows, *collapsedRows;
}
- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    self.contentTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    self.contentTableView.tableFooterView = [UIView new];
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.contentTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.contentTableView.hidden = YES;
    [self.view addSubview:self.contentTableView];
    categories = [NSMutableArray new];
    expandedRows = [NSMutableArray new];
    collapsedRows = [NSMutableArray new];
    [self getRootCategories];
}
- (void)configureLogo{
    if(self.isSubCategory){
        self.title = self.categoryModel.name;
    }else{
        self.title = SCLocalizedString(@"Categories");
    }
}
- (void)getRootCategories{
    if(!self.categoryCollection){
        self.categoryCollection = [[SCPCategoryModelCollection alloc] init];
    }
    NSString *categoryId = @"";
    if(self.categoryModel){
        categoryId = self.categoryModel.entityId;
    }
    [((SCPCategoryModelCollection *)self.categoryCollection) getRootCategories];
    [self startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetRootCategories:) name:Simi_DidGetCategoryCollection object:nil];
}
- (void)didGetRootCategories:(NSNotification *)noti{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS){
        [self initCategories];
        [self initCells];
        self.contentTableView.hidden = NO;
    }else{
        [self showAlertWithTitle:@"" message:responder.message];
    }
}
- (void)initCategories{
    if(!self.isSubCategory){
        for(SimiCategoryModel *model in self.categoryCollection.collectionData){
            SCPCategoryModel *category1 = [[SCPCategoryModel alloc] initWithModelData:model.modelData];
            [categories addObject:category1];
            category1.level = CategoryLevelOne;
            category1.isSelected = NO;
            category1.parentCategory = nil;
            if(category1.hasChildren){
                for(SCPCategoryModel *category2 in category1.subCategories){
                    category2.level = CategoryLevelTwo;
                    category2.isSelected = NO;
                    category2.parentCategory = category1;
                    if(category2.hasChildren){
                        for(SCPCategoryModel *category3 in category2.subCategories){
                            category3.level = CategoryLevelThree;
                            category3.isSelected = NO;
                            category3.parentCategory = category2;
                        }
                    }
                }
            }
        }
    }else{
        for(SimiCategoryModel *model in self.categoryCollection.collectionData){
            SCPCategoryModel *category2 = [[SCPCategoryModel alloc] initWithModelData:model.modelData];
            [categories addObject:category2];
            category2.level = CategoryLevelTwo;
            category2.isSelected = NO;
            category2.parentCategory = nil;
            if(category2.hasChildren){
                for(NSDictionary *cate3 in category2.subCategories){
                    SCPCategoryModel *category3 = [[SCPCategoryModel alloc] initWithModelData:cate3];
                    category3.level = CategoryLevelThree;
                    category3.isSelected = NO;
                    category3.parentCategory = category2;
                }
            }
        }
    }
}
- (void)createCells{
    self.cells = [SimiTable new];
    if(!self.isSubCategory){
        for(SCPCategoryModel *category1 in categories){
            SimiSection *section = [self.cells addSectionWithIdentifier:SCP_CATEGORY];
            section.simiObjectIdentifier = category1;
            float paddingX1 = 0;
            float contentWidth = CGRectGetWidth(self.contentTableView.frame) - 2*paddingX1;
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
            if(imageHeight == 0){
                imageHeight = 200;
            }
            imageHeight *= scale;
            section.header = [[SimiSectionHeader alloc] initWithTitle:@"" height:imageHeight];
            if(category1.hasChildren && category1.isSelected){
                SimiRow *row = [section addRowWithIdentifier:SCP_CATEGORY_VIEW_ALL];
                row.model = category1;
                for(SCPCategoryModel *category2 in category1.subCategories){
                    SimiRow *row2 = [section addRowWithIdentifier:SCP_CATEGORY];
                    row2.model = category2;
                    if(category2.hasChildren && category2.isSelected){
                        for(SCPCategoryModel *category3 in category2.subCategories){
                            SimiRow *row3 = [section addRowWithIdentifier:SCP_CATEGORY];
                            row3.model = category3;
                        }
                        SimiRow *row = [section addRowWithIdentifier:SCP_CATEGORY_VIEW_ALL];
                        row.model = category2;
                    }
                }
            }
        }
    }else{
        SimiSection *section = [self.cells addSectionWithIdentifier:SCP_CATEGORY];
        SimiRow *row = [section addRowWithIdentifier:SCP_CATEGORY_VIEW_ALL];
        row.model = self.categoryModel;
        for(SCPCategoryModel *category2 in categories){
            SimiRow *row2 = [section addRowWithIdentifier:SCP_CATEGORY];
            row2.model = category2;
            if(category2.hasChildren && category2.isSelected){
                for(SCPCategoryModel *category3 in category2.subCategories){
                    SimiRow *row3 = [section addRowWithIdentifier:SCP_CATEGORY];
                    row3.model = category3;
                }
                SimiRow *row = [section addRowWithIdentifier:SCP_CATEGORY_VIEW_ALL];
                row.model = category2;
            }
        }
    }
}
- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if([row.identifier isEqualToString:SCP_CATEGORY]){
        return [self createCategoryCellForRow:row];
    }else if([row.identifier isEqualToString:SCP_CATEGORY_VIEW_ALL]){
        return [self addCategoryViewAllCellForRow:row];
    }
    return nil;
}

- (UITableViewCell *)addCategoryViewAllCellForRow:(SimiRow *)row{
    SCPCategoryModel *category = (SCPCategoryModel *)row.model;
    NSString *identifier = [NSString stringWithFormat:@"%@%@",SCP_CATEGORY_VIEW_ALL,category.entityId];
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        float paddingX1 = CGRectGetWidth(self.contentTableView.frame) / 6;
        float paddingX2 = paddingX1 + 50;
        float contentWidth;
        cell.heightCell = 0;
        switch (category.level) {
            case CategoryLevelOne:
            {
                contentWidth = CGRectGetWidth(self.contentTableView.frame) - paddingX1;
                SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX1, cell.heightCell, contentWidth, 44) andFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
                label.text = @"All Products";
                [cell.contentView addSubview:label];
                cell.heightCell += CGRectGetHeight(label.frame);
            }
                break;
            case CategoryLevelTwo:
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
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(!self.isSubCategory){
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
    return nil;
}
- (void)didTapToCategoryImage:(UIButton *)sender{
    SimiSection *section = (SimiSection *)sender.simiObjectIdentifier;
    SCPCategoryModel *category = (SCPCategoryModel *)section.simiObjectIdentifier;
    if(category.hasChildren){
        if(category.isSelected){
            category.isSelected = NO;
            [self initCells];
            if (expandedRows.count > 0) {
                [self.contentTableView beginUpdates];
                [self.contentTableView deleteRowsAtIndexPaths:expandedRows withRowAnimation:UITableViewRowAnimationFade];
                [self.contentTableView endUpdates];
                [expandedRows removeAllObjects];
            }
        }else{
            for(SCPCategoryModel *cate in categories){
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
            
            [expandedRows removeAllObjects];
            NSInteger sectionIndex = [categories indexOfObject:category];
            for(int i = 0; i < section.rows.count;i++){
                [expandedRows addObject:[NSIndexPath indexPathForRow:0 inSection:sectionIndex]];
            }
            [self initCells];
//            [self.contentTableView beginUpdates];
//            [self.contentTableView insertRowsAtIndexPaths:expandedRows withRowAnimation:UITableViewRowAnimationFade];
//            [self.contentTableView endUpdates];
            [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}
- (UITableViewCell *)createCategoryCellForRow:(SimiRow *)row{
    SCPCategoryModel *category = (SCPCategoryModel *)row.model;
    NSString *identifier = [NSString stringWithFormat:@"%@%@",SCP_CATEGORY,category.entityId];
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        float paddingX2 = CGRectGetWidth(self.contentTableView.frame) / 6;
        float paddingX3 = paddingX2 + 50;
        cell.heightCell = 0;
        float contentWidth;
        switch (category.level) {
            case CategoryLevelTwo:{
                contentWidth = CGRectGetWidth(self.contentTableView.frame) - paddingX2;
                SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX2, cell.heightCell, contentWidth, 44) andFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
                label.text = category.name;
                label.textColor = SCP_ICON_COLOR;
                if(category.isSelected){
                    label.textColor = SCP_ICON_HIGHLIGHT_COLOR;
                }
                [cell.contentView addSubview:label];
                cell.heightCell += CGRectGetHeight(label.frame);
            }
                break;
            case CategoryLevelThree:{
                contentWidth = CGRectGetWidth(self.contentTableView.frame) - paddingX3;
                SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX3, cell.heightCell, contentWidth, 44) andFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
                label.text = category.name;
                [cell.contentView addSubview:label];
                cell.heightCell += CGRectGetHeight(label.frame);
            }
                break;
            default:
                break;
        }
    }
    if(category.level == CategoryLevelTwo){
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
- (void)contentTableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    SCPCategoryModel *category = (SCPCategoryModel *)row.model;
    if([row.identifier isEqualToString:SCP_CATEGORY]){
        if(category.hasChildren){
            switch (category.level) {
                case CategoryLevelTwo:{
                    if(category.isSelected){
                        category.isSelected = NO;
                        [self initCells];
                    }else{
                        category.isSelected = YES;
                        SCPCategoryModel *parent = category.parentCategory;
                        for(SCPCategoryModel *cate in parent.subCategories){
                            if(![cate isEqual:category]){
                                cate.isSelected = NO;
                            }
                        }
                        [self initCells];
                        [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    }
                }
                    break;
                case CategoryLevelThree:{
                    SCPCategoryViewController *subCateVC = [SCPCategoryViewController new];
                    subCateVC.isSubCategory = YES;
                    subCateVC.categoryModel = category;
                    [self.navigationController pushViewController:subCateVC animated:YES];
                }
                    break;
                default:
                    break;
            }
        }else{
            SCPProductsViewController *productsVC = [SCPProductsViewController new];
            if (PADDEVICE) {
                productsVC = [SCPPadProductsViewController new];
            }
            productsVC.categoryID = category.entityId;
            productsVC.nameOfProductList = category.name;
            [self.navigationController pushViewController:productsVC animated:YES];
        }
    }else if([row.identifier isEqualToString:SCP_CATEGORY_VIEW_ALL]){
        SCPProductsViewController *productsVC = [SCPProductsViewController new];
        if(PADDEVICE){
            productsVC = [SCPPadProductsViewController new];
        }
        productsVC.categoryID = category.entityId;
        productsVC.nameOfProductList = category.name;
        [self.navigationController pushViewController:productsVC animated:YES];
    }
}
@end
