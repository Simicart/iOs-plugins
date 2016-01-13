//
//  SCCartDetailControllerPad_Theme01.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/11/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <SimiCartBundle/SimiResponder.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>

#import "SCCartDetailControllerPad_Theme01.h"
#import "SimiViewController+Theme01.h"
#import "SCProductViewController_Theme01.h"

@interface SCCartDetailControllerPad_Theme01 ()

@end

@implementation SCCartDetailControllerPad_Theme01

@synthesize cartCells = _cartCells;

@synthesize tableViewCart, cart, isPresentingKeyboard, cartPrices, isCheckoutable;
#pragma mark Main Method

- (void)viewDidLoadBefore
{
    if(self.isDiscontinue){
        self.isDiscontinue = NO;
        return;
    }
    [self setToSimiView];
    if (qtyTextFieldList == nil) {
        qtyTextFieldList = [[NSMutableDictionary alloc] init];
    }
    if (tableViewCart == nil) {
        CGRect frame = self.view.frame;
        tableViewCart = [[SimiTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        tableViewCart.dataSource = self;
        tableViewCart.delegate = self;
        tableViewCart.delaysContentTouches = NO;
        tableViewCart.autoresizingMask =  UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }

    [tableViewCart setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:tableViewCart];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCart) name:@"DidPlaceOrder-After" object:nil];
    self.cart = [[SimiGlobalVar sharedInstance] cart];
    [tableViewCart deselectRowAtIndexPath:[tableViewCart indexPathForSelectedRow] animated:YES];
    [self getCart];

}

- (void)viewWillAppearBefore:(BOOL)animated{
    if(self.isDiscontinue){
        self.isDiscontinue = NO;
        return;
    }
    [tableViewCart deselectRowAtIndexPath:[tableViewCart indexPathForSelectedRow] animated:YES];
}

