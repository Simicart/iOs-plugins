//
//  SCMenuTableView.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 4/24/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCMenuCategory_Theme01.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface SCMenuCategory_Theme01 (){
    CGFloat tableWidth;
}
@end


@implementation SCMenuCategory_Theme01
@synthesize indexPathRow,categoryCollection,categoryCollection1,categoryId;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    tableWidth = 360;
    self.preferredContentSize = CGSizeMake(tableWidth, SCREEN_HEIGHT/2);
    categoryCollection = [[SimiCategoryModelCollection alloc] init];
    categoryCollection1 = [[SimiCategoryModelCollection alloc] init];
    if (categoryId == nil) {
        categoryId = @"";
    }
    indexPathRow = 1;
    NSDictionary *cateAll = [[NSDictionary alloc] initWithObjectsAndKeys:categoryId, @"category_id", SCLocalizedString(@"All products"), @"category_name", @"YES", @"has_child",@"YES", @"is_selected",nil];
    [categoryCollection addObject:cateAll];
    [self getCategories];
    self.tableView.tintColor = [UIColor colorWithRed:243.0/255 green:96.0/255 blue:13.0/255 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)getCategories{
    [self.tableView.infiniteScrollingView startAnimating];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCategories:) name:@"DidGetCategoryCollection" object:categoryCollection1];
    [categoryCollection1 getCategoryCollectionWithParentId:categoryId];
}

