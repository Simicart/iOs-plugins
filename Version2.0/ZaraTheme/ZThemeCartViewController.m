//
//  ZThemeCartViewController.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 5/13/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeCartViewController.h"

#import <SimiCartBundle/SimiProductModel.h>
#import <SimiCartBundle/SimiResponder.h>
#import <SimiCartBundle/SCOrderFeeCell.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>

#import "SimiViewController+ZTheme.h"
#import "ZThemeOrderViewController.h"
#import "ZThemeProductViewController.h"
#import "ZThemeWorker.h"

@class ZThemeCartViewController;

@implementation ZThemeCartViewController


@synthesize cartCells = _cartCells;

@synthesize tableViewCart, cart, isPresentingKeyboard, isCheckoutable, heightRow, cartPrices,isReloadNullPrice;

+ (instancetype)sharedInstance{
    static ZThemeCartViewController *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ZThemeCartViewController alloc] init];
    });
    return _sharedInstance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoadBefore
{
    self.navigationItem.title = [SCLocalizedString(@"Shopping Cart") uppercaseString];
    [super viewDidLoadBefore];
    [self setNavigationBarOnViewDidLoadForZTheme];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    [self setNavigationBarOnViewWillAppearForZTheme:YES isShowRightItems:NO];
}

- (void)setNavigationBar{
    // Overwrite lop cha
}

#pragma mark Check out & Update cart

- (void)checkout{
    if ([[SimiGlobalVar sharedInstance]isLogin]) {
        SCAddressViewController *nextController = [[SCAddressViewController alloc]init];
        nextController.isSelectAddressFromCartForCheckOut = YES;
        [nextController setDelegate:self];
        [nextController setIsGetOrderAddress:YES];
        [self.navigationController pushViewController:nextController animated:NO];
        return;
    }else
    {
        [self askCustomerRole];
    }
}

- (void)clearCart{
    [qtyTextFieldList removeAllObjects];
    [self.cart removeAllObjects];
    [self reloadData];
    self.isCheckoutable = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidPlaceOrder-After" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidChangeCart" object:self.cart];
}

- (void)reloadData
{
    _cartCells = nil;
    [self.tableViewCart reloadData];
}
#pragma  mark Notification Action
- (void)didReceiveNotification:(NSNotification *)noti{
    [self stopLoadingData];
    if ([noti.name isEqualToString:@"AddToCart"]) {
        SimiProductModel *product = [noti.userInfo valueForKey:@"data"];
        NSMutableArray *selectedOptions = [[NSMutableArray alloc] init];
        NSMutableDictionary *optionDict = [noti.userInfo valueForKey:@"optionDict"];
        NSMutableArray *allKeys = [noti.userInfo valueForKey:@"allKeys"];
        for (int i = 0; i < allKeys.count; i++) {
            NSMutableArray *optionsForKey = [optionDict valueForKey:[allKeys objectAtIndex:i]];
            for (NSDictionary *option in optionsForKey) {
                if ([[option valueForKeyPath:@"is_selected"] boolValue]) {
                    [selectedOptions addObject:option];
                }
            }
        }
        
        SimiProductModel *cartItem = [[SimiProductModel alloc] init];
        [cartItem setValue:[product valueForKeyPath:@"product_id"] forKey:@"product_id"];
        [cartItem setValue:[product valueForKeyPath:@"product_name"] forKey:@"product_name"];
        [cartItem setValue:[product valueForKeyPath:@"product_price"] forKey:@"product_price"];
        [cartItem setValue:[product valueForKeyPath:@"product_image"] forKey:@"product_image"];
        [cartItem setValue:[product valueForKeyPath:@"product_qty"] forKey:@"product_qty"];
        [cartItem setValue:selectedOptions forKey:@"options"];
        
        if (cart == nil) {
            cart = [[SimiCartModelCollection alloc] init];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidAddToCart" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidAddToCart" object:nil];
        [cart addToCartWithProduct:cartItem];
    }else{
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            if ([noti.name isEqualToString:@"DidAddToCart"] || [noti.name isEqualToString:@"DidGetCart"] || [noti.name isEqualToString:@"DidEditQty"]){
                if(responder.other){
                    cartPrices = responder.other;
                }
                if ([cart.cartQty integerValue] > 0) {
                    isCheckoutable = YES;
                }else{
                    isCheckoutable = NO;
                }
                self.navigationItem.rightBarButtonItem = nil;
                self.navigationItem.leftBarButtonItem = nil;
                [self setNavigationBarOnViewWillAppearForZTheme:YES isShowRightItems:NO];
                
                [self reloadData];
                [self hideKeyboard];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DidChangeCart" object:cart];
                if(!isReloadNullPrice && cart.count > 0)
                {
                    isReloadNullPrice = true;
                    [self removeObserverForNotification:noti];
                    [self getCart];
                    return;
                }
            }else if ([noti.name isEqualToString:@"DidFinishLaunchingApp"]){
                [self getCart];
            }
            if ([[responder responseMessage] rangeOfString:@"NOT CHECKOUT"].location != NSNotFound) {
                isCheckoutable = NO;
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[responder.responseMessage stringByReplacingOccurrencesOfString:@"NOT CHECKOUT" withString:@""] delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
                [alertView show];
            }
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
            if (cart.count > 0) {
                isCheckoutable = YES;
            }else{
                isCheckoutable = NO;
            }
        }
        //Remove observer after received response
        [self removeObserverForNotification:noti];
    }
}

