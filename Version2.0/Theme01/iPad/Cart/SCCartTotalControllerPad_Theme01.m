//
//  SCCartTotalControllerPad_Theme01.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/11/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCCartTotalControllerPad_Theme01.h"
#import "SCCartTotalCellPad_Theme01.h"
#import "SimiViewController+Theme01.h"
#import "SimiGlobalVar+Theme01.h"

@interface SCCartTotalControllerPad_Theme01 ()

@end

@implementation SCCartTotalControllerPad_Theme01

@synthesize cartCells = _cartCells;

@synthesize tableViewCart, cart, isPresentingKeyboard, isCheckoutable, heightRow, cartPrices;

- (void)viewDidLoadBefore
{
    if(self.isDiscontinue){
        self.isDiscontinue = NO;
        return;
    }
    if (tableViewCart == nil) {
        CGRect frame = self.view.frame;
        tableViewCart = [[SimiTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        tableViewCart.dataSource = self;
        tableViewCart.delegate = self;
        tableViewCart.delaysContentTouches = NO;
        tableViewCart.autoresizingMask =  UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    [tableViewCart setScrollEnabled:NO];
    [tableViewCart setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableViewCart setBackgroundView:nil];
    [self.view addSubview:tableViewCart];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    if(self.isDiscontinue){
        self.isDiscontinue = NO;
        return;
    }
}
                                     
- (void)checkout{
    [self.delegate didClickCheckOut];
}

- (void)reloadData
{
    _cartCells = nil;
    [self.tableViewCart reloadData];
}

#pragma mark - Init Cart Cells
- (SimiTable *)cartCells
{
    if (_cartCells) {
        return _cartCells;
    }
    _cartCells = [SimiTable new];
    SimiSection *cartTotals = [_cartCells addSectionWithIdentifier:CART_PRODUCTS];
    if ([self.cart count]) {
        [cartTotals addRowWithIdentifier:CART_TOTALS height:(27 * self.cartPrices.count + 20)];
        [cartTotals addRowWithIdentifier:CART_BUTTON height:100];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitCartCell-After" object:_cartCells];
    return _cartCells;
}

#pragma mark Table View Data Source
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cartCells objectAtIndex:[indexPath section]];
    SimiRow *row = [section objectAtIndex:[indexPath row]];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return (UITableViewCell *)self.simiObjectIdentifier;
    }
    UITableViewCell *aCell;
    if ([row.identifier isEqualToString:CART_TOTALS]) {
        static NSString *OrderFeeCellIdentifier = @"SCCartFeeCellIdentifier";
        SCCartTotalCellPad_Theme01 *cell = [[SCCartTotalCellPad_Theme01 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:OrderFeeCellIdentifier];
        [cell setCellWith:370];
        [cell setData:cartPrices];
        /*
        if([cartPrices valueForKey:@"subtotal"])
            [cell setSubTotal:[NSString stringWithFormat:@"%f",[[cartPrices valueForKey:@"subtotal"] floatValue]]];
        if([cartPrices valueForKey:@"subtotal_excl_tax"])
            [cell setSubTotalExcl:[cartPrices valueForKey:@"subtotal_excl_tax"]];
        if([cartPrices valueForKey:@"subtotal_incl_tax"])
            [cell setSubTotalIncl:[cartPrices valueForKey:@"subtotal_incl_tax"]];
        if([cartPrices valueForKey:@"discount"])
            [cell setDiscount:[cartPrices valueForKey:@"discount"]];
        if([cartPrices valueForKey:@"tax"])
            [cell setTax:[cartPrices valueForKey:@"tax"]];
        if([cartPrices valueForKey:@"shipping_hand"])
            [cell setShipping:[cartPrices valueForKey:@"shipping_hand"]];
        if([cartPrices valueForKey:@"shipping_hand_excl_tax"])
        [cell setShippingExcl:[cartPrices valueForKey:@"shipping_hand_excl_tax"]];
        if([cartPrices valueForKey:@"shipping_hand_incl_tax"])
            [cell setShippingIncl:[cartPrices valueForKey:@"shipping_hand_incl_tax"]];
        if([cartPrices valueForKey:@"grand_total"])
            [cell setTotal:[cartPrices valueForKey:@"grand_total"]];
        if([cartPrices valueForKey:@"grand_total_excl_tax"])
            [cell setTotalExcl:[cartPrices valueForKey:@"grand_total_excl_tax"]];
        if([cartPrices valueForKey:@"grand_total_incl_tax"])
            [cell setTotalIncl:[cartPrices valueForKey:@"grand_total_incl_tax"]];
        [cell setInterfaceCell];
         */
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        aCell = cell;
    }else if ([row.identifier isEqualToString:CART_BUTTON]) {
        static NSString *CheckoutCellIdentifier = @"SCCheckoutCellIdentifier";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CheckoutCellIdentifier];
        if(isCheckoutable){
            CGRect frame = cell.bounds;
            frame.origin.x = 10;
            frame.origin.y = 10;
            frame.size.width = 360;
            frame.size.height = 50;
            UIButton *button = [[UIButton alloc] initWithFrame: frame];
            button.backgroundColor = THEME_COLOR;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:20];
            [button.layer setCornerRadius:5.0f];
            [button.layer setMasksToBounds:YES];
            [button setAdjustsImageWhenHighlighted:YES];
            [button setAdjustsImageWhenDisabled:YES];
            [button setTitle:SCLocalizedString(@"Checkout") forState:UIControlStateNormal];
            [button addTarget:self action:@selector(checkout) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        aCell = cell;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCartCell-After" object:self userInfo:@{@"tableView": tableView, @"indexPath": indexPath, @"section": section, @"row": row,@"cell": aCell}];
    return aCell;
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectCartCellAtIndexPath" object:tableView userInfo:@{@"controller": self, @"indexPath": indexPath, @"cart": self.cart}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
}

- (void) setCartPrices:(NSMutableArray *)cartPrices_
{
    cartPrices = cartPrices_;
}

- (void) setIsCheckoutable:(BOOL)isCheckoutable_
{
    isCheckoutable = isCheckoutable_;
}

- (void) setCart:(SimiCartModelCollection *)cart_
{
    cart = cart_;
}

- (NSMutableArray *) getCartPrices
{
    return cartPrices;
}

- (BOOL) getIsCheckoutable
{
    return isCheckoutable;
}

@end
