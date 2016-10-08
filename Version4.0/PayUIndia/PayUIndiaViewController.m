//
//  PayUIndiaViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/17/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "PayUIndiaViewController.h"

@interface PayUIndiaViewController ()

@end

@implementation PayUIndiaViewController

- (void)viewDidLoadBefore
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:SCLocalizedString(@"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPayment:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    self.navigationItem.title = SCLocalizedString(@"PayU Indian");
}

- (void)cancelPayment:(UIButton*)sender
{
    [self showAlertWithTitle:@"FAIL" message:@"Your order has been canceled"];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    if ([stringRequest containsString:@"_payment_options"]) {
        [self stopLoadingData];
    }
    if ([stringRequest containsString:@"simipayuindia/api/success/"]) {
        [self showAlertWithTitle:@"SUCCESS" message:@"Thank your for purchase"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }else if ([stringRequest containsString:@"simipayuindia/api/failure/"])
    {
        [self showAlertWithTitle:@"Error" message:@"Have some errors, please try again"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }else if([stringRequest containsString:@"simipayuindia/api/canceled/"])
    {
        [self showAlertWithTitle:@"FAIL" message:@"Your order has been canceled"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }else if([stringRequest containsString:@"checkout/cart/"])
    {
        [self showAlertWithTitle:@"Error" message:@"Have some errors, please try again"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
    return  YES;
}

@end
