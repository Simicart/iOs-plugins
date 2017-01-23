//
//  BTPaymentViewController.m
//  SimiCartPluginFW
//
//  Created by Axe on 12/8/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//
@import PassKit;
#import "BTPaymentViewController.h"

#define BRAINTREE_APPLEPAY @"braintree_applepay"
#define BRAINTREE_GOOGLEPAY @"braintree_googlepay"
#define BRAINTREE_CREDITCARD @"braintree_creditcard"
#define BRAINTREE_PAYPAL @"braintree_paypal"

@interface BTPaymentViewController ()
@end

@implementation BTPaymentViewController{
    NSMutableArray* paymentList;
    SimiBraintreeModel* braintreeModel;
    NSString* clientToken;
}
@synthesize braintreeClient,order;


-(void) viewWillAppearBefore:(BOOL)animated{
    
}

-(void) configureLogo{
    
}


-(void) viewDidLoad{
    clientToken = [_payment valueForKey:@"token"];
    self.braintreeClient = [[BTAPIClient alloc] initWithAuthorization:clientToken];
    if([_payment valueForKey:@"payment_list"]){
        paymentList = [_payment valueForKey:@"payment_list"];
    }
    if([paymentList containsObject:BRAINTREE_APPLEPAY]){
        //Remove for unsupporting
//        [paymentList removeObject:BRAINTREE_APPLEPAY];
//        if (![PKPaymentAuthorizationViewController class] || ![PKPaymentAuthorizationViewController canMakePayments] || ![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa]]) {
//            [paymentList removeObject:BRAINTREE_APPLEPAY];
//            [self showAlertWithTitle:SCLocalizedString(@"Apple Pay") message:SCLocalizedString(@"This device cannot make payments with Apple Pay")];
//        }
    }
    if([paymentList containsObject:BRAINTREE_GOOGLEPAY])
        [paymentList removeObject:BRAINTREE_GOOGLEPAY];
    if([paymentList containsObject:BRAINTREE_CREDITCARD])
        [paymentList removeObject:BRAINTREE_CREDITCARD];
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.view = tableView;
    self.title = SCLocalizedString(@"Braintree");
    [super viewDidLoad];
}


#pragma mark TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* identifier = [paymentList objectAtIndex:indexPath.row];
    if([identifier isEqualToString:BRAINTREE_APPLEPAY]){
        [self payWithApplePay];
    }else if([identifier isEqualToString:BRAINTREE_PAYPAL]){
        [self showDropIn:[_payment objectForKey:@"token"]];
    }
    else{
        
    }
}

-(void) showDropIn:(NSString*) clientTokenOrTokenizationKey{
    BTDropInRequest *request = [[BTDropInRequest alloc] init];
    BTDropInController *dropIn = [[BTDropInController alloc] initWithAuthorization:clientTokenOrTokenizationKey request:request handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        if (error != nil) {
            NSLog(@"ERROR");
        } else if (result.cancelled) {
            NSLog(@"CANCELLED");
        } else {
            // Use the BTDropInResult properties to update your UI
            // result.paymentOptionType
            // result.paymentMethod
            // result.paymentIcon
            // result.paymentDescription
            if(result.paymentMethod.nonce){
                [self postNonceToServer:result.paymentMethod.nonce];
            }
        }
    }];
    [self presentViewController:dropIn animated:YES completion:nil];
}
- (PKPaymentRequest *)applePaymentRequest {
    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    paymentRequest.requiredBillingAddressFields = PKAddressFieldName;
    PKShippingMethod *shippingMethod = [PKShippingMethod summaryItemWithLabel:[_shipping valueForKey:@"s_method_title"] amount:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",[_shipping valueForKey:@"s_method_fee"]]]];
    shippingMethod.detail = [_shipping valueForKey:@"s_method_name"] ;
    shippingMethod.identifier = [_shipping valueForKey:@"s_method_id"];
    paymentRequest.shippingMethods = @[shippingMethod];
    paymentRequest.requiredShippingAddressFields = PKAddressFieldAll;
    
    paymentRequest.merchantIdentifier = [self.payment valueForKey:@"apple_merchant"];
#ifdef __IPHONE_9_0
    paymentRequest.supportedNetworks = @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex, PKPaymentNetworkDiscover];
#else
    paymentRequest.supportedNetworks = @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex];
#endif
    paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
    paymentRequest.countryCode = @"US";
    paymentRequest.currencyCode = @"USD";
