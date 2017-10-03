//
//  SimiIpayViewController.m
//  SimiCartPluginFW
//
//  Created by KingRetina on 2/8/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiIpayViewController.h"
#import "SimiOrderModel+Ipay.h"
#import <SimiCartBundle/UIImage+SimiCustom.h>

@interface SimiIpayViewController ()

@end

@implementation SimiIpayViewController

@synthesize paymentsdk, payment, order;

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
    [self setToSimiView];
    self.navigationItem.title = SCLocalizedString(@"Ipay88");
    paymentsdk = [[Ipay alloc] init];
    paymentsdk.delegate = self;
    IpayPayment *ipay = [[IpayPayment alloc] init];
    [ipay setPaymentId:@"2"];
    [ipay setMerchantKey:[payment valueForKey:@"merchant_key"]];
    [ipay setMerchantCode:[payment valueForKey:@"merchant_code"]];
    [ipay setRefNo:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]];
    [ipay setCurrency:[order valueForKey:@"currency_code"]];
    [ipay setProdDesc:[order valueForKey:@"product_des"]];
    [ipay setUserName:[order valueForKey:@"name"]];
    [ipay setUserEmail:[order valueForKey:@"email"]];
    [ipay setUserContact:[order valueForKey:@"contact"]];
    [ipay setRemark:@"Success"];
    [ipay setLang:@"UTF-8"];
    [ipay setCountry:[order valueForKey:@"country_id"]];
    [ipay setAmount:[order valueForKey:@"amount"]];
    [ipay setBackendPostURL:@"https://www.mobile88.com/epayment/report/testsignature_response.asp"];
    if([[payment valueForKey:@"is_sandbox"] isEqualToString:@"1"]){
        [ipay setAmount:@"1.00"];
        [ipay setCurrency:@"MYR"];
        [ipay setCountry:@"MY"];
    }
    
    UIView *paymentView = [paymentsdk checkout:ipay];
    [self.view addSubview:paymentView];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:SCLocalizedString(@"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPayment:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
}

- (void)cancelPayment:(UIButton*)sender
{
    [self cancelIpayCheckoutPayment:[NSString stringWithFormat:@"%@",[order valueForKey:@"invoice_number"]]];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    
}

- (void)didUpdatePayment:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [self showAlertWithTitle:responder.status message:@"Thank you for your purchase"];
    }else{
        [self showAlertWithTitle:responder.status message:responder.responseMessage];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateIpayCheckoutPayment: (NSMutableDictionary *) params
{
    SimiOrderModel *ipayCheckoutModel = [[SimiOrderModel alloc]init];
    [ipayCheckoutModel updateIpayOrderWithParams:params];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdatePayment:) name:@"DidUpdateIpayPayment" object:ipayCheckoutModel];
    [self startLoadingData];
}

- (void)cancelIpayCheckoutPayment: (NSString *)orderID
{
    SimiOrderModel *ipayCheckoutModel = [[SimiOrderModel alloc]init];
    [ipayCheckoutModel cancelOrderWithId:orderID];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCancelPayment:) name:Simi_DidCancelOrder object:ipayCheckoutModel];
    [self startLoadingData];
}

- (void)didCancelPayment:(NSNotification *)noti{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    [self showAlertWithTitle:@"FAIL" message:@"Your order has been canceled"];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentSuccess:(NSString *)refNo withTransId:(NSString *)transId withAmount:(NSString *)amount withRemark:(NSString *)remark withAuthCode:(NSString *)authCode{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:transId forKey:@"transaction_id"];
    [params setValue:authCode forKey:@"auth_code"];
    [params setValue:[order valueForKey:@"invoice_number"] forKey:@"ref_no"];
    [params setValue:[order valueForKey:@"invoice_number"] forKey:@"order_id"];
    [params setValue:@"processing" forKey:@"status"];
    [self updateIpayCheckoutPayment:params];
}

- (void)paymentFailed:(NSString *)refNo withTransId:(NSString *)transId withAmount:(NSString *)amount withRemark:(NSString *)remark withErrDesc:(NSString *)errDesc{
    [self cancelIpayCheckoutPayment:[NSString stringWithFormat:@"%@",[order valueForKey:@"invoice_number"]]];
}

- (void)paymentCancelled:(NSString *)refNo withTransId:(NSString *)transId withAmount:(NSString *)amount withRemark:(NSString *)remark withErrDesc:(NSString *)errDesc{
    [self cancelIpayCheckoutPayment:[NSString stringWithFormat:@"%@",[order valueForKey:@"invoice_number"]]];
}

- (void)requerySuccess:(NSString *)refNo withMerchantCode:(NSString *)merchantCode withAmount:(NSString *)amount withResult:(NSString *)result{

}

- (void)requeryFailed:(NSString *)refNo withMerchantCode:(NSString *)merchantCode withAmount:(NSString *)amount withErrDesc:(NSString *)errDesc{

}


@end
