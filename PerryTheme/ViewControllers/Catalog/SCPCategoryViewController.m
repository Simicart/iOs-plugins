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

@interface SCPCategoryViewController ()

@end

@implementation SCPCategoryViewController

- (void)getPageData{
    if(!self.isSubCategory){
        [self getSubCategories];
    }else{
        [self initCategories];
        [self initCells];
    }
}
- (void)configureLogo{
    if(self.isSubCategory){
        self.title = self.categoryModel.name;
    }else{
        self.title = SCLocalizedString(@"Categories");
    }
}
- (void)getSubCategories{
    if(!self.categoryCollection){
        self.categoryCollection = [[SCPCategoryModelCollection alloc] init];
    }
    NSString *categoryId;
    if(self.categoryModel){
        categoryId = self.categoryModel.entityId;
    }
    if(!self.isSubCategory){
        [self.categoryCollection getSubCategoriesWithId:categoryId level:@"1"];
    }
    self.contentTableView.hidden = YES;
    [self startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetSubCategories:) name:Simi_DidGetCategoryCollection object:nil];
}
- (void)didGetSubCategories:(NSNotification *)noti{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    self.contentTableView.hidden = NO;
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
    self.categories = [NSMutableArray new];
    if(!self.isSubCategory){
        for(SimiCategoryModel *model in self.categoryCollection.collectionData){
            SCPCategoryModel *category1 = [[SCPCategoryModel alloc] initWithModelData:model.modelData];
            [self.categories addObject:category1];
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
        for(SCPCategoryModel *category2 in self.categoryModel.subCategories){
            [self.categories addObject:category2];
            category2.level = CategoryLevelTwo;
            category2.isSelected = NO;
            category2.parentCategory = self.categoryModel;
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

- (void)createCategoryCells{
    if(!self.isSubCategory){
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
    }else{
        if(self.categories.count > 0){
            SimiSection *categorySection = [self.cells addSectionWithIdentifier:SCP_CATEGORY];
            for(SCPCategoryModel *category2 in self.categories){
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
@end
