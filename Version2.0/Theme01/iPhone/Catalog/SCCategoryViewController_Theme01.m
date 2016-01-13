//
//  SCCategoryViewController_Theme01.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/11/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <SimiCartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/SimiResponder.h>

#import "SCCategoryViewController_Theme01.h"
#import "SCGridViewController_Theme01.h"
#import "SimiViewController+Theme01.h"

@interface SCCategoryViewController_Theme01 ()

@end

@implementation SCCategoryViewController_Theme01

@synthesize tableViewCategory, categoryCollection, categoryId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoadBefore
{
    [self setToSimiView];
    if ([self.navigationController.title isEqualToString:@""]) {
        self.navigationItem.title = [SCLocalizedString(@"Category") uppercaseString];
    }
    tableViewCategory = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    tableViewCategory.dataSource = self;
    tableViewCategory.delegate = self;
    tableViewCategory.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:tableViewCategory];
    [self setNavigationBarOnViewWillAppearForTheme01];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    [self setNavigationBarOnViewWillAppearForTheme01];
}

- (void)viewWillAppearAfter:(BOOL)animated
{
    if (categoryCollection == nil) {
        categoryCollection = [[SimiCategoryModelCollection alloc] init];
    }
    [self getCategories];
    [tableViewCategory deselectRowAtIndexPath:[tableViewCategory indexPathForSelectedRow] animated:YES];
}

- (void)viewWillDisappearAfter:(BOOL)animated
{
    [self deleteBackItemForTheme01];
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return categoryCollection.count > 0 ? categoryCollection.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cateCellIdentifier = @"CategoryCell";
    static NSString *loadingCateCell = @"LoadingCateCell";
    UITableViewCell *cell;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCategoryCell-Before" object:cell];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return cell;
    }
    if (categoryCollection.count != 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:cateCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cateCellIdentifier];
            [[NSNotificationCenter defaultCenter] postNotificationName:cateCellIdentifier object:nil userInfo:@{@"data": cell}];
        }
        cell.textLabel.text = [[categoryCollection objectAtIndex:indexPath.row] valueForKey:@"category_name"];
        cell.textLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:THEME_FONT_SIZE];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userInteractionEnabled = YES;
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:loadingCateCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadingCateCell];
            [[NSNotificationCenter defaultCenter] postNotificationName:loadingCateCell object:nil userInfo:@{@"data": cell}];
        }
        UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loading.frame = CGRectMake(cell.frame.size.width/2-25, 0, 50, cell.frame.size.height);
        [loading startAnimating];
        [cell addSubview:loading];
        cell.userInteractionEnabled = NO;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCategoryCell-After" object:cell userInfo:@{@"indexPath": indexPath}];
    return cell;
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectCategoryCellAtIndexPath" object:tableView userInfo:@{@"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    if (categoryCollection.count > 0){
        NSInteger row = [indexPath row];
        BOOL hasChild = [[[categoryCollection objectAtIndex:row] valueForKey:@"has_child"] boolValue];
        if (hasChild){
            SCCategoryViewController_Theme01 *nextController = [[SCCategoryViewController_Theme01 alloc]init];
            [nextController setCategoryId:[[categoryCollection objectAtIndex:row] valueForKey:@"category_id"]];
            NSLog(@"%@",[[categoryCollection objectAtIndex:row] valueForKey:@"category_name"]);
            nextController.navigationItem.title = [[[categoryCollection objectAtIndex:row] valueForKey:@"category_name"] uppercaseString];
            //  Liam ADD 150326
            nextController.categoryRealName = [[categoryCollection objectAtIndex:row]valueForKey:@"category_name"];
            //  End
            [self.navigationController pushViewController:nextController animated:YES];
        }else{
            SCGridViewController_Theme01 *nextController = [[SCGridViewController_Theme01 alloc]init];
            nextController.categoryId = [[categoryCollection objectAtIndex:row] valueForKey:@"category_id"];
            nextController.scCollectionGetProductType = SCCollectionGetProductTypeFromCategory;
            //  Liam UPDATE 150326
            nextController.categoryName = [[categoryCollection objectAtIndex:row] valueForKey:@"category_name"];
            if ([nextController.categoryName isEqualToString:@"All products"] && self.categoryRealName) {
                nextController.categoryName = self.categoryRealName;
            }
            nextController.navigationItem.title = [nextController.categoryName uppercaseString];
            //  End
            [self.navigationController pushViewController:nextController animated:YES];
        }
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
