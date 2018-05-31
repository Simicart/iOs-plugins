//
//  SCPSubCategoryViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 5/28/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPSubCategoryViewController.h"

@interface SCPSubCategoryViewController ()

@end

@implementation SCPSubCategoryViewController

- (void)getPageData{
    [self getSubCategoriesOfCategory:self.categoryModel level:@"1"];
    [self startLoadingData];
}
- (void)configureLogo{
    if(self.categoryModel){
        self.title = SCLocalizedString(self.categoryModel.name);
    }else{
        [super configureLogo];
    }
}
- (void)viewDidAppearBefore:(BOOL)animated{
    [super viewDidAppearBefore:animated];
    [self.contentTableView setContentInset:UIEdgeInsetsMake(SCP_CATEGORY_TEXT_CELL_PADDING_TOP, 0, 0, 0)];
}
- (void)createCategoryCells{
    if(self.categories.count > 0){
        SimiSection *categorySection = [self.cells addSectionWithIdentifier:SCP_CATEGORY];
        SimiRow *row = [categorySection addRowWithIdentifier:SCP_CATEGORY_VIEW_ALL_PRODUCTS];
        row.model = self.categoryModel;
        for(SCPCategoryModel *category1 in self.categories){
            SimiRow *row1 = [categorySection addRowWithIdentifier:SCP_CATEGORY];
            row1.model = category1;
            if(category1.isSelected && category1.hasChildren){
                for(int i = 0;i<category1.subCategories.count;i++){
                    if(i < 3){
                        SCPCategoryModel *category2 = [category1.subCategories objectAtIndex:i];
                        SimiRow *row2 = [categorySection addRowWithIdentifier:SCP_CATEGORY];
                        row2.model = category2;
                    }
                }
                SimiRow *row = [categorySection addRowWithIdentifier:SCP_CATEGORY_VIEW_ALL_SUB_CATEGORIES];
                row.model = category1;
            }
        }
    }
}
- (void)didSelectCategoryCellAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    NSInteger sectionIndex = [self.cells indexOfObject:section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    SCPCategoryModel *category = (SCPCategoryModel *)row.model;
    if([row.identifier isEqualToString:SCP_CATEGORY]){
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
                        }
                    }else{
                        category.isSelected = YES;
                        NSInteger rowIndex = 0;
                        for(int i = 0; i < self.categories.count; i++){
                            SCPCategoryModel *cate = [self.categories objectAtIndex:i];
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
                        [self createCells];
                        [self.contentTableView beginUpdates];
                        if(expandedRow2s.count){
                            [self.contentTableView deleteRowsAtIndexPaths:expandedRow2s withRowAnimation:UITableViewRowAnimationFade];
                            [expandedRow2s removeAllObjects];
                        }
                        SimiSection *sec = [self.cells objectAtIndex:sectionIndex];
                        for(int i = 0;i<sec.rows.count;i++){
                            SimiRow *row = [sec objectAtIndex:i];
                            SCPCategoryModel *cate = (SCPCategoryModel *)row.model;
                            if(cate.level == CategoryLevelThree || [row.identifier isEqualToString:SCP_CATEGORY_VIEW_ALL_SUB_CATEGORIES]){
                                [expandedRow2s addObject:[NSIndexPath indexPathForRow:i inSection:sectionIndex]];
                            }
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
                NSInteger rowIndex = 0;
                for(int i = 0; i < self.categories.count; i++){
                    SCPCategoryModel *cate = [self.categories objectAtIndex:i];
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
                }
            }
            [self openProductListWithCategory:category];
        }
    }else if([row.identifier isEqualToString:SCP_CATEGORY_VIEW_ALL_PRODUCTS]){
        NSInteger rowIndex = 0;
        for(int i = 0; i < self.categories.count; i++){
            SCPCategoryModel *cate = [self.categories objectAtIndex:i];
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
        }
        [self openProductListWithCategory:category];
    }
    else{
        [super didSelectCategoryCellAtIndexPath:indexPath];
    }
}

- (void)didGetSubCategories:(NSNotification *)noti{
    [self stopLoadingData];
    self.contentTableView.userInteractionEnabled = YES;
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        [self initSubCategories:noti.object];
        [self initCells];
    }else {
        [self showToastMessage:responder.message duration:2];
    }
}

- (void)initSubCategories:(SCPCategoryModelCollection *)categoryCollection{
    self.categories = [NSMutableArray new];
    for(SCPCategoryModel *cate1 in categoryCollection.collectionData){
        SCPCategoryModel *category1 = [[SCPCategoryModel alloc] initWithModelData:cate1.modelData];
        category1.level = CategoryLevelTwo;
        category1.isSelected = NO;
        category1.parentCategory = self.categoryModel;
        [self.categories addObject:category1];
        if(category1.hasChildren && category1.subCategories){
            for(SCPCategoryModel *category2 in category1.subCategories){
                category2.level = CategoryLevelThree;
                category2.isSelected = NO;
                category2.parentCategory = category1;
            }
        }
    }
}

@end
