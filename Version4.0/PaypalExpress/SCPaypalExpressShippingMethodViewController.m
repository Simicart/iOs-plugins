//
//  SCPaypalExpressShippingMethodViewController.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/22/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SCPaypalExpressShippingMethodViewController.h"
#import <SimiCartBundle/SimiFormatter.h>
#import <SimiCartBundle/SCCartViewControllerPad.h>
#import <SimiCartBundle/SCThemeWorker.h>
#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/UIImageView+WebCache.h>

#define SHIPPING_METHOD_SECTION @"SHIPPING_METHOD_SECTION"
#define SHIPPING_METHOD_ROW @"SHIPPING_METHOD_ROW"
#define PRODUCT_TOTAL_SECTION @"PRODUCT_TOTAL_SECTION"
#define PRODUCT_TOTAL_ROW @"PRODUCT_TOTAL_ROW"
#define PRODUCT_SECTION @"PRODUCT_SECTION"
#define PRODUCT_ROW @"PRODUCT_ROW"

@interface SCPaypalExpressShippingMethodViewController ()
{
    NSMutableArray *listShippingMethods;
    NSMutableArray* orderTotal;
}
@end

@implementation SCPaypalExpressShippingMethodViewController
{
    UIButton * placeOrderButton;
    NSInteger selectedShippingMethod;
    NSArray* productList;
    SimiTable* cells;
}
@synthesize paypalModel,paypalShippingModel,shippingMethodTableView;


- (void)viewDidLoadBefore
{
    self.navigationItem.title = SCLocalizedString(@"Shipping Method");
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    
}

- (void)viewDidAppearBefore:(BOOL)animated
{
    if (shippingMethodTableView == nil) {
        shippingMethodTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 50) style:UITableViewStyleGrouped];
        shippingMethodTableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        shippingMethodTableView.dataSource = self;
        shippingMethodTableView.delegate = self;
        [self.view addSubview:shippingMethodTableView];
        placeOrderButton = [[UIButton alloc]initWithFrame:CGRectMake(0 , self.view.bounds.size.height - 50, self.view.bounds.size.width, 50)];
        [placeOrderButton setBackgroundColor:THEME_BUTTON_BACKGROUND_COLOR];
        placeOrderButton.tintColor = THEME_BUTTON_TEXT_COLOR;
        [placeOrderButton setTitle:SCLocalizedString(@"Place Order") forState:UIControlStateNormal];
        [placeOrderButton addTarget:self action:@selector(placeOrder:) forControlEvents:UIControlEventTouchUpInside];
        placeOrderButton.hidden = YES;
        [self.view addSubview:placeOrderButton];
        [self getShippingMethod];
    }
}

#pragma mark Get Shipping Methods
- (void)getShippingMethod
{
    [self startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetShippingMethods:) name:@"DidGetPaypalCheckoutShippingMethods" object:nil];
    paypalShippingModel = [SCPaypalExpressModel new];
    [paypalShippingModel getShippingMethods];
}

- (void)didGetShippingMethods:(NSNotification *)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    [self removeObserverForNotification:noti];
    [self stopLoadingData];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        cells = [SimiTable new];
        placeOrderButton.hidden = NO;
        listShippingMethods = [[NSMutableArray alloc]initWithArray:[paypalShippingModel valueForKey:@"methods"]];
        productList = [[paypalShippingModel objectForKey:@"app_customization"] objectForKey:@"products_ordered"];
        SimiSection* productSection = [cells addSectionWithIdentifier:PRODUCT_SECTION];
        productSection.headerTitle = SCLocalizedString(@"Products Orderred");
        for(NSDictionary* product in productList){
            SimiRow* productRow = [[SimiRow alloc] initWithIdentifier:PRODUCT_ROW height:110];
            productRow.data = [product copy];
            [productSection addRow:productRow];
        }
        SimiSection* totalSection = [cells addSectionWithIdentifier:PRODUCT_TOTAL_SECTION];
        orderTotal = [[SimiGlobalVar sharedInstance] convertCartPriceData:[[paypalShippingModel objectForKey:@"app_customization"] objectForKey:@"order_total"]];
        float heightRow;
        if(![[SimiGlobalVar sharedInstance] isReverseLanguage]){
            heightRow = 25 * [SimiGlobalVar sharedInstance].numberRowOnCartPrice + 10;
        }else{
            heightRow = [SimiGlobalVar scaleValue:50] * [SimiGlobalVar sharedInstance].numberRowOnCartPrice + 10;
        }
        SimiRow* totalRow = [[SimiRow alloc] initWithIdentifier:PRODUCT_TOTAL_ROW height:heightRow];
        [totalSection addRow:totalRow];
        
        SimiSection* shippingSection = [cells addSectionWithIdentifier:SHIPPING_METHOD_SECTION];
        shippingSection.headerTitle = SCLocalizedString(@"Please select shipping method");
        for(NSDictionary* shippingMethod in listShippingMethods){
            SimiRow* shippingRow = [[SimiRow alloc] initWithIdentifier:SHIPPING_METHOD_ROW height:50];
            [shippingSection addRow:shippingRow];
            shippingRow.data = [shippingMethod copy];
        }
        [shippingMethodTableView reloadData];
    }
    else {
        placeOrderButton.hidden = YES;
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:SCLocalizedString(@"Error") message:responder.responseMessage delegate:self cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alert show];
    }
}

