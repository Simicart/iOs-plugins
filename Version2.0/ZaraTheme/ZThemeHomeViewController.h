//
//  ZThemeHomeViewController.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SCHomeViewController.h>
#import <SimiCartBundle/SimiTable.h>

#import "ZThemeCategoryViewController.h"
#import "ZThemeHomeModelCollection.h"
#import "ZThemeProductListViewController.h"
#import "ZThemeSection.h"
#import "ZThemeRow.h"
#import "SimiViewController+ZTheme.h"

@interface ZThemeHomeViewController : SCHomeViewController

@property (nonatomic, strong) ZThemeHomeModelCollection *homeModelCollection;
@property (nonatomic, strong) SimiTable *cellTables;
@property (nonatomic, strong) NSMutableArray *currentRowsAllow; // Save indexPaths row is showing
@property (nonatomic, strong) UIImageView *searchImage;

- (void)getListCategories;
- (void)didGetListCategories:(NSNotification*)noti;
@end
