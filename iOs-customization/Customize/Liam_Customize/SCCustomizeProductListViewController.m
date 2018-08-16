//
//  SCCustomizeProductListViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 4/26/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCustomizeProductListViewController.h"
#import "SCCustomizeSearchViewController.h"

@interface SCCustomizeProductListViewController ()

@end

@implementation SCCustomizeProductListViewController
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    if (self.productListGetProductType == ProductListGetProductTypeFromSearch) {
        [self.navigationController popViewControllerAnimated:NO];
        return NO;
    }
    SCCustomizeSearchViewController *searchViewController = [SCCustomizeSearchViewController new];
    [self.navigationController pushViewController:searchViewController animated:YES];
    return NO;
}
@end