- (void)doneEditingQty
{
    [super doneEditingQty];
    self.navigationItem.rightBarButtonItem = nil;
    [self setNavigationBarOnViewWillAppearForZTheme:YES isShowRightItems:NO];
}

- (void)cancelEditingQty{
    [super cancelEditingQty];
    self.navigationItem.rightBarButtonItem = nil;
    [self setNavigationBarOnViewWillAppearForZTheme:YES isShowRightItems:NO];
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
            [cartTable addRowWithIdentifier:CART_PRODUCTS height:145];
        }
        [cartTable addRowWithIdentifier:CART_TOTALS height:(27 * self.cartPrices.count + 20)];
        [cartTable addRowWithIdentifier:CART_BUTTON height:100];
    } else {
        [cartTable addRowWithIdentifier:CART_EMPTY height:145];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitCartCell-After" object:_cartCells];
    return _cartCells;
}

#pragma mark Table View Data Source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    SimiSection *simiSection = [_cartCells objectAtIndex:section];
    if ([simiSection.identifier isEqualToString:CART_PRODUCTS]) {
        return 80;
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
        
        if (self.cart.count > 0) {
            //Clear Cart
            UIImage *imgClear = [[UIImage imageNamed:@"Ztheme_cart_clear"] imageWithColor:THEME_COLOR];
            UIImageView *clearImage = [[UIImageView alloc]initWithFrame:CGRectMake(20, 34, 15, 15)];
            clearImage.image = imgClear;
            [headerCell addSubview:clearImage];
            UILabel *clearLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 30, 90, 20)];
            clearLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", ZTHEME_FONT_NAME_REGULAR] size:18];
            clearLabel.backgroundColor = [UIColor clearColor];
            clearLabel.text = SCLocalizedString(@"Clear All");
            clearLabel.textColor = THEME_COLOR;
            [headerCell addSubview:clearLabel];
            UIButton *clearButton = [[UIButton alloc]initWithFrame:CGRectMake(20, 30, 110, 30)];
            [clearButton addTarget:self action:@selector(clearAllProductsInCart) forControlEvents:UIControlEventTouchUpInside];
            [headerCell addSubview:clearButton];
            
            UIImage *imgUpdate = [[UIImage imageNamed:@"Ztheme_cart_update"]imageWithColor:THEME_COLOR];
            UIImageView *updateImage = [[UIImageView alloc]initWithFrame:CGRectMake(230, 34, 15, 15)];
            updateImage.image = imgUpdate;
            [headerCell addSubview:updateImage];
            UILabel *updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 30, 90, 20)];
            updateLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", ZTHEME_FONT_NAME_REGULAR] size:18];
            updateLabel.backgroundColor = [UIColor clearColor];
            updateLabel.text = SCLocalizedString(@"Refresh");
            updateLabel.textColor = THEME_COLOR;
            
            UIButton *updateButton = [[UIButton alloc]initWithFrame:CGRectMake(230, 30, 110, 30)];
            [updateButton addTarget:self action:@selector(getCart) forControlEvents:UIControlEventTouchUpInside];
            [headerCell addSubview:updateButton];
            [headerCell addSubview:updateLabel];
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
        SimiCartModel *item = [self.cart objectAtIndex:indexPath.row];
        NSString *SCCartCellIdentifier = [NSString stringWithFormat:@"%@_%@", @"SCCartCellIdentifier", [item valueForKey:@"cart_item_id"]];
        ZThemeCartCell *cell = [tableView dequeueReusableCellWithIdentifier:SCCartCellIdentifier];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCartCell-Before" object:cell];
        if (self.isDiscontinue) {
            self.isDiscontinue = NO;
            return cell;
        }
        if (cell == nil) {
            cell = [[ZThemeCartCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SCCartCellIdentifier];
            if ([item valueForKeyPath:@"cart_item_name"] == nil) {
                NSString *cartItemName = [item valueForKeyPath:@"product_name"];
                for (NSDictionary *option in [item valueForKeyPath:@"options"]) {
                    cartItemName = [NSString stringWithFormat:@"%@, %@", cartItemName, [option valueForKeyPath:@"option_value"]];
                }
                [item setValue:cartItemName forKeyPath:@"cart_item_name"];
            }
            [cell setItem:item];
            [cell setName:[item valueForKeyPath:@"product_name"]];
            [cell setPrice:[item valueForKey:@"product_price"]];
            NSString *cartItemID = [item valueForKey:@"cart_item_id"];
            [cell setQty:[NSString stringWithFormat:@"%@", [item valueForKey:@"product_qty"]]];
            [cell setCartItemId:cartItemID];
            [cell setImagePath:[item valueForKey:@"product_image"]];
            [cell setTextFieldTag:indexPath.row];
            [cell setStockStatus:1];
            cell.qtyTextField.delegate = self;
            cell.delegate = self;
            [cell setInterfaceCell];
            if (qtyTextFieldList == nil) {
                qtyTextFieldList = [[NSMutableDictionary alloc] init];
            }
            [qtyTextFieldList setValue:cell.qtyTextField forKey:cartItemID];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        //Set cell data
        [cell setPrice:[item valueForKey:@"product_price"]];
        [cell setQty:[NSString stringWithFormat:@"%@", [item valueForKey:@"product_qty"]]];
        aCell = cell;
    }else if ([row.identifier isEqualToString:CART_TOTALS]) {
        static NSString *OrderFeeCellIdentifier = @"SCOrderFeeCellIdentifier";
        SCOrderFeeCell *cell = [[SCOrderFeeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:OrderFeeCellIdentifier];
        cell.isUsePhoneSizeOnPad = YES;
        if (self.cart.count <= 0) {
            return cell;
        }
        [cell setData:cartPrices];
        /*
        if([self.cartPrices valueForKey:@"subtotal"])
            [cell setSubTotal:[NSString stringWithFormat:@"%f",[[self.cartPrices valueForKey:@"subtotal"] floatValue]]];
        if([self.cartPrices valueForKey:@"subtotal_excl_tax"])
            [cell setSubTotalExcl:[self.cartPrices valueForKey:@"subtotal_excl_tax"]];
        if([self.cartPrices valueForKey:@"subtotal_incl_tax"])
            [cell setSubTotalIncl:[self.cartPrices valueForKey:@"subtotal_incl_tax"]];
        if([self.cartPrices valueForKey:@"discount"])
            [cell setDiscount:[self.cartPrices valueForKey:@"discount"]];
        if([self.cartPrices valueForKey:@"tax"])
            [cell setTax:[self.cartPrices valueForKey:@"tax"]];
        if([self.cartPrices valueForKey:@"shipping_hand"])
            [cell setShipping:[self.cartPrices valueForKey:@"shipping_hand"]];
        if([self.cartPrices valueForKey:@"shipping_hand_excl_tax"])
            [cell setShippingExcl:[self.cartPrices valueForKey:@"shipping_hand_excl_tax"]];
        if([self.cartPrices valueForKey:@"shipping_hand_incl_tax"])
            [cell setShippingIncl:[self.cartPrices valueForKey:@"shipping_hand_incl_tax"]];
        if([self.cartPrices valueForKey:@"grand_total"])
            [cell setTotal:[self.cartPrices valueForKey:@"grand_total"]];
        if([self.cartPrices valueForKey:@"grand_total_excl_tax"])
            [cell setTotalExcl:[self.cartPrices valueForKey:@"grand_total_excl_tax"]];
        if([self.cartPrices valueForKey:@"grand_total_incl_tax"])
            [cell setTotalIncl:[self.cartPrices valueForKey:@"grand_total_incl_tax"]];
        [cell setInterfaceCell];
        */ 
        cell.userInteractionEnabled = NO;
        aCell = cell;
    }else if ([row.identifier isEqualToString:CART_BUTTON]) {
        static NSString *CheckoutCellIdentifier = @"SCCheckoutCellIdentifier";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CheckoutCellIdentifier];
        CGRect frame = cell.frame;
        frame.origin.x = 10;
        frame.origin.y = 10;
        frame.size.width = cell.frame.size.width - 20;
        frame.size.height = 40;
        UIButton *button = [[UIButton alloc] initWithFrame: frame];
        button.backgroundColor = THEME_COLOR;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:18];
        [button.layer setCornerRadius:5.0f];
        [button.layer setMasksToBounds:YES];
        [button setAdjustsImageWhenHighlighted:YES];
        [button setAdjustsImageWhenDisabled:YES];
        if(self.isCheckoutable){
            [button setTitle:SCLocalizedString(@"Checkout") forState:UIControlStateNormal];
            [cell addSubview:button];
        }
        [button addTarget:self action:@selector(checkout) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        aCell = cell;
    }else if ([row.identifier isEqualToString:CART_EMPTY]) {
        static NSString *EmptyCartCellIdentifier = @"SCEmptyCartCellIdentifier";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EmptyCartCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *emptyLabel = [[UILabel alloc]init];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [emptyLabel setFrame:CGRectMake(50, 50, cell.bounds.size.width-100, cell.frame.size.height)];
        }else
        {
            [emptyLabel setFrame:CGRectMake(40, 50, 600, cell.frame.size.height)];
        }
        emptyLabel.text = SCLocalizedString(@"You have no items in your shopping cart.");
        emptyLabel.textColor = [UIColor blackColor];
        emptyLabel.backgroundColor = [UIColor whiteColor];
        emptyLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", ZTHEME_FONT_NAME_REGULAR] size:THEME_FONT_SIZE];
        [emptyLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [emptyLabel setTextAlignment:NSTextAlignmentCenter];
        [emptyLabel setNumberOfLines:2];
        [cell addSubview:emptyLabel];
        aCell = cell;
    }
    self.simiObjectIdentifier = aCell;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCartCell-After" object:self userInfo:@{@"tableView": tableView, @"indexPath": indexPath, @"section": section, @"row": row, @"cell": aCell}];
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
        ZThemeProductViewController *nextController = [[ZThemeProductViewController alloc]init];
        [nextController setProductId:productID];
        [self.navigationController pushViewController:nextController animated:YES];
    }else{
        [self cancelEditingQty];
    }
}