-(void) saveShippingMethod:(NSString* ) methodCode{
    if(!paypalShippingModel)
        paypalShippingModel = [SCPaypalExpressModel new];
    [paypalShippingModel saveShippingMethod:@{@"s_method":@{@"method":methodCode}}];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetShippingMethods:) name:DidSaveShippingMethod object:nil];
    [self startLoadingData];
}

#pragma mark TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return cells.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SimiSection* simiSection = [cells objectAtIndex:section];
    return simiSection.count;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    SimiSection* simiSection = [cells objectAtIndex:section];
    return simiSection.headerTitle;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection* section = [cells objectAtIndex:indexPath.section];
    SimiRow* row = [section objectAtIndex:indexPath.row];
    return row.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection* section = [cells objectAtIndex:indexPath.section];
    SimiRow* row = [section objectAtIndex:indexPath.row];
    UITableViewCell *cell = [UITableViewCell new];
    float paddingX = 10;
    float cellWidth = tableView.frame.size.width - 2*paddingX;
//    float cellHeight = row.height;
    if([row.identifier isEqualToString:SHIPPING_METHOD_ROW]){
        NSDictionary* shippingMethod = row.data;
        NSString* identifier = [NSString stringWithFormat:@"%@%@",SHIPPING_METHOD_ROW,[shippingMethod objectForKey:@"s_method_id"]];
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(!cell){
            float cellY = 0;
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(paddingX, cellY, cellWidth, 25)];
            [nameLabel setText: [NSString stringWithFormat:@"%@",[shippingMethod objectForKey:@"s_method_title"]]];
            [cell addSubview:nameLabel];
            cellY += nameLabel.frame.size.height;
            UILabel* priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(paddingX, cellY, cellWidth, 25)];
            [priceLabel setText: [[SimiFormatter sharedInstance] priceWithPrice:[shippingMethod objectForKey:@"s_method_fee"]]];
            [cell addSubview:priceLabel];
        }
        if([[shippingMethod objectForKey:@"s_method_selected"] boolValue]){
            selectedShippingMethod = indexPath.row;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }else if([row.identifier isEqualToString:PRODUCT_ROW]){
        NSDictionary* product = row.data;
        NSString* identifier = [NSString stringWithFormat:@"%@%@",PRODUCT_ROW,[product objectForKey:@"product_id"]];
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        SCCartCell *cartCell = [[SCCartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cartCell.useOnOrderPage = YES;
        [cartCell setItem:[SimiCartModel dictionaryWithDictionary:product]];
        [cartCell setInterfaceCell];
        cell = cartCell;
        if (cartCell.heightCell > row.height) {
            row.height = cartCell.heightCell;
            [tableView reloadData];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else if([row.identifier isEqualToString:PRODUCT_TOTAL_ROW]){
        cell = [[SCOrderFeeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PRODUCT_TOTAL_ROW];
        [(SCOrderFeeCell *)cell setData:orderTotal andWidthCell:cellWidth];
        cell.userInteractionEnabled = NO;
    }
    for(UIView* view in cell.subviews){
        if([view isKindOfClass:[UILabel class]]){
            UILabel* label = (UILabel*) view;
            label.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
            if([SimiGlobalVar sharedInstance].isReverseLanguage)
                label.textAlignment = NSTextAlignmentRight;
        }
    }
    return cell;
}


#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SimiSection* section = [cells objectAtIndex:indexPath.section];
    if([section.identifier isEqualToString:SHIPPING_METHOD_SECTION]){
        NSDictionary* shippingMethod = [listShippingMethods objectAtIndex:indexPath.row];
        [self saveShippingMethod:[shippingMethod objectForKey:@"s_method_code"]];
        [tableView reloadData];
    }
}

#pragma mark Place Order
- (void)placeOrder :(id)sender
{
    [self startLoadingData];
    if (paypalModel == nil) {
        paypalModel = [[SCPaypalExpressModel alloc]init];
    }
    SimiModel *method = [SimiModel new];
    [method setValue:@{@"method":[NSString stringWithFormat:@"%@",[[listShippingMethods objectAtIndex:selectedShippingMethod] objectForKey:@"s_method_code"]]}forKey:@"s_method"];
    [paypalModel placeOrderWithParam:method];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceOrder:) name:@"PaypalExpressDidPlaceOrder" object:nil];
}

- (void)didPlaceOrder:(NSNotification *)noti
{
    [self stopLoadingData];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if (PHONEDEVICE) {
        SCCartViewController * cartVC = [[SCThemeWorker sharedInstance].navigationBarPhone cartViewController];
        [cartVC getCart];
    }else
    {
        SCCartViewControllerPad * cartVC = [[SCThemeWorker sharedInstance].navigationBarPad cartViewControllerPad];
        [cartVC getCart];
    }
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:SCLocalizedString(@"Thank you for your purchase") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:responder.responseMessage delegate:self cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alert show];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DidCompleteCheckOutWithPaypalExpress" object:nil];
}
@end
