//
//  BTPaymentViewController.m
//  SimiCartPluginFW
//
//  Created by Axe on 12/8/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//
@import PassKit;
#import <PassKit/PKPaymentAuthorizationViewController.h>
#import "BraintreeApplePay.h"
#import "BTPaymentViewController.h"
#import "BraintreeCard.h"
#import "BraintreePayPal.h"
#import "SimiBraintreeModel.h"
#import <SimiCartBundle/SCThankyouPageViewController.h>

@interface BTPaymentViewController ()
@end

@implementation BTPaymentViewController{
    NSMutableArray* paymentList;
    SimiBraintreeModel* braintreeModel;
}
@synthesize braintreeClient,order;

-(void) viewDidLoadBefore{
    NSString* clientToken = [_payment valueForKey:@"token"];
    self.braintreeClient = [[BTAPIClient alloc] initWithAuthorization:clientToken];
    if([_payment valueForKey:@"payment_list"]){
        paymentList = [_payment valueForKey:@"payment_list"];
    }
    if([paymentList containsObject:@"braintree_googlepay"])
        [paymentList removeObject:@"braintree_googlepay"];
    if([paymentList containsObject:@"braintree_creditcard"])
        [paymentList removeObject:@"braintree_creditcard"];
    
//    [paymentList addObject:@"dropin_payment"];
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    tableView.delegate = self;
    tableView.dataSource = self;
//    tableView.separatorColor = [UIColor clearColor];
    self.view = tableView;
    self.title = SCLocalizedString(@"Braintree");
    [super viewDidLoadBefore];
}


#pragma mark TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* identifier = [paymentList objectAtIndex:indexPath.row];
    if([identifier isEqualToString:@"braintree_applepay"]){
        PKPaymentRequest *paymentRequest = [self paymentRequest];
        if([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:paymentRequest.supportedNetworks]){
            PKPaymentAuthorizationViewController *vc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
            vc.delegate = self;
            if(vc)
                [self presentViewController:vc animated:YES completion:nil];
        }else{
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Apple Pay" message:@"This device cannot make payments" delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else if([identifier isEqualToString:@"braintree_paypal"]){
        BTDropInViewController* dropInVC = [[BTDropInViewController alloc] initWithAPIClient:self.braintreeClient];
        dropInVC.delegate = self;
        [self.navigationController pushViewController:dropInVC animated:YES];
    }
    else{
    
    }
}
- (PKPaymentRequest *)paymentRequest {
    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    paymentRequest.merchantIdentifier = [self.payment valueForKey:@"apple_merchant"];
    paymentRequest.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkVisa, PKPaymentNetworkMasterCard];
    paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
    paymentRequest.countryCode = [[[[SimiGlobalVar sharedInstance] store] objectForKey:@"store_config"] valueForKey:@"country_code"];
    paymentRequest.currencyCode = [[[[SimiGlobalVar sharedInstance] store] objectForKey:@"store_config" ] valueForKey:@"currency_code"];
    NSMutableDictionary* fees = [order objectForKey:@"fee"];
    
    NSDecimalNumber* subTotal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",[fees valueForKey:@"sub_total"]]];
    
    
    
    NSDecimalNumber* grandTotal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",[fees valueForKey:@"grand_total"]]];

    paymentRequest.paymentSummaryItems =
    @[
      [PKPaymentSummaryItem summaryItemWithLabel:@"Subtotal" amount:subTotal],
      [PKPaymentSummaryItem summaryItemWithLabel:@"Grand Total" amount:grandTotal],
      ];
    return paymentRequest;
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
        if([identifier isEqualToString:@"braintree_applepay"]){
            cell.textLabel.text = @"Pay with Apple Pay";
        }else if([identifier isEqualToString:@"braintree_paypal"]){
            cell.textLabel.text = @"Pay with Paypal and Card";
        }
        else{
            
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
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
                                         UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Apple Pay" message:@"This device cannot make payments" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                         [alertView show];
                                     }
                                     if (tokenizedApplePayPayment) {
                                         
                                         [self postNonceToServer:tokenizedApplePayPayment.nonce];
                                     
                                         completion(PKPaymentAuthorizationStatusSuccess);
                                     } else {
                                         completion(PKPaymentAuthorizationStatusFailure);
//                                         [self.navigationController popToRootViewControllerAnimated:YES];
                                         UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Apple Pay" message:@"This device cannot make payments" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                         [alertView show];
                                     }
                                 }];
}


// Be sure to implement -paymentAuthorizationViewControllerDidFinish:
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postNonceToServer:(NSString *)paymentMethodNonce {
    if(!braintreeModel)
        braintreeModel = [SimiBraintreeModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"BRAINTREE-SENDNONCETOSERVER" object:braintreeModel];
    [self startLoadingData];
    [braintreeModel sendNonceToServer:paymentMethodNonce andOrder:order];
}

-(void) didReceiveNotification:(NSNotification *)noti{
    SimiResponder* responder = [noti.userInfo valueForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]){
        if([noti.name isEqualToString:@"BRAINTREE-SENDNONCETOSERVER"]){
            SCThankYouPageViewController* thankyouPage = [SCThankYouPageViewController new];
            thankyouPage.order = order;
            [thankyouPage.navigationItem setHidesBackButton:YES];
            [self.navigationController pushViewController:thankyouPage animated:YES];
        }
    }else{
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil, nil];
        [alertView show];
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
