//
//  SimiAvenueWebView.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/3/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiPaymentWebView.h"

@interface SimiPaymentWebView ()
@end

@implementation SimiPaymentWebView
{
    NSURLRequest* failedRequest;
    UIActivityIndicatorView* simiLoading;
}

- (void)viewDidLoadBefore
{
    self.navigationItem.title = SCLocalizedString(self.navigationItem.title);
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPayment:)];
    self.navigationItem.rightBarButtonItem = cancel;
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    
}

- (void)viewDidAppearBefore:(BOOL)animated
{
    if (_webView == nil) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.scalesPageToFit = YES;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_webView];
        _webView.delegate = self;
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:_urlPath]];
        [_webView loadRequest:request];
    }
}


-(void) cancelPayment:(id) sender{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Confirmation") message:[NSString stringWithFormat:@"%@?",SCLocalizedString(@"Are you sure that you want to cancel the order")] delegate:self cancelButtonTitle:SCLocalizedString(@"Close") otherButtonTitles:SCLocalizedString(@"OK"), nil];
    [alertView show];
    alertView.simiObjectName = @"cancelOrderAlert";
}

- (void)setUrlPath:(NSString *)path{
    if (![_urlPath isEqualToString:path]) {
        _urlPath = [path copy];
        if (([_urlPath rangeOfString:@"http://"].location == NSNotFound) && ([_urlPath rangeOfString:@"https://"].location == NSNotFound)) {
            _urlPath = [NSString stringWithFormat:@"http://%@", _urlPath];
        }
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if([alertView.simiObjectName isEqualToString:@"cancelOrderAlert"]){
        if(buttonIndex == 0){
            
        }else if(buttonIndex == 1){
            SimiOrderModel *orderModel = [SimiOrderModel new];
            [orderModel cancelOrderWithId:_orderID];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCancelOrder:) name:@"DidCancelOrder" object:orderModel];
            [self startLoadingData];
        }
    }
}


#pragma mark WebView Delegates
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self startLoadingData];
    webView.hidden = YES;
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopLoadingData];
    webView.hidden = NO;
    if (_webTitle == nil || _webTitle.length == 0) {
        [self setWebTitle:[webView stringByEvaluatingJavaScriptFromString:@"document.title"]];
    }
    NSLog(@"webViewDidFinishLoad");
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* requestURL = [NSString stringWithFormat:@"%@",request];
    if(_payment){
        if([requestURL rangeOfString:[_payment valueForKey:@"url_success"] ].location != NSNotFound){
            [self showToastMessage:[_payment valueForKey:@"message_success"]];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            return NO;
        }else if([requestURL rangeOfString:[_payment valueForKey:@"url_fail"]].location != NSNotFound){
            [self showToastMessage:[_payment valueForKey:@"message_fail"]];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            return NO;
        }else if([requestURL rangeOfString:[_payment valueForKey:@"url_cancel"]].location != NSNotFound){
            [self showToastMessage:[_payment valueForKey:@"message_cancel"]];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            return NO;
        }else if([requestURL rangeOfString:[_payment valueForKey:@"url_error"]].location != NSNotFound){
            [self showToastMessage:[_payment valueForKey:@"message_error"]];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            return NO;
        }
    }
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"didFailLoadWithError: %@",error);
}

-(void) didCancelOrder:(NSNotification *)noti{
    [self removeObserverForNotification:noti];
    [self stopLoadingData];
    SimiResponder* responder = [noti.userInfo valueForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]){
        [self showToastMessage:@"Your order is cancelled"];
    }else{
        [self showAlertWithTitle:responder.status message:responder.responseMessage];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
