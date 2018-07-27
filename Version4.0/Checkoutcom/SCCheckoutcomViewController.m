//
//  SCCheckoutcomViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 11/10/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCCheckoutcomViewController.h"

@interface SCCheckoutcomViewController ()

@end

@implementation SCCheckoutcomViewController{
    UIWebView* checkoutWebView;
    CheckoutcomModel* checkoutcomModel;
}
- (void)viewDidLoadBefore {
    [super viewDidLoadBefore];
    checkoutWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:checkoutWebView];
    checkoutWebView.delegate = self;
    NSString* actionURL = [[self.order objectForKey:@"redirect_url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [checkoutWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:actionURL]]];
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString* url = [request.URL absoluteString];
    if([url containsString:[self.order objectForKey:@"success_url"]]){
        if(!checkoutcomModel){
            checkoutcomModel = [CheckoutcomModel new];
        }
        [checkoutcomModel completeOrderWithParams:@{@"invoice_number":[self.order objectForKey:@"invoice_number"]}];
        [self startLoadingData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCompleteOrder:) name:CheckoutCom_DidUpdateCheckoutComPayment object:nil];
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self startLoadingData];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopLoadingData];
}

- (void)didCompleteOrder:(NSNotification*) noti{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    SimiResponder* responder = [noti.userInfo objectForKey:responderKey];
    if (responder.status == SUCCESS) {
        [self showAlertWithTitle:@"" message:[NSString stringWithFormat:@"%@!",SCLocalizedString(@"Thank you for your purchase")] completionHandler:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

@end
