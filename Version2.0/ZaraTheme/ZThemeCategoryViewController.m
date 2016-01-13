//
//  ZThemeCategoryViewController.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 5/6/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeCategoryViewController.h"

@class ZThemeCategoryViewController;
@interface ZThemeCategoryViewController ()

@end


@implementation ZThemeCategoryViewController

- (void)viewDidLoadAfter
{
    [self setNavigationBarOnViewDidLoadForZTheme];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    [self setNavigationBarOnViewWillAppearForZTheme:YES isShowRightItems:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectCategoryCellAtIndexPath" object:tableView userInfo:@{@"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    if (self.categoryCollection.count > 0){
        NSInteger row = [indexPath row];
        BOOL hasChild = [[[self.categoryCollection objectAtIndex:row] valueForKey:@"has_child"] boolValue];
        if (hasChild){
            ZThemeCategoryViewController *nextController = [[ZThemeCategoryViewController alloc]init];
            [nextController setCategoryId:[[self.categoryCollection objectAtIndex:row] valueForKey:@"category_id"]];
            nextController.navigationItem.title = [[self.categoryCollection objectAtIndex:row] valueForKey:@"category_name"];
            //  Liam ADD 150325
            nextController.categoryRealName = [[self.categoryCollection objectAtIndex:row]valueForKey:@"category_name"];
            //  End
            [self.navigationController pushViewController:nextController animated:YES];
        }else{
            ZThemeProductListViewController *nextController = [[ZThemeProductListViewController alloc]init];;
            [nextController setCategoryId: [[self.categoryCollection objectAtIndex:row] valueForKey:@"category_id"]];
            nextController.categoryName = [[self.categoryCollection objectAtIndex:row] valueForKey:@"category_name"];
            if ([nextController.categoryName isEqualToString:@"All products"] && self.categoryRealName) {
                nextController.categoryName = self.categoryRealName;
            }
            nextController.navigationItem.title = nextController.categoryName;
            [self.navigationController pushViewController:nextController animated:YES];
        }
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}
@end