#pragma mark Did Receive Noti
- (void)didReceiveNotification:(NSNotification *)noti{
    [self stopLoadingData];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if ([noti.name isEqualToString:@"DidAddToCart"] || [noti.name isEqualToString:@"DidGetCart"] || [noti.name isEqualToString:@"DidEditQty"]){
            if(responder.other){
                self.cartPrices = responder.other;
            }
            if ([self.cart.cartQty integerValue] > 0) {
                self.isCheckoutable = YES;
            }else{
                self.isCheckoutable = NO;
            }
            [self.delegate setCartPrices:self.cartPrices isCheckoutable:self.isCheckoutable cart:self.cart];
            [self reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidChangeCart" object:cart];
        }else if ([noti.name isEqualToString:@"DidFinishLaunchingApp"]){
            [self getCart];
        }
        if ([[responder responseMessage] rangeOfString:@"NOT CHECKOUT"].location != NSNotFound) {
            self.isCheckoutable = NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[responder.responseMessage stringByReplacingOccurrencesOfString:@"NOT CHECKOUT" withString:@""] delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        if (self.cart.count > 0) {
            self.isCheckoutable = YES;
        }else{
            self.isCheckoutable = NO;
        }
    }
    //Remove observer after received response
    [self removeObserverForNotification:noti];
}

#pragma mark Action Keyboard
- (void)keyboardWasShown{
    if (!self.isPresentingKeyboard) {
        self.isPresentingKeyboard = YES;
        UIEdgeInsets contentInsets = tableViewCart.contentInset;
        contentInsets.bottom += 265;
        tableViewCart.contentInset = contentInsets;
        tableViewCart.scrollIndicatorInsets = contentInsets;
    }
}

- (void)hideKeyboard{
    if (self.isPresentingKeyboard) {
        self.isPresentingKeyboard = NO;
        UIEdgeInsets contentInsets = tableViewCart.contentInset;
        contentInsets.bottom -= 265;
        tableViewCart.contentInset = contentInsets;
        tableViewCart.scrollIndicatorInsets = contentInsets;
    }
}

#pragma mark Process Cart
- (void)addProductToCart:(NSNotification*)noti
{
    SimiProductModel *product = [noti.userInfo valueForKey:@"data"];
    NSMutableArray *selectedOptions = [[NSMutableArray alloc] init];
    for (NSDictionary *option in [product valueForKeyPath:@"options"]) {
        if ([[option valueForKeyPath:@"is_selected"] boolValue]) {
            [selectedOptions addObject:option];
        }
    }
    
    SimiProductModel *cartItem = [[SimiProductModel alloc] init];
    [cartItem setValue:[product valueForKeyPath:@"product_id"] forKey:@"product_id"];
    [cartItem setValue:[product valueForKeyPath:@"product_name"] forKey:@"product_name"];
    [cartItem setValue:[product valueForKeyPath:@"product_price"] forKey:@"product_price"];
    [cartItem setValue:[product valueForKeyPath:@"product_image"] forKey:@"product_image"];
    [cartItem setValue:[product valueForKeyPath:@"product_qty"] forKey:@"product_qty"];
    [cartItem setValue:selectedOptions forKey:@"options"];
    
    if (self.cart == nil) {
        self.cart = [[SimiCartModelCollection alloc] init];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidAddToCart" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidAddToCart" object:nil];
    [self.cart addToCartWithProduct:cartItem];
}

- (void)getCart{
    if (self.cart == nil) {
        self.cart = [[SimiGlobalVar sharedInstance] cart];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetCart" object:cart];
    [self startLoadingData];
    [self.cart getCartItemsWithParams:@{@"width": @"500", @"height":@"500"}];
}

- (void) setCart:(SimiCartModelCollection *)cart_
{
    cart = cart_;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitCartCell-Before" object:_cartCells];
    
    SimiSection *cartTable = [_cartCells addSectionWithIdentifier:CART_PRODUCTS];
    if ([self.cart count]) {
        for (NSInteger i = [self.cart count]; i > 0; i--) {
            [cartTable addRowWithIdentifier:CART_PRODUCTS height:280];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitCartCell-After" object:_cartCells];
    return _cartCells;
}

#pragma mark Cart View Delegates
- (void)clearAllProductsInCart{
    NSMutableArray *qtyDictArr = [[NSMutableArray alloc] init];
    for (SimiCartModel *obj in self.cart) {
        //Set Qty Data for Request
        NSString *cartItemID = [obj valueForKey:@"cart_item_id"];
        NSDictionary *temp = [[NSDictionary alloc] initWithObjectsAndKeys:cartItemID, @"cart_item_id", @"0", @"product_qty", nil];
        [qtyDictArr addObject:temp];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidEditQty" object:self.cart];
    [self startLoadingData];
    [self.cart editQtyInCartWithData:qtyDictArr];
}

#pragma mark Table View Data Source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    SimiSection *simiSection = [_cartCells objectAtIndex:section];
    if ([simiSection.identifier isEqualToString:CART_PRODUCTS]) {
        return 70;
    }else
        return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    SimiSection *simiSection = [_cartCells objectAtIndex:section];
    if ([simiSection.identifier isEqualToString:CART_PRODUCTS]) {
        UIView *headerCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        headerCell.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        CGRect frame = headerCell.frame;
        headerCell.backgroundColor = [UIColor whiteColor];
        UILabel *bottomBorder = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, 6.0)];
        bottomBorder.text = @"";
        [headerCell addSubview:bottomBorder];
        
        if (self.cart.count == 0) {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 30, 0, self.view.frame.size.width - 30, 40)];
            titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
            titleLabel.backgroundColor = [UIColor whiteColor];
            titleLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE];
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.text = SCLocalizedString(@"Your shopping cart is empty");
            [headerCell addSubview:titleLabel];
        }else{
            //Clear Cart
            UIImage *imgUpdate = [[UIImage imageNamed:@"theme01_cart_update"] imageWithColor:THEME_COLOR];
            UIImageView *updateImage = [[UIImageView alloc]initWithFrame:CGRectMake(30, 35, 17, 17)];
            updateImage.image = imgUpdate;
            [headerCell addSubview:updateImage];
            UILabel *updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(51, 30, 120, 25)];
            updateLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:20];
            updateLabel.backgroundColor = [UIColor clearColor];
            updateLabel.text = SCLocalizedString(@"Update");
            updateLabel.textColor = THEME_COLOR;
            [headerCell addSubview:updateLabel];
            UIButton *updateButton = [[UIButton alloc]initWithFrame:CGRectMake(30, 30, 150, 30)];
            [updateButton addTarget:self action:@selector(getCart) forControlEvents:UIControlEventTouchUpInside];
            [headerCell addSubview:updateButton];
        }
        return headerCell;
    }else
        return nil;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cartCells objectAtIndex:[indexPath section]];
    SimiRow *row = [section objectAtIndex:[indexPath row]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCartCell-Before" object:self userInfo:@{@"tableView": tableView, @"indexPath": indexPath, @"section": section, @"row": row}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return (UITableViewCell *)self.simiObjectIdentifier;
    }
    UITableViewCell *aCell;
    if ([row.identifier isEqualToString:CART_PRODUCTS]) {
        SimiCartModel *item = [cart objectAtIndex:indexPath.row];
        NSString *cartItemID = [item valueForKey:@"cart_item_id"];
        NSString *SCCartCellIdentifier = [NSString stringWithFormat:@"%@_%@", @"SCCartCellIdentifier", cartItemID];
        SCCartCellPad_Theme01 *cell = [tableView dequeueReusableCellWithIdentifier:SCCartCellIdentifier];
        if (cell == nil) {
            cell = [[SCCartCellPad_Theme01 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SCCartCellIdentifier];
            if ([item valueForKeyPath:@"cart_item_name"] == nil) {
                NSString *cartItemName = [item valueForKeyPath:@"product_name"];
                for (NSDictionary *option in [item valueForKeyPath:@"options"]) {
                    cartItemName = [NSString stringWithFormat:@"%@, %@", cartItemName, [option valueForKeyPath:@"option_value"]];
                }
                [item setValue:cartItemName forKeyPath:@"cart_item_name"];
            }
            [cell setCellWith:620];
            [cell setItem:item];
            [cell setName:[item valueForKeyPath:@"product_name"]];
            [cell setQty:[NSString stringWithFormat:@"%@", [item valueForKey:@"product_qty"]]];
            [cell setPrice:[item valueForKey:@"product_price"]];
            [cell setCartItemId:cartItemID];
            cell.delegate = self;
            [cell setImagePath:[item valueForKey:@"product_image"]];
            [cell setTextFieldTag:indexPath.row];
            [cell setStockStatus:1];
            cell.qtyTextField.delegate = self;
            [cell setInterfaceCell];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (qtyTextFieldList == nil) {
                qtyTextFieldList = [[NSMutableDictionary alloc] init];
            }
            [qtyTextFieldList setValue:cell.qtyTextField forKey:cartItemID];
        }
        [cell setQty:[NSString stringWithFormat:@"%@", [item valueForKey:@"product_qty"]]];
        [cell setPrice:[item valueForKey:@"product_price"]];
        aCell = cell;
    }
    return aCell;
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectCartCellAtIndexPath" object:tableView userInfo:@{@"controller": self, @"indexPath": indexPath, @"cart": self.cart}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    NSInteger row = [indexPath row];
    if (!self.isPresentingKeyboard && self.isCheckoutable && row < [self.cart count]) {
        NSString *productID = [[self.cart objectAtIndex:row] valueForKey:@"product_id"];
        SCProductViewController_Theme01 *nextController = [[SCProductViewController_Theme01 alloc]init];
        [nextController setProductId:productID];
        [self.navigationController pushViewController:nextController animated:YES];
    }else{
        [self cancelEditingQty];
    }

}

#pragma mark CartCell Delegate
- (void)showProductDetail:(NSString *)productID
{
    [self.delegate showProductDetail:productID];
}

//  Liam ADD 20150420
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self doneEditingQty];
}
//  End

@end
