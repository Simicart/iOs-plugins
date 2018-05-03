//
//  SCPCategoryViewController.h
//  SimiCartPluginFW
//
//  Created by Axe on 4/24/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//
#import "SCPCategoryModel.h"
#import <SimiCartBundle/SimiCategoryModelCollection.h>
#import "SCPTableViewController.h"

@interface SCPCategoryViewController : SCPTableViewController
@property (nonatomic, strong) SimiCategoryModelCollection *categoryCollection;
@property (nonatomic, strong) SCPCategoryModel *categoryModel;
@property (nonatomic) BOOL isSubCategory;
@end
