//
//  PayUViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/15/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "PayUViewController.h"

@interface PayUViewController ()

@end

@implementation PayUViewController

- (void)viewDidLoadBefore
{
    [super viewDidLoadBefore];
    self.navigationItem.title = SCLocalizedString(@"PayU");
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    
}

- (void)viewDidAppearBefore:(BOOL)animated
{
    if (_webView == nil) {
        _webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
        _webView.delegate = self;
        NSURL *url = [[NSURL alloc]initWithString:[self.stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
        [_webView loadRequest:request];
        [self.view addSubview:_webView];
        [self startLoadingData];
    }
}

#pragma mark UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *stringRequest = [NSString stringWithFormat:@"%@",request];
    NSLog(@"%@",stringRequest);
//    if ([stringRequest containsString:@"session_id"]) {
//        [self stopLoadingData];
//    }
    if ([stringRequest containsString:@"simipayu/index/success"]) {
        [self showAlertWithTitle:@"SUCCESS" message:@"Thank your for purchase" completionHandler:^{
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
        return NO;
    }else if ([stringRequest containsString:@"simipayu/index/failure"])
    {
        [self showAlertWithTitle:@"ERROR" message:@"Have some errors, please try again" completionHandler:^{
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
        return NO;
    }
    return  YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self startLoadingData];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopLoadingData];
}

@end
