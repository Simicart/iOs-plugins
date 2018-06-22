//
//  SCPOrderDetailViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 6/20/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPOrderDetailViewController.h"
#import "SCPLabel.h"
#import "SCPCartCell.h"
#import "SCPOrderFeeCell.h"
#import "SCPButton.h"

@interface SCPOrderDetailViewController ()

@end

@implementation SCPOrderDetailViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    paddingX = 15; paddingTop = 15; paddingBottom = 15; paddingItems = 15;paddingTopContentX = 20;
    paddingHeaderX = 15; paddingContentX = 30;paddingHeaderY = 15; paddingContentY = 15;  paddingContentItem = 15;
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.contentTableView.estimatedRowHeight = 0;
    self.view.backgroundColor = COLOR_WITH_HEX(@"#f2f2f2");
    self.contentTableView.backgroundColor = [UIColor clearColor];
    self.contentTableView.showsVerticalScrollIndicator = NO;
    self.contentTableView.frame = CGRectMake(paddingX, paddingTop, CGRectGetWidth(self.view.frame) - 2*paddingX, CGRectGetHeight(self.view.frame) - paddingBottom);
}
- (void)viewDidAppearBefore:(BOOL)animated{
    [super viewDidAppearBefore:animated];
}
- (void)viewReorder{
    CGRect frameButon = CGRectMake(0, CGRectGetHeight(self.view.frame) - 44, SCREEN_WIDTH, 44);
    if (PADDEVICE) {
        frameButon = CGRectMake(0, CGRectGetHeight(self.view.frame) - 44, SCREEN_WIDTH *2/3, 44);
    }
    SCPButton *reOrderButton = [[SCPButton alloc] initWithFrame:frameButon title:@"Reorder" titleFont:[UIFont fontWithName:SCP_FONT_SEMIBOLD size:FONT_SIZE_HEADER] cornerRadius:0 borderWidth:0 borderColor:[UIColor clearColor]];
    reOrderButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [reOrderButton addTarget:self action:@selector(reOrder:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:reOrderButton];
}
- (void)createCells{
    SimiSection *summarySection = [[SimiSection alloc] init];
    SimiRow *summaryRow = [[SimiRow alloc] initWithIdentifier:ORDER_DETAIL_SUMMARY height:75];
    [summarySection addRow:summaryRow];
    [self.cells addObject:summarySection];
    //Add shipping section
    float widthCell = SCREEN_WIDTH - 30;
    if (PADDEVICE) {
        widthCell = SCREEN_WIDTH *2/3 - 30;
    }
    if(self.order.shippingMethod){
        SimiSection *shippingSection = [[SimiSection alloc] init];
        shippingSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"Ship To") height:52];
        SimiRow *shippingAddressRow = [[SimiRow alloc] initWithIdentifier:ORDER_DETAIL_SHIPPING_ADDRESS];
        [shippingSection addRow:shippingAddressRow];
        
        SimiRow *shippingMethodRow = [[SimiRow alloc] initWithIdentifier:ORDER_DETAIL_SHIPPING_METHOD];
        [shippingSection addRow:shippingMethodRow];
        [self.cells addObject:shippingSection];
    }
    
    //Add billing & payment & coupon section
    SimiSection *billingSection = [[SimiSection alloc] init];
    billingSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"Payment") height:52];
    SimiRow *paymentRow = [[SimiRow alloc] initWithIdentifier:ORDER_DETAIL_PAYMENT_METHOD];
    [billingSection addRow:paymentRow];
    
    SimiRow *billingAddressRow = [[SimiRow alloc] initWithIdentifier:ORDER_DETAIL_BILLING_ADDRESS];
    [billingSection addRow:billingAddressRow];
    
    SimiRow *couponcode = [[SimiRow alloc]initWithIdentifier:ORDER_DETAIL_COUPONCODE];
    [billingSection addRow:couponcode];
    [self.cells addObject:billingSection];
    
    //Add cart item section
    SimiSection *cartSection = [[SimiSection alloc] init];
    cartSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"Items") height:52];
    if(self.order.orderItems.count > 0){
        for(int i = 0; i < self.order.orderItems.count; i++){
            SimiRow *cartItemRow = [[SimiRow alloc] initWithIdentifier:ORDER_DETAIL_CART];
            [cartSection addRow:cartItemRow];
        }
    }
    [self.cells addObject:cartSection];
    
    //Add order total section
    SimiSection *orderTotalSection = [[SimiSection alloc] init];
    orderTotalSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"Fee Detail") height:52];
    if (!GLOBALVAR.isReverseLanguage) {
        [orderTotalSection addRowWithIdentifier:ORDER_DETAIL_TOTAL];
    }else
        [orderTotalSection addRowWithIdentifier:ORDER_DETAIL_TOTAL];
    [self.cells addObject:orderTotalSection];
    [self endInitCellsWithInfo:@{}];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    SimiSection *simiSection = [self.cells objectAtIndex:section];
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:nil];
    if(simiSection.header){
        headerView.backgroundColor = [UIColor clearColor];
        headerView.contentView.backgroundColor = [UIColor clearColor];
        SCPLabel *lblHeader = [[SCPLabel alloc]initWithFrame:CGRectMake(paddingHeaderX, paddingHeaderY, CGRectGetWidth(self.contentTableView.frame) - 2*paddingHeaderX, 20) andFontName:SCP_FONT_SEMIBOLD andFontSize:FONT_SIZE_HEADER andTextColor:[UIColor blackColor]];
        [lblHeader setText:simiSection.header.title];
        if ([GLOBALVAR isReverseLanguage]) {
            [lblHeader setTextAlignment:NSTextAlignmentRight];
        }
        UIView *headerContentView = [[UIView alloc]initWithFrame:CGRectMake(0, paddingItems, CGRectGetWidth(self.contentTableView.frame), paddingHeaderY + [lblHeader wrapContent])];
        headerContentView.backgroundColor = [UIColor whiteColor];
        [headerContentView addSubview:lblHeader];
        [headerView addSubview:headerContentView];
        simiSection.header.height = paddingItems + CGRectGetHeight(headerContentView.frame);
    }
    return headerView;
}
- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if([row.identifier isEqualToString:ORDER_DETAIL_CART]){
        NSInteger rowIndex = [indexPath row];
        SimiQuoteItemModel *item = [[SimiQuoteItemModel alloc]initWithModelData:[self.order.orderItems objectAtIndex:rowIndex]];
        NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%@",row.identifier, item.itemId];
        SCPCartCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[SCPCartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier quoteItemModel:item useOnOrderPage:YES];
            cell.contentWidth = CGRectGetWidth(self.contentTableView.frame);
            cell.paddingX = 0;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
            NSString *currency = GLOBALVAR.currencySymbol;
            if ([self.order.total valueForKey:@"currency_symbol"]) {
                currency = [NSString stringWithFormat:@"%@",[self.order.total valueForKey:@"currency_symbol"]];
            }
            cell.currencySymbol = currency;
            cell.heightCell += paddingContentY;
        }
        row.height = cell.heightCell;
        return cell;
    }
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if(!cell){
        cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        float tableWidth = CGRectGetWidth(self.contentTableView.frame);
        if([row.identifier isEqualToString:ORDER_DETAIL_SUMMARY]){
            cell.backgroundColor = [UIColor clearColor];
            cell.heightCell = 0;
            UIFont *titleFont = [UIFont fontWithName:SCP_FONT_SEMIBOLD size:FONT_SIZE_LARGE];
            UIFont *valueFont = [UIFont fontWithName:SCP_FONT_REGULAR size:FONT_SIZE_LARGE];
            SCPLabel *orderDateLabel = [[SCPLabel alloc] initWithFrame:CGRectMake(paddingTopContentX, cell.heightCell, tableWidth - 2*paddingTopContentX, 20)];
            [orderDateLabel showHTMLTextWithTitle:@"Order date" value:self.order.updatedAt titleFont:titleFont valueFont:valueFont];
            [orderDateLabel wrapContent];
            [cell.contentView addSubview:orderDateLabel];
            cell.heightCell += CGRectGetHeight(orderDateLabel.frame) + paddingContentItem;
            
            SCPLabel *orderNumberLabel = [[SCPLabel alloc] initWithFrame:CGRectMake(paddingTopContentX, cell.heightCell, tableWidth - 2*paddingTopContentX, 20)];
            [orderNumberLabel showHTMLTextWithTitle:@"Order number" value:self.order.incrementId titleFont:titleFont valueFont:valueFont];
            [orderNumberLabel wrapContent];
            [cell.contentView addSubview:orderNumberLabel];
            cell.heightCell += CGRectGetHeight(orderNumberLabel.frame) + paddingContentItem;
            
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
            cell.heightCell += CGRectGetHeight(orderTotalLabel.frame);
        }else if([row.identifier isEqualToString:ORDER_DETAIL_SHIPPING_ADDRESS]){
            cell.heightCell = paddingContentY;
            cell.backgroundColor = [UIColor whiteColor];
            SCPLabel *addressLabel = [[SCPLabel alloc] initWithFrame:CGRectMake(paddingContentX, cell.heightCell, tableWidth - 2*paddingContentX, 20)];
            [cell.contentView addSubview:addressLabel];
            NSInteger strLength = [[self.order.shippingAddress formatAddress] length];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            [style setLineSpacing:paddingContentItem];
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[self.order.shippingAddress formatAddress]];
            [attString addAttribute:NSParagraphStyleAttributeName
                              value:style
                              range:NSMakeRange(0, strLength)];
            addressLabel.attributedText = attString;
            [addressLabel wrapContent];
            cell.heightCell += CGRectGetHeight(addressLabel.frame);
        }else if([row.identifier isEqualToString:ORDER_DETAIL_SHIPPING_METHOD]){
            cell.heightCell = paddingContentY;
            SCPLabel *shippingMethodLabel = [[SCPLabel alloc] initWithFrame:CGRectMake(paddingContentX, cell.heightCell, tableWidth - 2*paddingContentX, 20)];
            shippingMethodLabel.text = self.order.shippingMethod;
            [shippingMethodLabel wrapContent];
            cell.heightCell += CGRectGetHeight(shippingMethodLabel.frame) + paddingContentY;
            [cell.contentView addSubview:shippingMethodLabel];
            cell.heightCell += paddingItems;
        }else if([row.identifier isEqualToString:ORDER_DETAIL_PAYMENT_METHOD]){
            cell.heightCell = paddingContentY;
            SCPLabel *paymentMethodLabel = [[SCPLabel alloc] initWithFrame:CGRectMake(paddingContentX, cell.heightCell, tableWidth - 2*paddingContentX, 20)];
            paymentMethodLabel.text = self.order.paymentMethod;
            [cell.contentView addSubview:paymentMethodLabel];
            cell.heightCell += [paymentMethodLabel wrapContent];
            cell.backgroundColor = [UIColor whiteColor];
        }else if([row.identifier isEqualToString:ORDER_DETAIL_BILLING_ADDRESS]){
            cell.heightCell = paddingContentY;
            SCPLabel *addressLabel = [[SCPLabel alloc] initWithFrame:CGRectMake(paddingContentX, cell.heightCell, tableWidth - 2*paddingContentX, 20)];
            [cell.contentView addSubview:addressLabel];
            NSInteger strLength = [[self.order.shippingAddress formatAddress] length];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            [style setLineSpacing:paddingContentItem];
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[self.order.shippingAddress formatAddress]];
            [attString addAttribute:NSParagraphStyleAttributeName
                              value:style
                              range:NSMakeRange(0, strLength)];
            addressLabel.attributedText = attString;
            [addressLabel wrapContent];
            cell.heightCell += CGRectGetHeight(addressLabel.frame);
            cell.backgroundColor = [UIColor whiteColor];
        }else if([row.identifier isEqualToString:ORDER_DETAIL_COUPONCODE]){
            cell.heightCell = paddingContentY;
            SCPLabel *couponLabel = [[SCPLabel alloc] initWithFrame:CGRectMake(paddingContentX, cell.heightCell, tableWidth - 2*paddingContentX, 20)];
            couponLabel.text = [NSString stringWithFormat:@"%@: %@",SCLocalizedString(@"Coupon code"),self.order.couponCode];
            cell.heightCell += [couponLabel wrapContent] + paddingContentY;
            [cell.contentView addSubview:couponLabel];
            cell.heightCell += paddingItems;
        }else if([row.identifier isEqualToString:ORDER_DETAIL_TOTAL]){
            cell = [[SCPOrderFeeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_DETAIL_TOTAL];
            ((SCPOrderFeeCell*)cell).paddingY = 0;
            ((SCPOrderFeeCell*)cell).paddingX = 0;
            ((SCPOrderFeeCell*)cell).paddingContentX = paddingContentX;
            ((SCPOrderFeeCell*)cell).paddingContentY = paddingContentY;
            ((SCPOrderFeeCell*)cell).heightLabel = SCALEVALUE(30);
            NSMutableArray *orderTotal = [GLOBALVAR convertCartPriceData:self.order.total];
            [(SCOrderFeeCell *)cell setData:orderTotal andWidthCell:tableWidth];
        }
    }
    row.height = cell.heightCell;
    return cell;
}
@end
