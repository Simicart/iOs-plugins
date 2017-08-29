//
//  BraintreeInitWorker.m
//  SimiCartPluginFW
//
//  Created by Axe on 12/8/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "BraintreeInitWorker.h"
#import <SimiCartBundle/SimiOrderModel.h>
#import <SimiCartBundle/SCThankYouPageViewController.h>
#import "SimiBraintreeModel.h"
#import "BraintreeDropIn.h"

#define DidSelectPaymentMethod @"DidSelectPaymentMethod"
#define DidPlaceOrderAfter @"DidPlaceOrder-After"
#define DidPlaceOrderBefore @"SCOrderViewController-BeforePlaceOrder"
#define BRAINTREE_PAYMENT_METHOD @"simibraintree"

@implementation BraintreeInitWorker
{
    SimiViewController *currentVC;
    SimiOrderModel* order;
    NSDictionary* selectedPayment;
    NSDictionary* selectedShipping;
    SimiBraintreeModel* braintreeModel;
    BOOL applePayCompleted;
}
- (instancetype) init{
    if(self == [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationDidFinishLaunching" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationOpenURL" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidSelectPaymentMethod object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidPlaceOrderAfter object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidPlaceOrderBefore object:nil];
        [BTAppSwitch setReturnURLScheme:[NSString stringWithFormat:@"%@.payments",[NSBundle mainBundle].bundleIdentifier]];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti{
    if([noti.name isEqualToString:@"ApplicationDidFinishLaunching"]){
    }else if([noti.name isEqualToString:@"ApplicationOpenURL"]){
        NSURL *url = [noti.userInfo valueForKey:@"url"];
        NSString* sourceApplication = [noti.userInfo valueForKey:@"source_application"];
        NSNumber* number = noti.object;
        if ([url.scheme localizedCaseInsensitiveCompare:[NSString stringWithFormat:@"%@.payments",[NSBundle mainBundle].bundleIdentifier]] == NSOrderedSame) {
            number = [NSNumber numberWithBool:[BTAppSwitch handleOpenURL:url sourceApplication:sourceApplication]];
        }
    }else if([noti.name isEqualToString:DidSelectPaymentMethod]){
        
    }else if([noti.name isEqualToString:DidPlaceOrderAfter]){
        if([[[[noti.userInfo valueForKey:@"data"] valueForKey:@"payment_method"] lowercaseString] isEqualToString:BRAINTREE_PAYMENT_METHOD]){
            selectedPayment = [noti.userInfo objectForKey:@"payment"];
            selectedShipping = [noti.userInfo objectForKey:@"shipping"];
            currentVC = [noti.userInfo valueForKey:@"controller"];
            [order addEntriesFromDictionary:noti.object];
            [self showDropIn:[selectedPayment objectForKey:@"token"]];
        }
    }else if([noti.name isEqualToString:DidPlaceOrderBefore]){
        order = [[SimiOrderModel alloc] initWithDictionary:[noti.userInfo objectForKey:@"order"]];
    }
}

- (void)showDropIn:(NSString*) clientTokenOrTokenizationKey{
    BTDropInRequest *request = [[BTDropInRequest alloc] init];
    //    request.applePayDisabled = YES;
    request.threeDSecureVerification = YES;
    NSMutableDictionary* fees = [order objectForKey:@"total"];
    NSString* grandTotal = [NSString stringWithFormat:@"%.2f",[[fees valueForKey:@"grand_total_incl_tax"] floatValue]];
    request.amount = grandTotal;
    request.currencyCode = [SimiGlobalVar sharedInstance].currencyCode;
    BTDropInController *dropIn = [[BTDropInController alloc] initWithAuthorization:clientTokenOrTokenizationKey request:request handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        if (error != nil) {
            NSLog(@"ERROR");
            [currentVC showToastMessage:error.localizedDescription];
            [currentVC.navigationController popToRootViewControllerAnimated:NO];
        } else if (result.cancelled) {
            NSLog(@"CANCELLED");
            [currentVC.navigationController popToRootViewControllerAnimated:NO];
        } else {
            //             Use the BTDropInResult properties to update your UI
            //             result.paymentOptionType
            //             result.paymentMethod
            //             result.paymentIcon
            //             result.paymentDescription
            if(result.paymentOptionType == BTUIKPaymentOptionTypeApplePay){
                PKPaymentAuthorizationViewController *viewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:[self applePaymentRequest]];
                viewController.delegate = self;
                [currentVC presentViewController:viewController animated:YES completion:nil];
                applePayCompleted = NO;
            }else {
                if(result.paymentMethod.nonce){
                    [self postNonceToServer:result.paymentMethod.nonce];
                }
            }
        }
    }];
    if(dropIn)
        [currentVC presentViewController:dropIn animated:YES completion:nil];
    else
        [currentVC showAlertWithTitle:@"Braintree" message:SCLocalizedString(@"The provided authorization was invalid")];
}

- (PKPaymentRequest *)applePaymentRequest {
    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    paymentRequest.merchantIdentifier = [selectedPayment valueForKey:@"apple_merchant"];
#ifdef __IPHONE_9_0
    paymentRequest.supportedNetworks = @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex, PKPaymentNetworkDiscover];
#else
    paymentRequest.supportedNetworks = @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex];
