//
//  ZThemeCategoryViewControllerPad.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 5/21/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeCategoryViewControllerPad.h"
#import "ZThemeProductListViewControllerPad.h"
#import <SimiCartBundle/SCAppDelegate.h>

@interface ZThemeCategoryViewControllerPad ()

@end

@implementation ZThemeCategoryViewControllerPad

- (void)viewWillAppearAfter:(BOOL)animated{
    [super viewWillAppearAfter:animated];
    [self.tableViewCategory setSeparatorColor:[UIColor whiteColor]];
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
            if (!self.isInView) {
                ZThemeCategoryViewControllerPad *nextController = [[ZThemeCategoryViewControllerPad alloc]init];
                [nextController setCategoryId:[[self.categoryCollection objectAtIndex:row] valueForKey:@"category_id"]];
                nextController.navigationItem.title = [[self.categoryCollection objectAtIndex:row] valueForKey:@"category_name"];
                nextController.categoryRealName = [[self.categoryCollection objectAtIndex:row]valueForKey:@"category_name"];
                nextController.isInPopover = self.isInPopover;
                nextController.popover = self.popover;
                [[self navigationController] pushViewController:nextController animated:YES];
            }
            else {
                self.categoryRealName = [[self.categoryCollection objectAtIndex:row]valueForKey:@"category_name"];
                [self setCategoryId:[[self.categoryCollection objectAtIndex:row] valueForKey:@"category_id"]];
                [self updateCategoryTitle:self.categoryRealName];
                [self startLoadingData];
                [self getCategories];
            }
        }else{
            if (self.isInPopover) {
                [self.popover dismissPopoverAnimated:YES];
            }
            ZThemeProductListViewControllerPad *nextController = [[ZThemeProductListViewControllerPad alloc]init];;
            [nextController setCategoryId: [[self.categoryCollection objectAtIndex:row] valueForKey:@"category_id"]];
            nextController.categoryName = [[self.categoryCollection objectAtIndex:row] valueForKey:@"category_name"];
            nextController.isCategory = YES;
            if ([nextController.categoryName isEqualToString:@"All products"] && self.categoryRealName) {
                nextController.categoryName = self.categoryRealName;
            }
            nextController.navigationItem.title = nextController.categoryName;
            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
            UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
            [viewController.navigationController pushViewController:nextController animated:YES];
        }
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)updateCategoryTitle: (NSString *)title
{
    if (self.categoryTitle == nil) {
        self.categoryTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, -40, 380, 30)];
        [self.categoryTitle setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE_REGULAR + 4]];
        [self.view addSubview:self.categoryTitle];
    }
    [self.categoryTitle setText:[title uppercaseString]];
}

- (void)didGetCategories:(NSNotification *)noti
{
    [super didGetCategories:noti];
    [self stopLoadingData];
}

#pragma mark tableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.font = [UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:THEME_FONT_SIZE_REGULAR];
    if (self.categoryCollection.count > 0){
        BOOL hasChild = [[[self.categoryCollection objectAtIndex:indexPath.row] valueForKey:@"has_child"] boolValue];
        if (!hasChild)
            cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

@end
