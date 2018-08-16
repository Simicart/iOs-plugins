//
//  SCCustomizeSearchViewController.h
//  SimiCartPluginFW
//
//  Created by Liam on 4/25/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiTableViewController.h>
#import "SCCusSearchModel.h"

@interface SCCustomizeSearchViewController : SimiTableViewController<UISearchBarDelegate>
@property (strong, nonatomic) UISearchBar *customSearchBar;
@property (strong, nonatomic) UIView *searchBarBackground;
@property (strong, nonatomic) NSString *keySearch;
@end
