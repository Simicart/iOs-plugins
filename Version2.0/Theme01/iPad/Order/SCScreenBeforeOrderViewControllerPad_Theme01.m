//
//  SCScreenBeforeOrderViewControllerPad_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 10/2/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCScreenBeforeOrderViewControllerPad_Theme01.h"
#import "SimiGlobalVar+Theme01.h"

@interface SCScreenBeforeOrderViewControllerPad_Theme01 ()
{
    BOOL isSelectBillingAddress;
}

@end

@implementation SCScreenBeforeOrderViewControllerPad_Theme01

#pragma mark Main Method
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = [SCLocalizedString(@"Review Order") uppercaseString];
    if (SIMI_SYSTEM_IOS >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self setToSimiView];
    _tblViewOrder = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    _tblViewOrder.dataSource = self;
    _tblViewOrder.delegate = self;
    _tblViewOrder.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_tblViewOrder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if (![[SimiGlobalVar sharedInstance] isLogin]) {
        [self askCustomerRole];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

#pragma UI Table View DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AskUserCell"];
    cell.textLabel.text = SCLocalizedString(@"Please add a billing address");
    cell.textLabel.textColor = [UIColor blueColor];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#pragma mark Check User
- (void)askCustomerRole{
    UIActionSheet *actionSheet;
    SimiStoreModel *store = [[SimiGlobalVar sharedInstance] store];
    if ([[[store valueForKey:@"checkout_config"] valueForKey:@"enable_guest_checkout"] boolValue]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:SCLocalizedString(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:SCLocalizedString(@"Checkout as existing customer"), SCLocalizedString(@"Checkout as new customer"), SCLocalizedString(@"Checkout as guest"), nil];
    }else{
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:SCLocalizedString(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:SCLocalizedString(@"Checkout as existing customer"), SCLocalizedString(@"Checkout as new customer"), nil];
    }
    [actionSheet showInView:self.view];
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
                SCLoginViewController_Theme01 *nextController = [[SCLoginViewController_Theme01 alloc] init];
                nextController.delegate = self;
                nextController.isLoginInCheckout = YES;
                [self.navigationController pushViewController:nextController animated:YES];
            }
                break;
            case 1: //Checkout as new customer
            {
                self.isNewCustomer = YES;
                isSelectBillingAddress = YES;
                SCNewAddressViewController *nextController = [[SCNewAddressViewController alloc]init];
                nextController.isNewCustomer = YES;
                nextController.delegate = self;
                [self.navigationController pushViewController:nextController animated:YES];
            }
                break;
            case 2: //Checkout as guest
            {
                self.isNewCustomer = NO;
                isSelectBillingAddress = YES;
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
                self.isNewCustomer = NO;
                SCLoginViewController_Theme01 *nextController = [[SCLoginViewController_Theme01 alloc] init];
                nextController.delegate = self;
                nextController.isLoginInCheckout = YES;
                [self.navigationController pushViewController:nextController animated:YES];
            }
                break;
            case 1: //Checkout as new customer
            {
                self.isNewCustomer = YES;
                isSelectBillingAddress = YES;
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
    //  End
    /*
    switch (buttonIndex) {
        case 0: //Checkout as existing customer
        {
            self.isNewCustomer = NO;
            SCLoginViewController_Theme01 *nextController = [[SCLoginViewController_Theme01 alloc] init];
            nextController.delegate = self;
            nextController.isLoginInCheckout = YES;
            [self.navigationController pushViewController:nextController animated:YES];
        }
            break;
        case 1: //Checkout as new customer
        {
            self.isNewCustomer = YES;
            isSelectBillingAddress = YES;
            SCNewAddressViewController *nextController = [[SCNewAddressViewController alloc]init];
            nextController.isNewCustomer = YES;
            nextController.delegate = self;
            [self.navigationController pushViewController:nextController animated:YES];
        }
            break;
        case 2: //Checkout as guest
        {
            self.isNewCustomer = NO;
            isSelectBillingAddress = YES;
            SCNewAddressViewController *nextController = [[SCNewAddressViewController alloc]init];
            nextController.delegate = self;
            [self.navigationController pushViewController:nextController animated:YES];
        }
            break;
        default: //Cancel
        break;
    }
    */
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //  Liam UPDATE 150421
    SimiStoreModel *store = [[SimiGlobalVar sharedInstance] store];
    BOOL isEnableGuestCheckout = [[[store valueForKey:@"checkout_config"] valueForKey:@"enable_guest_checkout"] boolValue];
    if (isEnableGuestCheckout) {
        if (buttonIndex != 0 && buttonIndex != 1 && buttonIndex != 2) {
            [self.delegate didCancelCheckout];
        }
    }else
    {
        if (buttonIndex != 0 && buttonIndex != 1) {
            [self.delegate didCancelCheckout];
        }
    }
    //  End 150421
}

#pragma mark NewAddress Delegate
- (void)didSaveAddress:(SimiAddressModel *)address
{
    [self.delegate didGetAddressModelForCheckOut:address andIsNewCustomer:self.isNewCustomer];
}

#pragma mark Address Delegate
- (void)selectAddress:(SimiAddressModel *)address
{
    [self.delegate didGetAddressModelForCheckOut:address andIsNewCustomer:self.isNewCustomer];
}

#pragma mark Login Delegate
-(void)didFinishLoginSuccess
{
    [self.delegate reloadCartDetail];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    isSelectBillingAddress = YES;
    SCAddressViewController *nextController = [[SCAddressViewController alloc]init];
    [nextController setDelegate:self];
    [nextController setIsGetOrderAddress:YES];
    [self.navigationController pushViewController:nextController animated:YES];
}
@end
