//
//  SCPCategoryViewController.m
//  SimiCartPluginFW
//
//  Created by Axe on 4/24/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPCategoryViewController.h"
#import "SCPGlobalVars.h"
#import "SCPProductsViewController.h"

#define SCP_CATEGORY @"ROOT_CATEGORY"
#define SCP_CATEGORY_VIEW_ALL @"ROOT_CATEGORY_VIEW_ALL"

@interface SCPCategoryViewController ()

@end

@implementation SCPCategoryViewController{
    NSMutableArray *categories;
}
- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    self.contentTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    self.contentTableView.tableFooterView = [UIView new];
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.contentTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.contentTableView.hidden = YES;
    [self.view addSubview:self.contentTableView];
    categories = [NSMutableArray new];
    [self getRootCategories];
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
        [self initCells];
        self.contentTableView.hidden = NO;
    }else{
        [self showAlertWithTitle:@"" message:responder.message];
    }
}
- (void)createCells{
    SimiSection *section = [self.cells addSectionWithIdentifier:SCP_CATEGORY];
    if(!self.isSubCategory){
        for(SCPCategoryModel *category1 in categories){
            SimiRow *row1 = [section addRowWithIdentifier:SCP_CATEGORY];
            row1.model = category1;
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
- (UITableViewCell *)createCategoryCellForRow:(SimiRow *)row{
    SCPCategoryModel *category = (SCPCategoryModel *)row.model;
    NSString *identifier = [NSString stringWithFormat:@"%@%@",SCP_CATEGORY,category.entityId];
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        float paddingX1 = 0;
        float paddingX2 = CGRectGetWidth(self.contentTableView.frame) / 6;
        float paddingX3 = paddingX2 + 50;
        cell.heightCell = 0;
        float contentWidth;
        switch (category.level) {
            case CategoryLevelOne:{
                contentWidth = CGRectGetWidth(self.contentTableView.frame) - 2*paddingX1;
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
                if(imageHeight == 0){
                    imageHeight = 200;
                }
                imageHeight *= scale;
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(paddingX1, cell.heightCell, contentWidth, imageHeight)];
                [imageView sd_setImageWithURL:[NSURL URLWithString:category.imageURL] placeholderImage:[UIImage imageNamed:@"logo"]];
                [cell.contentView addSubview:imageView];
                cell.heightCell += imageHeight;
            }
                break;
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
                case CategoryLevelOne:{
                    if(category.isSelected){
                        category.isSelected = NO;
                    }else{
                        category.isSelected = YES;
                        for(SCPCategoryModel *cate in categories){
                            if(![category isEqual:cate]){
                                cate.isSelected = NO;
                            }
                            if(cate.hasChildren){
                                for(SCPCategoryModel *cate2 in cate.subCategories){
                                    cate2.isSelected = NO;
                                }
                            }
                        }
                    }
                }
                    break;
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
            [self initCells];
        }else{
            SCPProductsViewController *productsVC = [SCPProductsViewController new];
            productsVC.categoryID = category.entityId;
            [self.navigationController pushViewController:productsVC animated:YES];
        }
    }else if([row.identifier isEqualToString:SCP_CATEGORY_VIEW_ALL]){
        SCPProductsViewController *productsVC = [SCPProductsViewController new];
        productsVC.categoryID = category.entityId;
        [self.navigationController pushViewController:productsVC animated:YES];
    }
}
@end
