//
//  SimiIpayViewController.m
//  SimiCartPluginFW
//
//  Created by KingRetina on 2/8/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiIpayViewController.h"
#import "SimiCartPadWorker.h"
#import "SimiOrderModel+Ipay.h"
#import <SimiCartBundle/UIImage+SimiCustom.h>

#define BACK_ITEM 123
#define SPACE_ITEM 134

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

- (void)viewWillAppearAfter:(BOOL)animated{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //        [super viewWillAppearAfter:animated];
        //Set logo
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.navigationItem.titleView = imageView;
        self.navigationItem.titleView.contentMode = UIViewContentModeCenter;
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [super viewDidDisappear:animated];
        self.navigationItem.rightBarButtonItems = nil;
        self.navigationItem.leftBarButtonItems = nil;
        if (([[[[[SimiCartPadWorker sharedInstance] navigationBarWorker] leftButtonItems] lastObject] tag] == BACK_ITEM) || ([[[[[SimiCartPadWorker sharedInstance] navigationBarWorker] leftButtonItems] lastObject] tag] == SPACE_ITEM)) {
            //Remove back item
            [[[[SimiCartPadWorker sharedInstance] navigationBarWorker] leftButtonItems] removeLastObject];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [super viewDidAppear:animated];
        [self.navigationController.view addSubview:[[[SimiCartPadWorker sharedInstance] navigationBarWorker] leftMenu]];
        
        if ((self != [self.navigationController.viewControllers objectAtIndex:0]) && (self.navigationController.viewControllers != NULL) ){
            backItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_back"] imageWithColor:THEME_COLOR] style:UIBarButtonItemStyleBordered target:self action:@selector(didSelectBackBarItem:)];
            backItem.tag = BACK_ITEM;
        }
        NSMutableArray *leftItems = [[[SimiCartPadWorker sharedInstance] navigationBarWorker] leftButtonItems];
        CGFloat width = 0;
        if (backItem) {
            [leftItems addObject:backItem];
            width += 32;
        }else{
            UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            space.width = 58;
            space.tag = SPACE_ITEM;
            width += space.width;
            [leftItems addObject:space];
        }
        self.navigationItem.rightBarButtonItems = [[[SimiCartPadWorker sharedInstance] navigationBarWorker] rightButtonItems];
        self.navigationItem.leftBarButtonItems = leftItems;
    }
}

- (void)didSelectBackBarItem:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [self setToSimiView];
    self.navigationItem.title = SCLocalizedString(self.navigationItem.title);
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
    [ipay setBackendPostURL:@"http://merchant.com/backend.php"];
    if([[payment valueForKey:@"is_sandbox"] isEqualToString:@"1"]){
        [ipay setAmount:@"1.00"];
        [ipay setCurrency:@"MYR"];
        [ipay setCountry:@"MY"];
    }
    UIView *paymentView = [paymentsdk checkout:ipay];
    [self.view addSubview:paymentView];
    [super viewDidLoad];
    [self setContentSizeForViewInPopover:CGSizeMake(3*SCREEN_WIDTH/4, 3*SCREEN_HEIGHT/4)];
}

- (void)didUpdatePayment:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:SCLocalizedString(@"Thank you for your purchase") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
}

- (void)updateIpayCheckoutPayment: (NSMutableDictionary *) params
{
    SimiOrderModel *ipayCheckoutModel = [[SimiOrderModel alloc]init];
    [ipayCheckoutModel updateIpayOrderWithParams:params];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdatePayment:) name:@"DidUpdateIpayPayment" object:ipayCheckoutModel];
    [self startLoadingData];
}

- (void)cancelIpayCheckoutPayment: (NSMutableDictionary *) params
{
    SimiOrderModel *ipayCheckoutModel = [[SimiOrderModel alloc]init];
    [ipayCheckoutModel updateIpayOrderWithParams:params];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCancelPayment:) name:@"DidUpdateIpayPayment" object:ipayCheckoutModel];
    [self startLoadingData];
}

- (void)didCancelPayment:(NSNotification *)noti{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"FAIL") message:SCLocalizedString(@"Your order has been canceled") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
    [alertView show];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
}

- (void)paymentSuccess:(NSString *)refNo withTransId:(NSString *)transId withAmount:(NSString *)amount withRemark:(NSString *)remark withAuthCode:(NSString *)authCode{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:transId forKey:@"transaction_id"];
    [params setValue:authCode forKey:@"auth_code"];
    [params setValue:[order valueForKey:@"invoice_number"] forKey:@"ref_no"];
    [params setValue:[order valueForKey:@"invoice_number"] forKey:@"order_id"];
    [params setValue:@"1" forKey:@"status"];
    [self updateIpayCheckoutPayment:params];
}

- (void)paymentFailed:(NSString *)refNo withTransId:(NSString *)transId withAmount:(NSString *)amount withRemark:(NSString *)remark withErrDesc:(NSString *)errDesc{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"FAIL") message:SCLocalizedString(@"Your order has been canceled") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
//    [alertView show];
//    NSLog(@"%@", errDesc);
//    [self.navigationController popToRootViewControllerAnimated:YES];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:transId forKey:@"transaction_id"];
    [params setValue:errDesc forKey:@"auth_code"];
    [params setValue:[order valueForKey:@"invoice_number"] forKey:@"ref_no"];
    [params setValue:[order valueForKey:@"invoice_number"] forKey:@"order_id"];
    [params setValue:@"2" forKey:@"status"];
    [self cancelIpayCheckoutPayment:params];
}

- (void)paymentCancelled:(NSString *)refNo withTransId:(NSString *)transId withAmount:(NSString *)amount withRemark:(NSString *)remark withErrDesc:(NSString *)errDesc{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"FAIL") message:SCLocalizedString(@"Your order has been canceled") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
//    [alertView show];
//    [self.navigationController popToRootViewControllerAnimated:YES];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:transId forKey:@"transaction_id"];
    [params setValue:errDesc forKey:@"auth_code"];
    [params setValue:[order valueForKey:@"invoice_number"] forKey:@"ref_no"];
    [params setValue:[order valueForKey:@"invoice_number"] forKey:@"order_id"];
    [params setValue:@"2" forKey:@"status"];
    [self cancelIpayCheckoutPayment:params];
}

- (void)requerySuccess:(NSString *)refNo withMerchantCode:(NSString *)merchantCode withAmount:(NSString *)amount withResult:(NSString *)result{

}

- (void)requeryFailed:(NSString *)refNo withMerchantCode:(NSString *)merchantCode withAmount:(NSString *)amount withErrDesc:(NSString *)errDesc{

}


@end
