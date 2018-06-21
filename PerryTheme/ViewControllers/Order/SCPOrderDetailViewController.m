//
//  SCPOrderDetailViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 6/20/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPOrderDetailViewController.h"
#import "SCPLabel.h"

@interface SCPOrderDetailViewController ()

@end

@implementation SCPOrderDetailViewController

- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    paddingX = 15; paddingTop = 15; paddingBottom = 15; paddingItems = 15;paddingTopContentX = 20;
    paddingHeaderX = 15; paddingContentX = 30;paddingHeaderY = 15; paddingContentY = 15;  paddingContentItem = 15;
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.contentTableView.estimatedRowHeight = 0;
    self.view.backgroundColor = COLOR_WITH_HEX(@"#f2f2f2");
    self.contentTableView.backgroundColor = [UIColor clearColor];
    self.contentTableView.frame = CGRectMake(paddingX, paddingTop, CGRectGetWidth(self.view.frame) - 2*paddingX, CGRectGetHeight(self.view.frame) - paddingBottom);
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    SimiSection *simiSection = [self.cells objectAtIndex:section];
    NSString *headerTitle = simiSection.header.title;
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:nil];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.contentView.backgroundColor = [UIColor whiteColor];
    SimiLabel *lblHeader = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingHeaderX, paddingHeaderY, CGRectGetWidth(self.contentTableView.frame) - 2*paddingHeaderX, 20) andFontName:SCP_FONT_SEMIBOLD andFontSize:FONT_SIZE_HEADER andTextColor:[UIColor blackColor]];
    [lblHeader setText:[headerTitle uppercaseString]];
    if ([GLOBALVAR isReverseLanguage]) {
        [lblHeader setTextAlignment:NSTextAlignmentRight];
    }
    [headerView.contentView addSubview:lblHeader];
    return headerView;
}
- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if(!cell){
        cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        float tableWidth = CGRectGetWidth(self.contentTableView.frame);
        if([row.identifier isEqualToString:ORDER_DETAIL_SUMMARY]){
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.heightCell = 0;
            UIFont *titleFont = [UIFont fontWithName:SCP_FONT_SEMIBOLD size:FONT_SIZE_LARGE];
            UIFont *valueFont = [UIFont fontWithName:SCP_FONT_REGULAR size:FONT_SIZE_LARGE];
            SCPLabel *orderDateLabel = [[SCPLabel alloc] initWithFrame:CGRectMake(paddingTopContentX, cell.heightCell, tableWidth - 2*paddingTopContentX, 20)];
            [orderDateLabel showHTMLTextWithTitle:@"Order date" value:self.order.updatedAt titleFont:titleFont valueFont:valueFont];
            [orderDateLabel wrapContent];
            [cell.contentView addSubview:orderDateLabel];
            cell.heightCell += CGRectGetHeight(orderDateLabel.frame);
            
            SCPLabel *orderNumberLabel = [[SCPLabel alloc] initWithFrame:CGRectMake(paddingTopContentX, cell.heightCell, tableWidth - 2*paddingTopContentX, 20)];
            [orderNumberLabel showHTMLTextWithTitle:@"Order number" value:self.order.incrementId titleFont:titleFont valueFont:valueFont];
            [orderNumberLabel wrapContent];
            [cell.contentView addSubview:orderNumberLabel];
            cell.heightCell += CGRectGetHeight(orderNumberLabel.frame);
            
            SCPLabel *orderTotalLabel = [[SCPLabel alloc] initWithFrame:CGRectMake(paddingTopContentX, cell.heightCell, tableWidth - 2*paddingTopContentX, 20)];
            NSString *total;
            NSString *currency = @"";
            if ([self.order.total valueForKey:@"currency_symbol"]) {
                currency = [NSString stringWithFormat:@"%@",[self.order.total valueForKey:@"currency_symbol"]];
            }
            if ([self.order.total valueForKey:@"grand_total_incl_tax"]) {
                total = [[SimiFormatter sharedInstance]priceWithPrice:[NSString stringWithFormat:@"%@",[self.order.total valueForKey:@"grand_total_incl_tax"]]andCurrency:currency];
            }
            if ([self.order.total valueForKey:@"grand_total"]) {
                total = [[SimiFormatter sharedInstance]priceWithPrice:[NSString stringWithFormat:@"%@",[total valueForKey:@"grand_total"]]andCurrency:currency];
            }
            [orderTotalLabel showHTMLTextWithTitle:@"Order total" value:total titleFont:titleFont valueFont:valueFont];
            [orderTotalLabel wrapContent];
            [cell.contentView addSubview:orderTotalLabel];
            cell.heightCell += CGRectGetHeight(orderDateLabel.frame) + paddingTop;
        }else if([row.identifier isEqualToString:ORDER_DETAIL_SHIPPING_ADDRESS]){
            cell.heightCell = paddingContentY;
            SCPLabel *addressLabel = [[SCPLabel alloc] initWithFrame:CGRectMake(paddingContentX, cell.heightCell, tableWidth - 2*paddingContentX, 20)];
            [cell.contentView addSubview:addressLabel];
            addressLabel.text = [self.order.shippingAddress formatAddress];
            [addressLabel wrapContent];
            cell.heightCell += CGRectGetHeight(addressLabel.frame);
        }else if([row.identifier isEqualToString:ORDER_DETAIL_SHIPPING_METHOD]){
            cell.heightCell = paddingContentY;
            SCPLabel *addressLabel = [[SCPLabel alloc] initWithFrame:CGRectMake(paddingContentX, cell.heightCell, tableWidth - 2*paddingContentX, 20)];
            [cell.contentView addSubview:addressLabel];
            addressLabel.text = [self.order.shippingAddress formatAddress];
            [addressLabel wrapContent];
            cell.heightCell += CGRectGetHeight(addressLabel.frame) + paddingContentY;
        }else if([row.identifier isEqualToString:ORDER_DETAIL_PAYMENT_METHOD]){
            cell.heightCell = paddingContentY;
            SCPLabel *paymentMethodLabel = [[SCPLabel alloc] initWithFrame:CGRectMake(paddingContentX, cell.heightCell, tableWidth - 2*paddingContentX, 20)];
            paymentMethodLabel.text = self.order.paymentMethod;
            [cell.contentView addSubview:paymentMethodLabel];
            cell.heightCell += [paymentMethodLabel wrapContent];
        }else if([row.identifier isEqualToString:ORDER_DETAIL_BILLING_ADDRESS]){
            cell.heightCell = paddingContentY;
            SCPLabel *addressLabel = [[SCPLabel alloc] initWithFrame:CGRectMake(paddingContentX, cell.heightCell, tableWidth - 2*paddingContentX, 20)];
            [cell.contentView addSubview:addressLabel];
            addressLabel.text = [self.order.billingAddress formatAddress];
            [addressLabel wrapContent];
            cell.heightCell += CGRectGetHeight(addressLabel.frame);
        }else if([row.identifier isEqualToString:ORDER_DETAIL_CART]){
            
        }else if([row.identifier isEqualToString:ORDER_DETAIL_COUPONCODE]){
            
        }else if([row.identifier isEqualToString:ORDER_DETAIL_TOTAL]){
            
        }
    }
    return cell;
}
@end