#endif
    paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
    paymentRequest.countryCode = [SimiGlobalVar sharedInstance].countryCode;
    paymentRequest.currencyCode = [SimiGlobalVar sharedInstance].currencyCode;
    //Shipping and Billing is not required
    paymentRequest.requiredBillingAddressFields = NO;
    paymentRequest.requiredShippingAddressFields = NO;
    NSMutableDictionary* fees = [order objectForKey:@"total"];
    
    NSDecimalNumber* subTotal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[[fees valueForKey:@"subtotal_incl_tax"] floatValue]]];
    NSDecimalNumber* shippingFee;
    if([fees objectForKey:@"shipping_hand_incl_tax"]){
        shippingFee = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[[fees valueForKey:@"shipping_hand_incl_tax"] floatValue]]];
    }else{
        shippingFee = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    NSDecimalNumber* grandTotal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[[fees valueForKey:@"grand_total_incl_tax"] floatValue]]];
    NSMutableArray* summaryItems = [[NSMutableArray alloc] init];
    [summaryItems addObject:[PKPaymentSummaryItem summaryItemWithLabel:@"Subtotal" amount:subTotal]];
    if(shippingFee.floatValue > 0){
        [summaryItems addObject:[PKPaymentSummaryItem summaryItemWithLabel:@"Shipping" amount:shippingFee]];
    }
    [summaryItems addObject:[PKPaymentSummaryItem summaryItemWithLabel:@"Grand Total" amount:grandTotal]];
    paymentRequest.paymentSummaryItems = summaryItems;
    return paymentRequest;
}

//ApplePay Delegate
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    
    // Example: Tokenize the Apple Pay payment
    BTApplePayClient *applePayClient = [[BTApplePayClient alloc]
                                        initWithAPIClient:[[BTAPIClient alloc] initWithAuthorization:[selectedPayment valueForKey:@"token"]]];
    [applePayClient tokenizeApplePayPayment:payment
                                 completion:^(BTApplePayCardNonce *tokenizedApplePayPayment,
                                              NSError *error) {
                                     if(error){
                                         [currentVC showAlertWithTitle:SCLocalizedString(@"Apple Pay") message:SCLocalizedString(error.localizedDescription)];
                                         completion(PKPaymentAuthorizationStatusFailure);
                                     }else{
                                         if (tokenizedApplePayPayment.nonce) {
                                             [self postNonceToServer:tokenizedApplePayPayment.nonce];
                                             applePayCompleted = YES;
                                         } else {
                                             [currentVC showAlertWithTitle:SCLocalizedString(@"Apple Pay") message:[NSString stringWithFormat:@"Authorization Fail"]];
                                         }
                                         completion(PKPaymentAuthorizationStatusSuccess);
                                     }
                                 }];
}


// Be sure to implement -paymentAuthorizationViewControllerDidFinish:
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
    if(!applePayCompleted){
        [self showDropIn:[selectedPayment objectForKey:@"token"]];
    }
}
-(void) paymentAuthorizationViewControllerWillAuthorizePayment:(PKPaymentAuthorizationViewController *)controller{
    
}

- (void)postNonceToServer:(NSString *)paymentMethodNonce {
    if(!braintreeModel)
        braintreeModel = [SimiBraintreeModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSendNonceToServer:) name:BRAINTREE_SENDNONCETOSERVER object:braintreeModel];
    [currentVC startLoadingData];
    [braintreeModel sendNonceToServer:paymentMethodNonce andOrder:order];
}

- (void)didSendNonceToServer:(NSNotification *)noti{
    SimiResponder* responder = [noti.userInfo valueForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]){
        if([noti.name isEqualToString:BRAINTREE_SENDNONCETOSERVER]){
            SCThankYouPageViewController* thankyouPage = [SCThankYouPageViewController new];
            thankyouPage.order = order;
            [[SimiGlobalVar sharedInstance].currentlyNavigationController popToRootViewControllerAnimated:NO];
            if(PHONEDEVICE){
                [[SimiGlobalVar sharedInstance].currentlyNavigationController pushViewController:thankyouPage animated:YES];
            }else{
                UINavigationController* navi = [[UINavigationController alloc] initWithRootViewController:thankyouPage];
                navi.modalPresentationStyle = UIModalPresentationPopover;
                UIPopoverPresentationController* popoverVC = navi.popoverPresentationController;
                popoverVC.sourceView = [SimiGlobalVar sharedInstance].currentlyNavigationController.view;
                popoverVC.sourceRect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
                [popoverVC setPermittedArrowDirections:0];
                [[SimiGlobalVar sharedInstance].currentlyNavigationController presentViewController:navi animated:YES completion:nil];
            }
        }
    }else{
        [currentVC showAlertWithTitle:SCLocalizedString(@"") message:responder.responseMessage];
        [currentVC.navigationController popToRootViewControllerAnimated:YES];
    }
    [self removeObserverForNotification:noti];
}

#pragma mark - BTViewControllerPresentingDelegate
// Required
- (void)paymentDriver:(id)paymentDriver requestsPresentationOfViewController:(UIViewController *)viewController {
}

// Required
- (void)paymentDriver:(id)paymentDriver requestsDismissalOfViewController:(UIViewController *)viewController {
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
    [currentVC startLoadingData];
}

- (void)hideLoadingUI:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [currentVC stopLoadingData];
}

#pragma mark BTDropInViewControllerDelegate
- (void)dropInViewController:(BTDropInViewController *)viewController didSucceedWithTokenization:(BTPaymentMethodNonce *)paymentMethodNonce{
    if(paymentMethodNonce.nonce){
        [self postNonceToServer:paymentMethodNonce.nonce];
    }
}

- (void)dropInViewControllerDidCancel:(BTDropInViewController *)viewController{
    NSLog(@"DIDCANCEL");
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewControllerDidLoad:(BTDropInViewController *)viewController{
    
}
- (void)dropInViewControllerWillComplete:(BTDropInViewController *)viewController{
    
}
@end
