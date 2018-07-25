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

@implementation PayUIndiaViewController{
    UIWebView* payUIndianWebView;
}

- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    self.navigationItem.title = SCLocalizedString(@"PayU Indian");
}

- (void)viewWillAppearBefore:(BOOL)animated{
    
}

- (void)viewDidAppearBefore:(BOOL)animated{
    [super viewDidAppearBefore:animated];
    if (payUIndianWebView == nil) {
        payUIndianWebView = [[UIWebView alloc]initWithFrame:self.view.bounds];
        payUIndianWebView.delegate = self;
        NSURL *url = [[NSURL alloc]initWithString:[self.order.urlAction stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
        [payUIndianWebView loadRequest:request];
        [self.view addSubview:payUIndianWebView];
        [self startLoadingData];
    }
}

#pragma mark UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *stringRequest = [NSString stringWithFormat:@"%@",request];
    if ([stringRequest containsString:@"_payment_options"]) {
        [self stopLoadingData];
    }
    if ([stringRequest containsString:@"simipayuindia/api/success/"]) {
        [self showAlertWithTitle:@"SUCCESS" message:@"Thank your for purchase" completionHandler:^{
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
    }else if ([stringRequest containsString:@"simipayuindia/api/failure/"])
    {
        [self showAlertWithTitle:@"Error" message:@"Have some errors, please try again" completionHandler:^{
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
    }else if([stringRequest containsString:@"simipayuindia/api/canceled/"])
    {
        [self showAlertWithTitle:@"FAIL" message:@"Your order has been canceled" completionHandler:^{
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
    }else if([stringRequest containsString:@"checkout/cart/"])
    {
        [self showAlertWithTitle:@"Error" message:@"Have some errors, please try again" completionHandler:^{
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
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