#pragma mark Address Delegate
- (void)selectAddress:(SimiAddressModel *)address
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCart) name:@"DidPlaceOrder-After" object:nil];
    self.billingAddress = address;
    ZThemeOrderViewController *orderController = [[ZThemeOrderViewController alloc] init];
    [orderController setCart:self.cart];
    [orderController setCartPrices:[self.cartPrices mutableCopy]];
    [orderController setBillingAddress:self.billingAddress];
    [orderController setShippingAddress:self.billingAddress];
    [self.navigationController pushViewController:orderController animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //  Liam UPDATE 150421
    SimiStoreModel *store = [[SimiGlobalVar sharedInstance] store];
    BOOL isEnableGuestCheckout = [[[store valueForKey:@"checkout_config"] valueForKey:@"enable_guest_checkout"] boolValue];
    if (isEnableGuestCheckout) {
        switch (buttonIndex) {
            case 0: //Checkout as existing customer
            {
                self.isNewCustomer = NO;
                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didLogin:)name:@"PushLoginInCheckout" object:nil];
                SCLoginViewController *nextController = [[SCLoginViewController alloc] init];
                nextController.isLoginInCheckout = YES;
                UINavigationController *navigationController = [[UINavigationController alloc]
                                                                initWithRootViewController:nextController];
                [self presentViewController:navigationController animated:YES completion: nil];
            }
                break;
            case 1: //Checkout as new customer
            {
                self.isNewCustomer = YES;
                SCNewAddressViewController *nextController = [[SCNewAddressViewController alloc]init];
                nextController.isNewCustomer = YES;
                nextController.delegate = self;
                [self.navigationController pushViewController:nextController animated:YES];
            }
                break;
            case 2: //Checkout as guest
            {
                self.isNewCustomer = NO;
                SCNewAddressViewController *nextController = [[SCNewAddressViewController alloc]init];
                nextController.delegate = self;
                [self.navigationController pushViewController:nextController animated:YES];
            }
                
                break;
            default: //Cancel
                
                break;
        }
    }else
    {
        switch (buttonIndex) {
            case 0: //Checkout as existing customer
            {
                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didLogin:)name:@"PushLoginInCheckout" object:nil];
                self.isNewCustomer = NO;
                SCLoginViewController *nextController = [[SCLoginViewController alloc] init];
                nextController.isLoginInCheckout = YES;
                
                UINavigationController *navigationController = [[UINavigationController alloc]
                                                                initWithRootViewController:nextController];
                [self presentViewController:navigationController animated:YES completion: nil];
            }
                break;
            case 1: //Checkout as new customer
            {
                self.isNewCustomer = YES;
                SCNewAddressViewController *nextController = [[SCNewAddressViewController alloc]init];
                nextController.isNewCustomer = YES;
                nextController.delegate = self;
                [self.navigationController pushViewController:nextController animated:YES];
            }
                break;
            default: //Cancel
                
                break;
        }
    }
}

- (void)didSaveAddress:(SimiAddressModel *)address
{
    self.billingAddress = address;
    ZThemeOrderViewController *orderController = [[ZThemeOrderViewController alloc] init];
    [orderController setCart:self.cart];
    [orderController setCartPrices:[self.cartPrices mutableCopy]];
    [orderController setBillingAddress:self.billingAddress];
    [orderController setShippingAddress:self.billingAddress];
    if (self.isNewCustomer) {
        orderController.addressNewCustomerModel = address;
        orderController.isNewCustomer = self.isNewCustomer;
    }
    [self.navigationController pushViewController:orderController animated:YES];
}

- (void)didLogin:(NSNotification*)noti
{
    [[NSNotificationCenter defaultCenter]removeObserverForNotification:noti];
    SCAddressViewController *nextController = [[SCAddressViewController alloc]init];
    nextController.isSelectAddressFromCartForCheckOut = YES;
    [nextController setDelegate:self];
    [nextController setIsGetOrderAddress:YES];
    [self.navigationController pushViewController:nextController animated:YES];
}
@end