//    if ([paymentRequest respondsToSelector:@selector(setShippingType:)]) {
//        paymentRequest.shippingType = PKShippingTypeDelivery;
//    }
    {
        //Shipping Contact
        NSDictionary* shippingAddress = [order objectForKey:@"shipping_address"];
        PKContact* shippingContact = [[PKContact alloc] init];
        NSPersonNameComponents *name = [[NSPersonNameComponents alloc] init];
        name.givenName = [shippingAddress objectForKey:@"firstname"];
        name.familyName = [shippingAddress objectForKey:@"lastname"];
        shippingContact.name = name;

        CNMutablePostalAddress *address = [[CNMutablePostalAddress alloc] init];
        address.street = [shippingAddress objectForKey:@"street"];
        address.city = [shippingAddress objectForKey:@"city"];
        address.state = [shippingAddress objectForKey:@"region"];
        address.postalCode = [shippingAddress objectForKey:@"postcode"];
        
        shippingContact.postalAddress = address;
        paymentRequest.shippingContact = shippingContact;
    }
    {
        //Billing Contact
        NSDictionary* billingAddress = [order objectForKey:@"billing_address"];
        PKContact* billingContact = [[PKContact alloc] init];
        NSPersonNameComponents *name = [[NSPersonNameComponents alloc] init];
        name.givenName = [billingAddress objectForKey:@"firstname"];
        name.familyName = [billingAddress objectForKey:@"lastname"];
        billingContact.name = name;
        
        CNMutablePostalAddress *address = [[CNMutablePostalAddress alloc] init];
        address.street = [billingAddress objectForKey:@"street"];
        address.city = [billingAddress objectForKey:@"city"];
        address.state = [billingAddress objectForKey:@"region"];
        address.postalCode = [billingAddress objectForKey:@"postcode"];
        
        billingContact.postalAddress = address;
        paymentRequest.billingContact = billingContact;
    }
    NSMutableDictionary* fees = [order objectForKey:@"total"];
    
    NSDecimalNumber* subTotal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[[fees valueForKey:@"subtotal_incl_tax"] floatValue]]];
    NSDecimalNumber* shippingFee;
    if([fees objectForKey:@"shipping_hand_incl_tax"]){
        shippingFee = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[[fees valueForKey:@"shipping_hand_incl_tax"] floatValue]]];
    }else{
        shippingFee = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    NSDecimalNumber* grandTotal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[[fees valueForKey:@"grand_total_incl_tax"] floatValue]]];
    
    paymentRequest.paymentSummaryItems =
    @[
      [PKPaymentSummaryItem summaryItemWithLabel:@"Subtotal" amount:subTotal],
      [PKPaymentSummaryItem summaryItemWithLabel:@"Shipping" amount:shippingFee],
      [PKPaymentSummaryItem summaryItemWithLabel:@"Grand Total" amount:grandTotal],
      ];
    return paymentRequest;
}

-(void) payWithApplePay{
    PKPaymentAuthorizationViewController *vc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:[self applePaymentRequest]];
    vc.delegate = self;
    if(vc){
        [self presentViewController:vc animated:YES completion:nil];
    }else{
        [self showAlertWithTitle:SCLocalizedString(@"Apple Pay") message:SCLocalizedString(@"This device cannot make payments with Apple Pay")];
    }
}

