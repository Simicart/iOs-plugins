//
//  TimeLoaderViewController.m
//  SimiCartPluginFW
//
//  Created by Gin-Wishky on 10/14/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "TimeLoaderDetailViewController.h"
#import "SimiSection.h"

@interface TimeLoaderDetailViewController (){
    
}

@end

@implementation TimeLoaderDetailViewController
@synthesize timeLoaderTableDetail,arrayDetail,stringHeader;

-(void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    if(arrayDetail == nil){
        arrayDetail = [[NSMutableArray alloc] init];
    }
    timeLoaderTableDetail = [[SimiTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    timeLoaderTableDetail.delegate = self;
    timeLoaderTableDetail.dataSource = self;
    [self.view addSubview:timeLoaderTableDetail];
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
        simiSection.headerTitle = stringHeader;
        simiSection.identifier = stringHeader;
        if(arrayDetail.count >0){
            for (int i = 0; i < arrayDetail.count; i++) {
                SimiRow *row = [[SimiRow alloc] init];
                row.height = 44;
                row.identifier = [NSString stringWithFormat:@"%i",i];
                [simiSection addRow:row];
            }
        }
        SimiRow *rowAverage = [[SimiRow alloc] init];
        rowAverage.height = 44;
        rowAverage.identifier = @"Average";
        [simiSection addRow:rowAverage];
        
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
    if ([simiRow.identifier isEqualToString:[NSString stringWithFormat:@"%li",indexPath.row]]){
        cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *lbStt = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 50, 44)];
            lbStt.text = [NSString stringWithFormat:@"%li",(indexPath.row +1)];
            [cell addSubview:lbStt];
            
            UILabel *lbTime = [[UILabel alloc] initWithFrame:CGRectMake(200, 0,250 , 44)];
            lbTime.text = [[arrayDetail objectAtIndex:indexPath.row] stringValue];
            [cell addSubview:lbTime];
        }
    }else if ([simiRow.identifier isEqualToString:[NSString stringWithFormat:@"Average"]]){
            cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UILabel *lbStt = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 44)];
                lbStt.text = @"Average";
                [cell addSubview:lbStt];
                float Sum = 0;
                for (int i = 0; i< arrayDetail.count; i++) {
                    Sum = Sum +[[arrayDetail objectAtIndex:i] doubleValue];
                }
                UILabel *lbTime = [[UILabel alloc] initWithFrame:CGRectMake(200, 0,150 , 44)];
                lbTime.text = [NSString stringWithFormat:@"%.3f",Sum/arrayDetail.count];
                [cell addSubview:lbTime];
                
            }
    }
    return cell;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle = @"";
    SimiSection *simiSection = [_cells objectAtIndex:section];
    headerTitle = simiSection.headerTitle;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, tableView.bounds.size.width, 30)];
    UILabel *headerTitleSection = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, tableView.bounds.size.width - 20, 30)];
    headerTitleSection.text = headerTitle;
    [headerTitleSection setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
    [headerTitleSection setTextAlignment:NSTextAlignmentCenter];
    [headerView addSubview:headerTitleSection];
    headerView.backgroundColor = [[SimiGlobalVar sharedInstance]colorWithHexString:@"#ededed"];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}
@end
