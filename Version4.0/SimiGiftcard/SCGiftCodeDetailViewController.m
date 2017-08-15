//
//  SCGiftCodeDetailViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/13/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCGiftCodeDetailViewController.h"
#import "SimiTable.h"
#import "SimiTextView.h"

@interface SCGiftCodeDetailViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) SimiTable *cells;
@end

@implementation SCGiftCodeDetailViewController
- (void)viewDidLoadBefore{
    self.navigationItem.title = SCLocalizedString(@"GIFT CARD CODE DETAILS");
}

- (void)viewDidAppearBefore:(BOOL)animated{
    if (giftCodeDetailTableView == nil) {
        giftCodeDetailTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        giftCodeDetailTableView.delegate = self;
        giftCodeDetailTableView.dataSource = self;
        giftCodeDetailTableView.tableFooterView = [UIView new];
        [self.view addSubview:giftCodeDetailTableView];
    }
    [self getGiftCodeDetailInfo];
}

- (void)getGiftCodeDetailInfo{
    giftCodeModel = [SimiGiftCodeModel new];
    [giftCodeModel getGiftCodeDetailWithParams:@{@"id":self.giftCodeId}];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetGiftCodeDetail:) name:DidGetGiftCodeDetail object:giftCodeModel];
    [self startLoadingData];
}

- (void)didGetGiftCodeDetail:(NSNotification*)noti{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if ([[giftCodeModel valueForKey:@"history"] isKindOfClass:[NSArray class]]) {
            giftCodeHistories = [giftCodeModel valueForKey:@"history"];
        }
        [self setCells:nil];
    }else
        [self showAlertWithTitle:responder.status message:responder.responseMessage];
}

- (void)setCells:(SimiTable *)cells{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [SimiTable new];
        SimiSection *mainSection = [_cells addSectionWithIdentifier:@"main_section"];
        [mainSection addRowWithIdentifier:giftcode_info_row height:180];
        if (giftCodeHistories.count > 0) {
            for (int i = 0; i < giftCodeHistories.count; i++) {
                SimiRow *row = [mainSection addRowWithIdentifier:giftcode_history_row height:160 sortOrder:0];
                row.data = [[NSMutableDictionary alloc]initWithDictionary:[giftCodeHistories objectAtIndex:i]];
            }
        }
    }
    [giftCodeDetailTableView reloadData];
}

