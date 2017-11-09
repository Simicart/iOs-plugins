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
    if(self.webTitle){
        self.navigationItem.title = self.webTitle;
    }
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
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Confirmation" message:[NSString stringWithFormat:@"%@?",SCLocalizedString(@"Are you sure that you want to cancel the order")] preferredStyle:UIAlertControllerStyleAlert];
    [alertView addAction:[UIAlertAction actionWithTitle:SCLocalizedString(@"No") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
                                    
    [alertView addAction:[UIAlertAction actionWithTitle:SCLocalizedString(@"Yes") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        SimiOrderModel *orderModel = [SimiOrderModel new];
        [orderModel cancelOrderWithId:_orderID];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCancelOrder:) name:@"DidCancelOrder" object:orderModel];
        [self startLoadingData];
    }]];
    [self presentViewController:alertView animated:YES completion:nil];
}

- (void)setUrlPath:(NSString *)path{
    if (![_urlPath isEqualToString:path]) {
        _urlPath = [path copy];
        if (([_urlPath rangeOfString:@"http://"].location == NSNotFound) && ([_urlPath rangeOfString:@"https://"].location == NSNotFound)) {
            _urlPath = [NSString stringWithFormat:@"http://%@", _urlPath];
        }
    }
}

#pragma mark WebView Delegates
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self startLoadingData];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopLoadingData];
    if([webView stringByEvaluatingJavaScriptFromString:@"document.title"]){
        [self setWebTitle:[webView stringByEvaluatingJavaScriptFromString:@"document.title"]];
    }
    [SimiGlobalVar clearAllCookies];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* requestURL = [NSString stringWithFormat:@"%@",request];
    if(_payment){
        if([requestURL rangeOfString:[_payment valueForKey:@"url_success"] ].location != NSNotFound){
            [self showAlertWithTitle:@"" message:[_payment valueForKey:@"message_success"] completionHandler:^{
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }];
            return NO;
        }else if([requestURL rangeOfString:[_payment valueForKey:@"url_fail"]].location != NSNotFound){
            [self showAlertWithTitle:@"" message:[_payment valueForKey:@"message_fail"] completionHandler:^{
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }];
            return NO;
        }else if([requestURL rangeOfString:[_payment valueForKey:@"url_cancel"]].location != NSNotFound){
            [self showAlertWithTitle:@"" message:[_payment valueForKey:@"message_cancel"] completionHandler:^{
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }];
            return NO;
        }else if([requestURL rangeOfString:[_payment valueForKey:@"url_error"]].location != NSNotFound){
            [self showAlertWithTitle:@"" message:[_payment valueForKey:@"message_error"] completionHandler:^{
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }];
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
        [((SimiViewController *)[SimiGlobalVar sharedInstance].currentViewController) showToastMessage:@"Your order is cancelled"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else {
        [self showAlertWithTitle:@"" message:responder.responseMessage completionHandler:^{
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}
@end
