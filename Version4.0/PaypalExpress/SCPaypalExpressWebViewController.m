//
//  SCPaypalExpressWebViewController.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/19/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SCPaypalExpressWebViewController.h"
#import "SCPaypalExpressModel.h"

#define TASK_BAR_HEIGH 0

@interface SCPaypalExpressWebViewController ()

@end

@implementation SCPaypalExpressWebViewController
{
    SCPaypalExpressModel * paypalModel;
}

@synthesize paypalExpCheckOutWebView;

- (void)viewWillAppearBefore:(BOOL)animated
{
    
}

- (void)viewDidLoadBefore
{
    [self paypalStart];
    self.needReviewAddress = YES;
    
    self.title = SCLocalizedString(@"Paypal Checkout");
    [self.view setBackgroundColor:[UIColor whiteColor]];
    paypalExpCheckOutWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height - TASK_BAR_HEIGH)];
    paypalExpCheckOutWebView.delegate = self;
    [paypalExpCheckOutWebView setBackgroundColor:[UIColor whiteColor]];
    [paypalExpCheckOutWebView setContentMode:UIViewContentModeScaleAspectFill];
    paypalExpCheckOutWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin ;
    [self.view addSubview:paypalExpCheckOutWebView];
    [self startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeCheckOut:) name:@"DidCompleteCheckOutWithPaypalExpress" object:nil];
}

- (void)completeCheckOut:(NSNotification*)noti
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)paypalStart
{
    if (paypalModel == nil) {
        paypalModel = [[SCPaypalExpressModel alloc] init];
    }
    [paypalModel startPaypalExpress];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartPaypalExpress:) name:@"DidStartPaypalExpress" object:nil];
    
}

- (void)didStartPaypalExpress: (NSNotification *)noti
{
    [self removeObserverForNotification:noti];

    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        self.needReviewAddress = [(NSNumber *)[paypalModel objectForKey:@"review_address"] boolValue];
        NSURL * url = [NSURL URLWithString:(NSString *)[paypalModel objectForKey:@"url"]];
        NSURLRequest * requestObj = [NSURLRequest requestWithURL:url];
        [paypalExpCheckOutWebView loadRequest:requestObj];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
        UIAlertView * warning = [[UIAlertView alloc]initWithTitle:@"" message:[responder responseMessage] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [warning show];
    }
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlRequest = request.URL.absoluteString;
    if ((!([urlRequest rangeOfString:@"simiconnector/rest/v2/ppexpressapis/return"].location == NSNotFound))){
        if (self.needReviewAddress) {
            SCPaypalExpressAddressReviewViewController *addressReviewViewController = [SCPaypalExpressAddressReviewViewController new];
            UINavigationController *naviPresent = [[UINavigationController alloc]initWithRootViewController:addressReviewViewController];
            if (PHONEDEVICE) {
                [self presentViewController:naviPresent animated:YES completion:nil];
            }else
            {
                naviPresent.modalPresentationStyle = UIModalPresentationFormSheet;
                [self presentViewController:naviPresent animated:YES completion:nil];
            }
        }
        else{
            SCPaypalExpressShippingMethodViewController *shippingMethodViewController = [[SCPaypalExpressShippingMethodViewController alloc]init];
            UINavigationController *naviPresent = [[UINavigationController alloc]initWithRootViewController:shippingMethodViewController];
            if (PHONEDEVICE) {
                [self presentViewController:naviPresent animated:YES completion:nil];
            }else
            {
                naviPresent.modalPresentationStyle = UIModalPresentationFormSheet;
                [self presentViewController:naviPresent animated:YES completion:nil];
            }
        }
        return NO;
    }
    if (!([urlRequest rangeOfString:@"cancel"].location == NSNotFound)) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self startLoadingData];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self stopLoadingData];
}
@end
