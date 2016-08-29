//
//  CategoryTImeLoaderViewController.m
//  SimiCartPluginFW
//
//  Created by Gin-Wishky on 10/20/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "CategoryTimeLoaderViewController.h"
#import "SimiSection.h"
#import "TimeLoaderViewController.h"
NSString *  APITimeLoader = @"APITimeLoader";
NSString *  SCREENTimeLoader = @"SCREENTimeLoader";
@interface CategoryTimeLoaderViewController ()

@end

@implementation CategoryTimeLoaderViewController
@synthesize timeLoaderCategory,dictAPIDataTimeLoader,dictAPIScreenDataTimeLoader;
-(void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    if(dictAPIDataTimeLoader == nil){
        dictAPIDataTimeLoader = [[NSMutableDictionary alloc] init];
    }
    if(dictAPIScreenDataTimeLoader == nil){
        dictAPIScreenDataTimeLoader = [[NSMutableDictionary alloc] init];
    }
    timeLoaderCategory = [[SimiTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    timeLoaderCategory.delegate = self;
    timeLoaderCategory.dataSource = self;
    [self.view addSubview:timeLoaderCategory];
    [self setCells:nil];
}
-(void)viewDidLoadAfter{
    
}
- (void)setCells:(NSMutableArray *)cells{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [[NSMutableArray alloc] init];
        SimiSection *simiSection = [[SimiSection alloc] init];
        if(dictAPIDataTimeLoader.count > 0){
            SimiRow *row = [[SimiRow alloc] init];
            row.identifier = APITimeLoader;
            row.height = 50;
            [simiSection addRow:row];
        }
        if(dictAPIScreenDataTimeLoader.count > 0){
            SimiRow *row = [[SimiRow alloc] init];
            row.identifier = SCREENTimeLoader;
            row.height = 50;
            [simiSection addRow:row];
        }
        [_cells addObject:simiSection];
    }
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _cells.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SimiSection *simiSection = [_cells objectAtIndex:section];
    return simiSection.rows.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    return simiRow.height;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    if ([simiRow.identifier isEqualToString:APITimeLoader]){
        cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *lbTime = [[UILabel alloc] initWithFrame:CGRectMake(10, 0,300 , 44)];
            [lbTime setTextAlignment:NSTextAlignmentCenter];
            lbTime.text = @"API TimeLoader";
            [cell addSubview:lbTime];
        }
    }else if ([simiRow.identifier isEqualToString:SCREENTimeLoader]){
        cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *lbTime = [[UILabel alloc] initWithFrame:CGRectMake(10, 0,300 , 44)];
            [lbTime setTextAlignment:NSTextAlignmentCenter];
            lbTime.text = @"SCREEN TimeLoader";
            [cell addSubview:lbTime];
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    TimeLoaderViewController *nextVC = [[TimeLoaderViewController alloc] init];

    if ([simiRow.identifier isEqualToString:APITimeLoader]){
        nextVC.dictdata = dictAPIDataTimeLoader ;
    }else if ([simiRow.identifier isEqualToString:SCREENTimeLoader]){
        nextVC.dictdata = dictAPIScreenDataTimeLoader ;
    }
    [self.navigationController pushViewController:nextVC animated:YES];
}

@end
