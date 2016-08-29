//
//  CategoryTImeLoaderViewController.h
//  SimiCartPluginFW
//
//  Created by Gin-Wishky on 10/20/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "SimiTableView.h"

@interface CategoryTimeLoaderViewController : SimiViewController <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic,strong)   NSMutableArray *cells;
@property(nonatomic,strong)  SimiTableView *timeLoaderCategory;
@property(nonatomic,strong)  NSMutableDictionary *dictAPIDataTimeLoader;
@property(nonatomic,strong)  NSMutableDictionary *dictAPIScreenDataTimeLoader;
@end
