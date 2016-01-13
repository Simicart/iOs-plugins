//
//  SCMenuSort_Theme01.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 4/29/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCMenuSort_Theme01.h"
#import "SimiGlobalVar+Theme01.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface SCMenuSort_Theme01 (){
    NSArray *arraySort;
    CGFloat tableWidth;
}

@end

@implementation SCMenuSort_Theme01

@synthesize rowSelect;
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
    [self.tableView setTintColor:[UIColor orangeColor]];
    tableWidth = 300;
    arraySort = [NSArray arrayWithObjects:
                          @"None",
                          @"Price: Low to High",
                          @"Price: High to Low",
                          @"Name: A -> Z",
                          @"Name: Z -> A",
                          nil];
    rowSelect = 0;
    NSInteger rowsCount = [arraySort count];
//    NSInteger singleRowHeight = [self.tableView.delegate tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSInteger totalRowsHeight = (rowsCount + 1) * 55;
    self.contentSizeForViewInPopover = CGSizeMake(tableWidth, totalRowsHeight);
    
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
    return [arraySort count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cateCellIdentifier = @"CategoryCell";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:cateCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cateCellIdentifier];
        [[NSNotificationCenter defaultCenter] postNotificationName:cateCellIdentifier object:nil userInfo:@{@"data": cell}];
    }
    cell.textLabel.text = SCLocalizedString(arraySort[indexPath.row]);
    cell.textLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:16];
    //  Liam RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [cell.textLabel setTextAlignment:NSTextAlignmentRight];
    }
    //  End RTL
     cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.row == rowSelect) {
         cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 55;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 55)];
    [labelView setBackgroundColor:[UIColor whiteColor]];
    labelView.text = [SCLocalizedString(@"Sort") uppercaseString];
    labelView.font = [UIFont fontWithName:THEME01_FONT_NAME_BOLD size:THEME_FONT_SIZE];
    labelView.textAlignment = NSTextAlignmentCenter;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 54, labelView.frame.size.width, 1)];
    [v setBackgroundColor:[UIColor lightGrayColor]];
    [labelView addSubview:v];
    return labelView;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    rowSelect = (int)indexPath.row;
    [self.tableView reloadData];
    ProductCollectionSortType sortType;
    switch (indexPath.row) {
        case 1:
            sortType = ProductCollectionSortPriceLowToHigh;
            break;
        case 2:
            sortType = ProductCollectionSortPriceHighToLow;
            break;
        case 3:
            sortType = ProductCollectionSortNameASC;
            break;
        case 4:
            sortType = ProductCollectionSortNameDESC;
            break;
        default:
            sortType = ProductCollectionSortNone;
            break;
    }
    [self.delegate selectedMenuSort:sortType rowSelect:rowSelect];
}
@end