#pragma mark TableView Delegate&DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [simiSection objectAtIndex:indexPath.row];
    UITableViewCell *cell = nil;
    if ([row.identifier isEqualToString:giftcode_info_row]) {
        cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
            float labelHeight = 25;
            float height = 5;
            float padding = 10;
            float titleWidth = 120;
            float cellWidth = SCREEN_WIDTH;
            float valueWidth = cellWidth - titleWidth - padding*3;
            NSString *currencySymbol = @"";
            if ([giftCodeModel valueForKey:@"currency_symbol"] && ![[giftCodeModel valueForKey:@"currency_symbol"] isKindOfClass:[NSNull class]]) {
                currencySymbol = [giftCodeModel valueForKey:@"currency_symbol"];
            }
            
            SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, cellWidth - padding*2, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:20 andTextColor:THEME_CONTENT_COLOR text:@"Gift Card Code Information"];
            [cell.contentView addSubview:titleLabel];
            height += 30;
            
            SimiLabel *giftCardCodeLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Gift Card Code"];
            [cell.contentView addSubview:giftCardCodeLabel];
            
            SimiTextView *giftCardCodeTextView = [[SimiTextView alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, 170, 40) font:[UIFont systemFontOfSize:16 weight:UIFontWeightSemibold] borderWidth:1 borderColor:[UIColor lightGrayColor] paddingLeft:10];
            giftCardCodeTextView.layer.cornerRadius = 6;
            giftCardCodeTextView.editable = NO;
            giftCardCodeTextView.text = [giftCodeModel valueForKey:@"gift_code"];
            [cell.contentView addSubview:giftCardCodeTextView];
            height += 40;
            
            SimiLabel *balanceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Balance"];
            [cell.contentView addSubview:balanceLabel];
            
            SimiLabel *balanceValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@""];
            [cell.contentView addSubview:balanceValueLabel];
            height += labelHeight;
            
            SimiLabel *statusLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Status"];
            [cell.contentView addSubview:statusLabel];
            
            SimiLabel *statusValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@""];
            [cell.contentView addSubview:statusValueLabel];
            height += labelHeight;
            
            SimiLabel *addedLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Added Date"];
            [cell.contentView addSubview:addedLabel];
            
            NSString *addedValue = [giftCodeModel valueForKey:@"added_date"];
            SimiLabel *addedValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:addedValue];
            [cell.contentView addSubview:addedValueLabel];
            height += labelHeight;
            
            SimiLabel *expiredLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Expired Date"];
            [cell.contentView addSubview:expiredLabel];
            
            NSString *expiredValue = [giftCodeModel valueForKey:@"expired_at"];
            SimiLabel *expiredValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:expiredValue];
            [cell.contentView addSubview:expiredValueLabel];
            height += labelHeight;
            
            NSString *statusValue = [giftCodeModel valueForKey:@"status"];
            switch ([statusValue integerValue]) {
                case 1:
                    statusValue = @"Pending";
                    break;
                case 2:
                    statusValue = @"Active";
                    break;
                case 3:
                    statusValue = @"Disabled";
                    break;
                case 4:
                    statusValue = @"Used";
                    break;
                case 5:
                    statusValue = @"Expried";
                    break;
                case 6:
                    statusValue = @"Deleted";
                    break;
                default:
                    break;
            }
            [statusValueLabel setText:statusValue];
            NSString *balanceValue = [[SimiFormatter sharedInstance]priceWithPrice:[giftCodeModel valueForKey:@"balance"] andCurrency:currencySymbol];
            [balanceValueLabel setText:balanceValue];
            
            SimiLabel *historyLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, cellWidth - padding*2, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:20 andTextColor:THEME_CONTENT_COLOR text:@"History"];
            [cell.contentView addSubview:historyLabel];
            height += 30;
            [SimiGlobalVar sortViewForRTL:cell.contentView andWidth:cellWidth];
            row.height = height;
        }
    }else if ([row.identifier isEqualToString:giftcode_history_row]){
        NSString *identifer = [NSString stringWithFormat:@"%@_%@",giftcode_history_row,[row.data valueForKey:@"history_id"]];
        GiftCodeHistoryTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:identifer];
        if (aCell == nil) {
            aCell = [[GiftCodeHistoryTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer info:row.data];
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

@implementation GiftCodeHistoryTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier info:(NSDictionary*)info{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    float labelHeight = 25;
    float height = 5;
    float padding = 10;
    float titleWidth = 120;
    float cellWidth = SCREEN_WIDTH;
    float valueWidth = cellWidth - titleWidth - padding*3;
    if(self){
        SimiLabel *actionLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Action"];
        [self.contentView addSubview:actionLabel];
        
        NSString *actionValue = [info valueForKey:@"action"];
        switch ([actionValue integerValue]) {
            case 1:
                actionValue = @"Create";
                break;
            case 2:
                actionValue = @"Update";
                break;
            case 3:
                actionValue = @"Mass Update";
                break;
            case 4:
                actionValue = @"Email";
                break;
            case 5:
                actionValue = @"Spend Order";
                break;
            case 6:
                actionValue = @"Refund";
                break;
            case 7:
                actionValue = @"Redeem";
                break;
            default:
                break;
        }
        NSString *currencySymbol = @"";
        if ([info valueForKey:@"currency_symbol"] && ![[info valueForKey:@"currency_symbol"] isKindOfClass:[NSNull class]]) {
            currencySymbol = [info valueForKey:@"currency_symbol"];
        }
        SimiLabel *actionValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:actionValue];
        [self.contentView addSubview:actionValueLabel];
        height += labelHeight;
        
        SimiLabel *balanceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Balance"];
        [self.contentView addSubview:balanceLabel];
        
        NSString *balanceValue = [[SimiFormatter sharedInstance]priceWithPrice:[info valueForKey:@"balance"] andCurrency:currencySymbol];
        SimiLabel *balanceValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:balanceValue];
        [self.contentView addSubview:balanceValueLabel];
        height += labelHeight;
        
        SimiLabel *changedTimeLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Date"];
        [self.contentView addSubview:changedTimeLabel];
        
        NSString *changedTimeValue = [info valueForKey:@"created_at"];
        SimiLabel *changedTimeValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:changedTimeValue];
        [self.contentView addSubview:changedTimeValueLabel];
        height += labelHeight;
        
        SimiLabel *balanceChangeLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Balance Change"];
        [self.contentView addSubview:balanceChangeLabel];
        
        NSString *balanceChangeValue = [[SimiFormatter sharedInstance]priceWithPrice:[info valueForKey:@"amount"] andCurrency:currencySymbol];
        SimiLabel *balanceChangeValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:balanceChangeValue];
        [self.contentView addSubview:balanceChangeValueLabel];
        height += labelHeight;
        
        SimiLabel *orderNumberLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Order"];
        [self.contentView addSubview:orderNumberLabel];
        
        NSString *orderValue = [info valueForKey:@"order_increment_id"];
        if ([orderValue isEqualToString:@""]) {
            orderValue = @"N/A";
        }
        SimiLabel *orderValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:orderValue];
        [self.contentView addSubview:orderValueLabel];
        height += labelHeight;
        
        SimiLabel *commentsLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Comments"];
        [self.contentView addSubview:commentsLabel];
        if (![[info valueForKey:@"comments"] isKindOfClass:[NSNull class]] && [info valueForKey:@"comments"]) {
            SimiLabel *commentsValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:[info valueForKey:@"comments"]];
            [self.contentView addSubview:commentsValueLabel];
            height += labelHeight;
        }
        
        [SimiGlobalVar sortViewForRTL:self.contentView andWidth:cellWidth];
    }
    return self;
}

@end