- (void)didGetCategories:(NSNotification *)noti{
    _isFinishLoad = YES;
    if (indexSelect) {
        if (categoryCollection.count > 0){
            NSInteger row = [indexSelect row];
            isHasChild = [[[categoryCollection objectAtIndex:row] valueForKey:@"has_child"] boolValue];
            if (isHasChild){
                indexPathRow = 0;
                [self.tableView beginUpdates];
                int j =0;
                NSLog(@"categoryCollection %@",categoryCollection);
                for (NSInteger i = 0; i < [categoryCollection count]; i++) {
                    if ([[[categoryCollection objectAtIndex:i] valueForKey:@"is_selected"] boolValue]) {
                        indexPathRow++;
                    }else{
                        [categoryCollection removeObjectAtIndex:i];
                        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath  indexPathForRow:j inSection:indexSelect.section]] withRowAnimation:UITableViewRowAnimationFade];
                        i--;
                    }
                    j++;
                }
                [self.tableView endUpdates];
            }else{
                indexPathRow = indexSelect.row + 1;
            }
        }else{
            [self.tableView deselectRowAtIndexPath:indexSelect animated:YES];
        }
        [self.delegate selectedIDMenu:categoryId];
        [self.tableView setAllowsSelection:YES];
    }    
    for (int i = 0; i < [categoryCollection1 count]; i++) {
        [[categoryCollection1 objectAtIndex:i] setObject:@"NO" forKey:@"is_selected"];
    }
    
    NSInteger nextIndex = categoryCollection.count;
    [self.tableView beginUpdates];
    
    for (NSObject *item in categoryCollection1) {
        //Add the item to the data source
        [categoryCollection addObject:item];
        //Add the item to the table view
        NSIndexPath *path = [NSIndexPath indexPathForRow:nextIndex++ inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView endUpdates];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:SUCCESS]) {
        NSInteger rowsCount = [categoryCollection count];
        NSInteger singleRowHeight = [self.tableView.delegate tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        NSInteger totalRowsHeight = (rowsCount + 2) * singleRowHeight;
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            self.contentSizeForViewInPopover = CGSizeMake(tableWidth, totalRowsHeight);
        } else{
            self.preferredContentSize = CGSizeMake(tableWidth, totalRowsHeight);
        }
    }
    [UIView animateWithDuration:0.5 animations:^{
        [self.tableView reloadData];
    }];
    [activity stopAnimating];
    activity = nil;
    [self.tableView.infiniteScrollingView stopAnimating];
    [self removeObserverForNotification:noti];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return categoryCollection.count > 0 ? categoryCollection.count : 1 ;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 55)];
    [labelView setBackgroundColor:[UIColor whiteColor]];
    labelView.text = SCLocalizedString(@"Category");
    labelView.font = [UIFont fontWithName:THEME01_FONT_NAME_BOLD size:20];
    labelView.textAlignment = NSTextAlignmentCenter;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 54, labelView.frame.size.width, 1)];
    [v setBackgroundColor:[UIColor lightGrayColor]];
    [labelView addSubview:v];
    return labelView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cateCellIdentifier = @"CategoryCell";
    static NSString *loadingCateCell = @"LoadingCateCell";
    UITableViewCell *cell;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCategoryCell-Before" object:cell];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return cell;
    }
    if (categoryCollection.count > 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:cateCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cateCellIdentifier];
            [[NSNotificationCenter defaultCenter] postNotificationName:cateCellIdentifier object:nil userInfo:@{@"data": cell}];
        }
        if ([[[categoryCollection objectAtIndex:indexPath.row] valueForKey:@"has_child"] boolValue] &&[[[categoryCollection objectAtIndex:indexPath.row] valueForKey:@"is_selected"] boolValue]) {
            cell.textLabel.text = [[categoryCollection objectAtIndex:indexPath.row] valueForKey:@"category_name"];
            cell.textLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_BOLD size:18];
            [cell setBackgroundColor:[UIColor whiteColor]];
            cell.accessoryView = NULL;
            cell.userInteractionEnabled = YES;
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            if (indexPathRow == indexPath.row + 1) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }
        }else{
            cell.textLabel.text = [NSString stringWithFormat:@"   %@",[[categoryCollection objectAtIndex:indexPath.row] valueForKey:@"category_name"]];
            cell.textLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:18];
            cell.accessoryView = NULL;
            [cell setBackgroundColor:[UIColor whiteColor]];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            cell.userInteractionEnabled = YES;
            if (indexPathRow == indexPath.row + 1) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }
        }
    }else{
        if (_isFinishLoad) {
            _isFinishLoad = NO;
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cateCellIdentifier];
                [[NSNotificationCenter defaultCenter] postNotificationName:cateCellIdentifier object:nil userInfo:@{@"data": cell}];
            }
            cell.userInteractionEnabled = NO;
            self.tableView.userInteractionEnabled = NO;
            if ([[[categoryCollection objectAtIndex:indexPath.row] valueForKey:@"has_child"] boolValue] &&[[[categoryCollection objectAtIndex:indexPath.row] valueForKey:@"is_selected"] boolValue]) {
                cell.textLabel.text = [[categoryCollection objectAtIndex:indexPath.row] valueForKey:@"category_name"];
                cell.textLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_BOLD size:18];
                [cell setBackgroundColor:[UIColor colorWithWhite:0.92 alpha:1.0]];
                cell.accessoryView = NULL;
                cell.userInteractionEnabled = YES;
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                if (indexPathRow == indexPath.row + 1) {
                    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                }
            }else{
                cell.textLabel.text = [NSString stringWithFormat:@"   %@",[[categoryCollection objectAtIndex:indexPath.row] valueForKey:@"category_name"]];
                cell.textLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:18];
                cell.accessoryView = NULL;
                [cell setBackgroundColor:[UIColor whiteColor]];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                cell.userInteractionEnabled = YES;
                if (indexPathRow == indexPath.row + 1) {
                    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                }
            }
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
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCategoryCell-After" object:cell];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
    
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (SIMI_SYSTEM_IOS < 7.0) {
        if ([[[categoryCollection objectAtIndex:indexPath.row] valueForKey:@"has_child"] boolValue] &&[[[categoryCollection objectAtIndex:indexPath.row] valueForKey:@"is_selected"] boolValue]) {
            [cell setBackgroundColor:[UIColor whiteColor]];
        }else{
            [cell setBackgroundColor:[UIColor whiteColor]];
        }
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPathRow != [indexPath row] + 1) {
        [tableView setAllowsSelection:NO];
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activity setColor:THEME_COLOR];
        [activity startAnimating];
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryView:activity];
        if (indexPath.row != 0) {
            [[categoryCollection objectAtIndex:indexPath.row] setObject:@"YES" forKey:@"is_selected"];
        }
        for (int i = 1; i < indexPath.row; i++) {
            if (![[[categoryCollection objectAtIndex:i] valueForKey:@"has_child"] boolValue]) {
                [[categoryCollection objectAtIndex:i] setObject:@"NO" forKey:@"is_selected"];
            }
        }
        for (NSInteger i = indexPath.row + 1; i < [categoryCollection count]; i++) {
            if (i != 0) {
                [[categoryCollection objectAtIndex:i] setObject:@"NO" forKey:@"is_selected"];
            }
        }
        [self setCategoryId:[[categoryCollection objectAtIndex:indexPath.row] valueForKey:@"category_id"]];
        indexSelect = indexPath;
        [self getCategories];
    }else{
        [self.tableView reloadData];
    }
}


@end
