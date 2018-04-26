//
//  SCPCategoryViewController.h
//  SimiCartPluginFW
//
//  Created by Axe on 4/24/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//
#import "SCPCategoryModel.h"
#import <SimiCartBundle/SimiCategoryModelCollection.h>

@interface SCPCategoryViewController : SimiTableViewController
@property (nonatomic, strong) SimiCategoryModelCollection *categoryCollection;
@end
