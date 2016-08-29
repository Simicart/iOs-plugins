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

- (void)viewDidAppear:(BOOL)animated
{
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    _webView = [[UIWebView alloc]initWithFrame:CGRectInset(self.view.bounds, 0, 64)];
    _webView.delegate = self;
    NSURL *url = [[NSURL alloc]initWithString:[self.stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
    [self startLoadingData];
}

#pragma mark UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@",request);
    NSString *stringRequest = [NSString stringWithFormat:@"%@",request];
    if ([stringRequest containsString:@"session_id"]) {
        [self stopLoadingData];
    }
    if ([stringRequest containsString:@"simipayu/index/success"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"SUCCESS") message:SCLocalizedString(@"Thank your for purchase") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return NO;
    }else if ([stringRequest containsString:@"simipayu/index/failure"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[SCLocalizedString(@"Error") uppercaseString] message:SCLocalizedString(@"Have some errors, please try again") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return NO;
    }
    return  YES;
}
@end
