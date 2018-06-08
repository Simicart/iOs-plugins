//
//  SCPCartViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 6/4/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPCartViewController.h"

@interface SCPCartViewController ()

@end

@implementation SCPCartViewController

- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    self.contentTableView.contentInset = UIEdgeInsetsMake(0, 0, SCALEVALUE(45), 0);
    self.contentTableView.backgroundColor = COLOR_WITH_HEX(@"#f2f2f2");
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:NO];
}
- (void)viewDidAppearBefore:(BOOL)animated{
    if (self.btnCheckout == nil) {
        float btnCheckoutHeight = SCALEVALUE(45);
        CGRect frame = self.view.bounds;
        frame.size.height -= btnCheckoutHeight;
        self.btnCheckout = [[SCPButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - btnCheckoutHeight, SCREEN_WIDTH, btnCheckoutHeight) title:@"CHECK OUT" titleFont:[UIFont fontWithName:SCP_FONT_SEMIBOLD size:FONT_SIZE_HEADER] cornerRadius:0 borderWidth:0 borderColor:[UIColor clearColor] shadowOffset:CGSizeZero shadowRadius:0 shadowOpacity:0];
        self.btnCheckout.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.btnCheckout addTarget:self action:@selector(checkout) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.btnCheckout];
        if (self.cart.canCheckOut) {
            [self.btnCheckout setHidden:NO];
        }else{
            [self.btnCheckout setHidden:YES];
        }
    }
    if (GLOBALVAR.isGettingCart) {
        [self startLoadingData];
    }else{
        [self initCells];
    }
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
        SimiSection *sectionPrice = [self.cells addSectionWithIdentifier:CART_TOTALS];
        SimiRow *cartTotalsRow = [[SimiRow alloc]initWithIdentifier:CART_TOTALS_ROW];
        [sectionPrice addRow:cartTotalsRow];
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
- (UITableViewCell *)createTotalCellForRow:(SimiRow *)row{
    SCPOrderFeeCell *cell = [[SCPOrderFeeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
    if (self.cart.count <= 0) {
        return cell;
    }
    [cell setData:cartPrices andWidthCell:self.contentTableView.frame.size.width];
    cell.userInteractionEnabled = NO;
    row.height = cell.heightCell;
    return cell;
}

@end
