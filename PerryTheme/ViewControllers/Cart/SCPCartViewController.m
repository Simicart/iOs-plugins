//
//  SCPCartViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 6/4/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPCartViewController.h"
#import "SCPCartCell.h"

@interface SCPCartViewController ()

@end

@implementation SCPCartViewController

- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    self.contentTableView.backgroundColor = COLOR_WITH_HEX(@"#f2f2f2");
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
- (void)createCells{
    cartPrices = [GLOBALVAR convertCartPriceData:self.cart.cartTotal];
    if ([self.cart count]) {
        SimiSection *products = [self.cells addSectionWithIdentifier:CART_PRODUCTS];
        for (NSInteger i = 0; i < [self.cart count]; i++) {
            SimiQuoteItemModel *item = [self.cart objectAtIndex:i];
            SimiRow *row = [[SimiRow alloc]initWithIdentifier:[NSString stringWithFormat:@"%@_%@",CART_PRODUCTS, item.itemId] height:SCALEVALUE(100)];
            row.model = item;
            [products addObject:row];
        }
    } else {
        SimiSection *sectionEmpty = [self.cells addSectionWithIdentifier:CART_EMPTY];
        [sectionEmpty addRowWithIdentifier:CART_EMPTY height:125];
    }
}
- (void)changeCartData:(NSNotification *)noti{
    [super changeCartData:noti];
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)configureLogo{
    self.title = SCLocalizedString(@"My Cart");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UITableViewCell *)createProductCellForRow:(SimiRow *)row atIndexPath:(NSIndexPath *)indexPath{
    SCPCartCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    SimiQuoteItemModel *item = (SimiQuoteItemModel*)row.model;
    if (cell == nil || item.product.isSalable != cell.item.product.isSalable) {
        cell = [[SCPCartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier quoteItemModel:item];
        cell.delegate = self;
    }else
        [cell updateCellWithQuoteItem:item];
    if (cell.heightCell > row.height) {
        row.height = cell.heightCell;
    }
    return cell;
}

@end
