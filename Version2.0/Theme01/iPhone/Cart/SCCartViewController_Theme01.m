//
//  SCCartViewController_Theme01.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/11/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <SimiCartBundle/SimiProductModel.h>
#import <SimiCartBundle/SimiResponder.h>
#import <SimiCartBundle/SCOrderFeeCell.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>

#import "SCCartViewController_Theme01.h"
#import "SimiViewController+Theme01.h"
#import "SCOrderViewController_Theme01.h"
#import "SCProductViewController_Theme01.h"

@class SCCartViewController_Theme01;

@implementation SCCartViewController_Theme01

@synthesize cartCells = _cartCells;

@synthesize tableViewCart, cart, isPresentingKeyboard, isCheckoutable, heightRow, cartPrices,isReloadNullPrice;

+ (instancetype)sharedInstance{
    static SCCartViewController_Theme01 *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SCCartViewController_Theme01 alloc] init];
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
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    [self setNavigationBarOnViewWillAppearForTheme01];
    self.navigationItem.rightBarButtonItems = nil;
}

- (void)setNavigationBar{
   
}

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

- (void)didReceiveNotification:(NSNotification *)noti{
    [self stopLoadingData];
    if ([noti.name isEqualToString:@"AddToCart"]) {
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
                [self reloadData];
                [self hideKeyboard];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DidChangeCart" object:cart];
                //  Liam Remove 150707
                /*
                if(!isReloadNullPrice && cart.count > 0)
                {
                    isReloadNullPrice = true;
                    [self removeObserverForNotification:noti];
                    [self getCart];
                    return;
                }
                 */
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
}

- (void)cancelEditingQty{
    [super cancelEditingQty];
    self.navigationItem.rightBarButtonItem = nil;
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
            UIImage *imgClear = [[UIImage imageNamed:@"theme01_cart_clear"] imageWithColor:THEME_COLOR];
            UIImageView *clearImage = [[UIImageView alloc]initWithFrame:CGRectMake(20, 34, 15, 15)];
            clearImage.image = imgClear;
            [headerCell addSubview:clearImage];
            UILabel *clearLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 30, 90, 20)];
            clearLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:18];
            clearLabel.backgroundColor = [UIColor clearColor];
            clearLabel.text = SCLocalizedString(@"Clear All");
            clearLabel.textColor = THEME_COLOR;
            [headerCell addSubview:clearLabel];
            UIButton *clearButton = [[UIButton alloc]initWithFrame:CGRectMake(20, 30, 110, 30)];
            [clearButton addTarget:self action:@selector(clearAllProductsInCart) forControlEvents:UIControlEventTouchUpInside];
            [headerCell addSubview:clearButton];
            
            UIImage *imgUpdate = [[UIImage imageNamed:@"theme01_cart_update"]imageWithColor:THEME_COLOR];
            UIImageView *updateImage = [[UIImageView alloc]initWithFrame:CGRectMake(230, 34, 15, 15)];
            updateImage.image = imgUpdate;
            [headerCell addSubview:updateImage];
            UILabel *updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 30, 90, 20)];
            updateLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:18];
            updateLabel.backgroundColor = [UIColor clearColor];
            updateLabel.text = SCLocalizedString(@"Update");
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
        NSString *rowIdentifier = [NSString stringWithFormat:@"%@_%@", row.identifier, [[self.cart objectAtIndex:indexPath.row] valueForKey:@"cart_item_id"]];
        SCCartCell_Theme01 *cell = [tableView dequeueReusableCellWithIdentifier:rowIdentifier];
        SimiCartModel *item = [self.cart objectAtIndex:indexPath.row];
        if (cell == nil) {
            cell = [[SCCartCell_Theme01 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:rowIdentifier];
            //Set cell data
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
            cell.delegate = self;
            [cell setImagePath:[item valueForKey:@"product_image"]];
            [cell setTextFieldTag:indexPath.row];
            [cell setStockStatus:1];
            cell.qtyTextField.delegate = self;
            [cell setInterfaceCell];
            if (qtyTextFieldList == nil) {
                qtyTextFieldList = [[NSMutableDictionary alloc] init];
            }
            [qtyTextFieldList setValue:cell.qtyTextField forKey:cartItemID];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell setQty:[NSString stringWithFormat:@"%@", [item valueForKey:@"product_qty"]]];
        [cell setPrice:[item valueForKey:@"product_price"]];
        aCell = cell;
    }else if ([row.identifier isEqualToString:CART_TOTALS]) {
        static NSString *OrderFeeCellIdentifier = @"SCOrderFeeCellIdentifier";
        SCOrderFeeCell *cell = [[SCOrderFeeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:OrderFeeCellIdentifier];
        if (self.cart.count <= 0) {
            return cell;
        }
        [cell setData:self.cartPrices];
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
        button.titleLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:18];
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
        emptyLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE];
        [emptyLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [emptyLabel setTextAlignment:NSTextAlignmentCenter];
        [emptyLabel setNumberOfLines:2];
        [cell addSubview:emptyLabel];
        aCell = cell;
    }
    self.simiObjectIdentifier = aCell;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCartCell-After" object:self userInfo:@{@"tableView": tableView, @"indexPath": indexPath, @"section": section, @"row": row, @"cell": aCell}];
    return (UITableViewCell *)self.simiObjectIdentifier;
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

#pragma mark Address Delegate
- (void)selectAddress:(SimiAddressModel *)address
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCart) name:@"DidPlaceOrder-After" object:nil];
    self.billingAddress = address;
    SCOrderViewController_Theme01 *orderController = [[SCOrderViewController_Theme01 alloc] init];
    [orderController setCart:self.cart];
    [orderController setCartPrices:[self.cartPrices mutableCopy]];
    [orderController setBillingAddress:self.billingAddress];
    [orderController setShippingAddress:self.billingAddress];
    [self.navigationController pushViewController:orderController animated:NO];
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
                    SCLoginViewController_Theme01 *nextController = [[SCLoginViewController_Theme01 alloc] init];
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
                SCLoginViewController_Theme01 *nextController = [[SCLoginViewController_Theme01 alloc] init];
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
    SCOrderViewController_Theme01 *orderController = [[SCOrderViewController_Theme01 alloc] init];
    [orderController setCart:self.cart];
    [orderController setCartPrices:[self.cartPrices mutableCopy]];
    [orderController setBillingAddress:self.billingAddress];
    [orderController setShippingAddress:self.billingAddress];
    if (self.isNewCustomer) {
        orderController.addressNewCustomerModel = address;
        orderController.isNewCustomer = self.isNewCustomer;
    }
    [self.navigationController pushViewController:orderController animated:NO];
}

- (void)didLogin:(NSNotification*)noti
{
    [[NSNotificationCenter defaultCenter]removeObserverForNotification:noti];
    SCAddressViewController *nextController = [[SCAddressViewController alloc]init];
    nextController.isSelectAddressFromCartForCheckOut = YES;
    [nextController setDelegate:self];
    [nextController setIsGetOrderAddress:YES];
    [self.navigationController pushViewController:nextController animated:NO];
}

@end