#pragma mark TableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section_{
    return paymentList.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* identifier = [paymentList objectAtIndex:indexPath.row];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        if([identifier isEqualToString:BRAINTREE_APPLEPAY]){
            PKPaymentButton *applePayButton = [[PKPaymentButton alloc] initWithPaymentButtonType:PKPaymentButtonTypePlain paymentButtonStyle:PKPaymentButtonStyleBlack];
            [applePayButton addTarget:self action:@selector(payWithApplePay) forControlEvents:UIControlEventTouchUpInside];
            applePayButton.frame = CGRectMake(44, 7, 100, 30);
            [cell addSubview:applePayButton];
        }else if([identifier isEqualToString:BRAINTREE_PAYPAL]){
            cell.textLabel.text = @"Pay with Paypal and Card";
        }
        else{
            
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(!cell)
        cell = [UITableViewCell new];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel* lblHeader = [UILabel new];
    lblHeader.text = SCLocalizedString(@"Braintree");
    lblHeader.backgroundColor = [UIColor blackColor];
    lblHeader.textColor = [UIColor whiteColor];
    lblHeader.textAlignment = NSTextAlignmentCenter;
    lblHeader.font = [UIFont fontWithName:@"Helvetica-Bold" size:30];
    return lblHeader;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (void)userDidCancelPayment {
    [self dismissViewControllerAnimated:YES completion:nil];
}


//ApplePay Delegate
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    
    // Example: Tokenize the Apple Pay payment
    BTApplePayClient *applePayClient = [[BTApplePayClient alloc]
                                        initWithAPIClient:self.braintreeClient];
    [applePayClient tokenizeApplePayPayment:payment
                                 completion:^(BTApplePayCardNonce *tokenizedApplePayPayment,
                                              NSError *error) {
                                     if(!error){
                                         [self showAlertWithTitle:SCLocalizedString(@"Apple Pay") message:[NSString stringWithFormat:@"Cannot make payments.Error: %@", error]];
                                     }
                                     if (tokenizedApplePayPayment.nonce) {
                                         [self postNonceToServer:tokenizedApplePayPayment.nonce];
                                         completion(PKPaymentAuthorizationStatusSuccess);
                                     } else {
                                         completion(PKPaymentAuthorizationStatusFailure);
                                         [self showAlertWithTitle:SCLocalizedString(@"Apple Pay") message:SCLocalizedString(@"Something went wrong")];
                                     }
                                 }];
}


// Be sure to implement -paymentAuthorizationViewControllerDidFinish:
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}
-(void) paymentAuthorizationViewControllerWillAuthorizePayment:(PKPaymentAuthorizationViewController *)controller{
    
}

- (void)postNonceToServer:(NSString *)paymentMethodNonce {
    if(!braintreeModel)
        braintreeModel = [SimiBraintreeModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:BRAINTREE_SENDNONCETOSERVER object:braintreeModel];
    [self startLoadingData];
    [braintreeModel sendNonceToServer:paymentMethodNonce andOrder:order];
}

-(void) viewWillDisappear:(BOOL)animated{
    [[SimiGlobalVar sharedInstance].currentlyNavigationController popToRootViewControllerAnimated:YES];
}

-(void) didReceiveNotification:(NSNotification *)noti{
    SimiResponder* responder = [noti.userInfo valueForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]){
        if([noti.name isEqualToString:BRAINTREE_SENDNONCETOSERVER]){
            SCThankYouPageViewController* thankyouPage = [SCThankYouPageViewController new];
            thankyouPage.order = order;
            [thankyouPage.navigationItem setHidesBackButton:YES];
            [self.navigationController pushViewController:thankyouPage animated:YES];
        }
    }else{
        [self showAlertWithTitle:SCLocalizedString(@"") message:responder.responseMessage];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    [self removeObserverForNotification:noti];
}

#pragma mark - BTViewControllerPresentingDelegate

// Required
- (void)paymentDriver:(id)paymentDriver
requestsPresentationOfViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

// Required
- (void)paymentDriver:(id)paymentDriver
requestsDismissalOfViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - BTAppSwitchDelegate

// Optional - display and hide loading indicator UI
- (void)appSwitcherWillPerformAppSwitch:(id)appSwitcher {
    [self showLoadingUI];
    
    // You may also want to subscribe to UIApplicationDidBecomeActiveNotification
    // to dismiss the UI when a customer manually switches back to your app since
    // the payment button completion block will not be invoked in that case (e.g.
    // customer switches back via iOS Task Manager)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideLoadingUI:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)appSwitcherWillProcessPaymentInfo:(id)appSwitcher {
    [self hideLoadingUI:nil];
}

- (void)appSwitcher:(id)appSwitcher didPerformSwitchToTarget:(BTAppSwitchTarget)target{
    
}


#pragma mark - Private methods

- (void)showLoadingUI {
    [self startLoadingData];
}

- (void)hideLoadingUI:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [self stopLoadingData];
}

#pragma mark BTDropInViewControllerDelegate
- (void)dropInViewController:(BTDropInViewController *)viewController didSucceedWithTokenization:(BTPaymentMethodNonce *)paymentMethodNonce{
    if(paymentMethodNonce.nonce){
        [self postNonceToServer:paymentMethodNonce.nonce];
    }
}

- (void)dropInViewControllerDidCancel:(BTDropInViewController *)viewController{
    NSLog(@"DIDCANCEL");
}


@end
