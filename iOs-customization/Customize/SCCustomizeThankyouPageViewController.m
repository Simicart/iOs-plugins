//
//  SCCustomizeThankyouPageViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 7/19/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCustomizeThankyouPageViewController.h"
#define CUSTOMIZE_TKPAGE_ORDER_INFO @"CUSTOMIZE_TKPAGE_ORDER_INFO"

@interface SCCustomizeThankyouPageViewController ()

@end

@implementation SCCustomizeThankyouPageViewController
- (void)createCells{
    SimiSection *mainSection = [self.cells addSectionWithIdentifier:@"mainSection"];
    [mainSection addRowWithIdentifier:CUSTOMIZE_TKPAGE_ORDER_INFO];
}
- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if(!cell){
        cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if([row.identifier isEqualToString:CUSTOMIZE_TKPAGE_ORDER_INFO]){
            cell.heightCell = 30;
            float titlePadding = 30;
            float buttonPadding = 15;
            float messagePadding = 20;
            float cellWidth = CGRectGetWidth(self.contentTableView.frame);
            SimiLabel *titleLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(titlePadding, cell.heightCell, cellWidth - 2*titlePadding, 25) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_HEADER andTextColor:THEME_BUTTON_BACKGROUND_COLOR text:[NSString stringWithFormat:@"%@",[self.order objectForKey:@"title"]]];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            [titleLabel resizLabelToFit];
            [cell.contentView addSubview:titleLabel];
            cell.heightCell += CGRectGetHeight(titleLabel.frame) + 30;
            SimiButton *viewOrderButton = [[SimiButton alloc] initWithFrame:CGRectMake(buttonPadding, cell.heightCell, cellWidth - 2*buttonPadding, 44) title:[NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"ORDER NO"),self.order.invoiceNumber]];
            [viewOrderButton addTarget:self action:@selector(viewOrder:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:viewOrderButton];
            cell.heightCell += CGRectGetHeight(viewOrderButton.frame) + 30;
            
            SimiLabel *messageLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(messagePadding, cell.heightCell, cellWidth - 2*messagePadding, 25) andFontName:THEME_FONT_NAME andFontSize:FONT_SIZE_LARGE andTextColor:THEME_CONTENT_COLOR text:[NSString stringWithFormat:@"%@",[self.order objectForKey:@"message"]]];
            messageLabel.textAlignment = NSTextAlignmentCenter;
            [messageLabel resizLabelToFit];
            [cell.contentView addSubview:messageLabel];
            cell.heightCell += CGRectGetHeight(messageLabel.frame) + 30;
        }
    }
    row.height = cell.heightCell;
    return cell;
}
- (void)viewOrder:(id)sender{
    [[SCAppController sharedInstance]openOrderHistoryDetailScreenWithNavigationController:self.navigationController moreParams:@{KEYEVENT.ORDERHISTORYDETAILVIEWCONTROLLER.order_id:self.order.invoiceNumber}];
}
- (void)contentTableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
@end
