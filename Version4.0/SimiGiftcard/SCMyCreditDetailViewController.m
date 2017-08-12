//
//  SCMyCreditDetailViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/11/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCMyCreditDetailViewController.h"

@interface SCMyCreditDetailViewController ()

@end

@implementation SCMyCreditDetailViewController

- (void)viewDidLoadBefore{
    self.navigationItem.title = SCLocalizedString(@"MY GIFT CARD CREDIT");
    if ([[self.giftCardCreditModel valueForKey:@"history"] isKindOfClass:[NSArray class]]) {
        myCreditHistories = [self.giftCardCreditModel valueForKey:@"history"];
        [self setCells:nil];
    }
}

- (void)viewDidAppearBefore:(BOOL)animated{
    if (myCreditTableView == nil) {
        myCreditTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        myCreditTableView.delegate = self;
        myCreditTableView.dataSource = self;
        myCreditTableView.tableFooterView = [UIView new];
        [self.view addSubview:myCreditTableView];
    }
}

- (void)setCells:(SimiTable *)cells{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [SimiTable new];
        SimiSection *mainSection = [_cells addSectionWithIdentifier:@"main_section"];
        [mainSection addRowWithIdentifier:mycredit_creditinfo_row height:110];
        if (myCreditHistories.count > 0) {
            for (int i = 0; i < myCreditHistories.count; i++) {
                SimiRow *row = [mainSection addRowWithIdentifier:mycredit_credithistory_row height:160 sortOrder:0];
                row.data = [[NSMutableDictionary alloc]initWithDictionary:[myCreditHistories objectAtIndex:i]];
            }
        }
    }
    [myCreditTableView reloadData];
}

#pragma mark TableView Delegate&DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [simiSection objectAtIndex:indexPath.row];
    UITableViewCell *cell = nil;
    if ([row.identifier isEqualToString:mycredit_creditinfo_row]) {
        cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
        if (cell == nil) {
            float padding = 10;
            float cellWidth = SCREEN_WIDTH;
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
            SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, padding, cellWidth - padding*2, 30) andFontName:THEME_FONT_NAME_REGULAR andFontSize:20 andTextColor:THEME_CONTENT_COLOR text:@"Balance"];
            [cell.contentView addSubview:titleLabel];
            
            SimiLabel *myCreditLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, padding + 25, cellWidth - padding*2, 30) andFontName:THEME_FONT_NAME andFontSize:18 andTextColor:THEME_CONTENT_COLOR];
            NSString *balance = [NSString stringWithFormat:@"%@",[self.giftCardCreditModel valueForKey:@"balance"]];
            balance = [[SimiFormatter sharedInstance] priceWithPrice:balance];
            [myCreditLabel setText:[NSString stringWithFormat:@"%@: %@", SCLocalizedString(@"My credit balance"), balance]];
            [cell.contentView addSubview:myCreditLabel];
            
            SimiLabel *balaceTitleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, padding + 60, cellWidth - padding*2, 30) andFontName:THEME_FONT_NAME_REGULAR andFontSize:20 andTextColor:THEME_CONTENT_COLOR text:@"Balance History"];
            [cell.contentView addSubview:balaceTitleLabel];
        }
    }else if ([row.identifier isEqualToString:mycredit_credithistory_row]){
        NSString *identifer = [NSString stringWithFormat:@"%@_%@",mycredit_credithistory_row,[row.data valueForKey:@"history_id"]];
        MyCreditHistoryTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:identifer];
        if (aCell == nil) {
            aCell = [[MyCreditHistoryTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer info:row.data];
        }
        cell = aCell;
    }
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setPreservesSuperviewLayoutMargins:NO];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    if (cell == nil) {
        cell = [UITableViewCell new];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SimiSection *simiSection = [self.cells objectAtIndex:section];
    return simiSection.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [simiSection objectAtIndex:indexPath.row];
    return row.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

@implementation MyCreditHistoryTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier info:(NSDictionary*)info{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    float labelHeight = 25;
    float height = 5;
    float padding = 10;
    float titleWidth = 120;
    float valueWidth = 140;
    float cellWidth = SCREEN_WIDTH;
    if(self){
        SimiLabel *actionLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Action"];
        [self.contentView addSubview:actionLabel];
        
        NSString *actionValue = [info valueForKey:@"action"];
        SimiLabel *actionValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:actionValue];
        [self.contentView addSubview:actionValueLabel];
        height += labelHeight;
    
        SimiLabel *balanceChangeLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Balance Change"];
        [self.contentView addSubview:balanceChangeLabel];
        
        NSString *balanceChangeValue = [[SimiFormatter sharedInstance]priceWithPrice:[info valueForKey:@"balance_change"]];
        SimiLabel *balanceChangeValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:balanceChangeValue];
        [self.contentView addSubview:balanceChangeValueLabel];
        height += labelHeight;
        
        SimiLabel *giftCodeLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Gift Card Code"];
        [self.contentView addSubview:giftCodeLabel];
        
        SimiLabel *giftCodeValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:[info valueForKey:@"giftcard_code"]];
        [self.contentView addSubview:giftCodeValueLabel];
        height += labelHeight;
        
        SimiLabel *orderNumberLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Order"];
        [self.contentView addSubview:orderNumberLabel];
        
        NSString *orderValue = [info valueForKey:@"order_number"];
        if ([orderValue isEqualToString:@""]) {
            orderValue = @"N/A";
        }
        SimiLabel *orderValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:orderValue];
        [self.contentView addSubview:orderValueLabel];
        height += labelHeight;
        
        SimiLabel *currentBalanceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Current Balance"];
        [self.contentView addSubview:currentBalanceLabel];
        
        NSString *currentBalanceValue = [[SimiFormatter sharedInstance]priceWithPrice:[info valueForKey:@"currency_balance"]];
        SimiLabel *currentBalanceValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:currentBalanceValue];
        [self.contentView addSubview:currentBalanceValueLabel];
        height += labelHeight;
        
        SimiLabel *changedTimeLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Changed Time"];
        [self.contentView addSubview:changedTimeLabel];
        
        NSString *changedTimeValue = [info valueForKey:@"created_date"];
        SimiLabel *changedTimeValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:changedTimeValue];
        [self.contentView addSubview:changedTimeValueLabel];
        height += labelHeight;
        
        [SimiGlobalVar sortViewForRTL:self.contentView andWidth:cellWidth];
    }
    return self;
}

@end
