//
//  SCHomeThemeWorker.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/24/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCHomeThemeWorker.h"
#import <SimiCartBundle/SCHomeViewController.h>
#import <SimiCartBundle/SimiCategoryModelCollection.h>
#import <SimiCartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/SCCategoryViewController.h>
#import <SimiCartBundle/SCSearchViewController.h>
#import <SimiCartBundle/SCProductListViewController.h>

static NSString *HomeSearchCell = @"HomeSearchCellIdentififer";
static NSString *HomeSignInCell = @"HomeSignInCellIdentifier";
static NSString *HomeCateCell   = @"HomeCategoryCellIdentifier";

@implementation SCHomeThemeWorker{
    SimiCategoryModelCollection *categories;
    UITableView *tableViewHome;
    SCHomeViewController *homeController;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCHomeViewController-ViewDidLoad" object:nil];
        [[SimiGlobalVar sharedInstance] addObserver:self forKeyPath:@"isLogin" options:NSKeyValueObservingOptionInitial context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"isLogin"]) {
        [tableViewHome reloadData];
    }
}

- (void)didReceiveNotification:(NSNotification *)noti{
    if ([noti.name isEqualToString:@"SCHomeViewController-ViewDidLoad"]) {
        homeController = noti.object;
        tableViewHome= homeController.tableViewHome;
        tableViewHome.dataSource = self;
        tableViewHome.delegate = self;
        tableViewHome.scrollEnabled = YES;
        if (categories == nil) {
            categories = [[SimiCategoryModelCollection alloc] init];
        }
        @try {
            [[SimiGlobalVar sharedInstance] removeObserver:homeController forKeyPath:@"isLogin" context:nil];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        @finally {
            
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetCategoryCollection" object:categories];
        [categories getCategoryCollectionWithParentId:@""];
        [self removeObserverForNotification:noti];
        
    }else if ([noti.name isEqualToString:@"DidGetCategoryCollection"]){
        [tableViewHome reloadData];
        [self removeObserverForNotification:noti];
    }
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return categories.count + 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row > 1) {
        return 125;
    }
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if (indexPath.row == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:HomeSearchCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HomeSearchCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:cell.frame];
            searchBar.placeholder = SCLocalizedString(@"Search");
            searchBar.userInteractionEnabled = NO;
            [cell addSubview:searchBar];
        }
    }else if (indexPath.row == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:HomeSignInCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HomeSignInCell];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if ([[SimiGlobalVar sharedInstance] isLogin]) {
            SimiCustomerModel *customer = [[SimiGlobalVar sharedInstance] customer];
            cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", SCLocalizedString(@"Hello"), [customer valueForKey:@"user_name"]];
            cell.detailTextLabel.text = SCLocalizedString(@"View Account");
        }else{
            cell.textLabel.text = SCLocalizedString(@"Already a customer ?");
            cell.detailTextLabel.text = SCLocalizedString(@"Sign In");
        }
    }else{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HomeCateCell];
        NSURL *url = [NSURL URLWithString:[[categories objectAtIndex:indexPath.row - 2] valueForKey:@"category_image"]];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 125)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"logo.png"]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addSubview:imageView];
    }
    return cell;
}

#pragma mark Table View Delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        SCSearchViewController *searchController = [[[[homeController.tabBarController viewControllers] objectAtIndex:2] viewControllers] objectAtIndex:0];
        searchController.isFromHome = YES;
        [homeController.tabBarController setSelectedIndex:2];
    }else if (indexPath.row == 1) {
        if (![[SimiGlobalVar sharedInstance] isLogin]) {
            SCLoginViewController *nextController = [[SCLoginViewController alloc]init];
            nextController.navigationItem.title = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text;
            [homeController.navigationController pushViewController:nextController animated:YES];
            nextController = nil;
        }else{
            SCAccountViewController *nextController = [[SCAccountViewController alloc]init];
            nextController.navigationItem.title = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text;
            [homeController.navigationController pushViewController:nextController animated:YES];
            nextController = nil;
        }
    }else{
        NSString *categoryId = [[categories objectAtIndex:indexPath.row - 2] valueForKey:@"category_id"];
        NSString *hasChild = [[categories objectAtIndex:indexPath.row - 2] valueForKey:@"has_child"];
        NSString *categoryName = [[categories objectAtIndex:indexPath.row - 2] valueForKey:@"category_name"];
        if([hasChild boolValue]){
            SCCategoryViewController *controller = [[SCCategoryViewController alloc] init];
            controller.categoryId = categoryId;
            controller.title = categoryName;
            [homeController.navigationController pushViewController:controller animated:YES];
        }else{
            SCProductListViewController *nextController = [[SCProductListViewController alloc]init];;
            [nextController setCategoryId: categoryId];
            nextController.categoryName = categoryName;
            nextController.navigationItem.title = nextController.categoryName;
            [homeController.navigationController pushViewController:nextController animated:YES];
        }
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    @try {
        [[SimiGlobalVar sharedInstance] removeObserver:self forKeyPath:@"isLogin" context:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
        
    }
}

@end
