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
#import "SCPCategoryModelCollection.h"
#import "SCPHomeViewController.h"

@interface SCPCategoryViewController : SCPHomeViewController
@property (nonatomic, strong) SCPCategoryModelCollection *categoryCollection;
@end
