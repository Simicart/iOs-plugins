//
//  KlarnaViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "KlarnaViewController.h"

@interface KlarnaViewController ()
@end

@implementation KlarnaViewController

-(void)viewDidLoadBefore
{
    self.edgesForExtendedLayout = UIRectEdgeBottom;
}

- (void)viewDidAppear:(BOOL)animated
{
    _klarnaModelCollection = [[KlarnaModelCollection alloc]init];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetKlarnaParam" object:_klarnaModelCollection];
    
    _webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    [self startLoadingData];
    [_klarnaModelCollection getParamsKlarnaWithParams:@{}];
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"DidGetKlarnaParam"]) {
        NSString *stringParams = @"[";
        for (int i = 0; i < _klarnaModelCollection.count; i++) {
            SimiModel *model = [_klarnaModelCollection objectAtIndex:i];
            NSData *data = [NSJSONSerialization dataWithJSONObject:model options:0 error:nil];
            NSString *string = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
            if (i < (_klarnaModelCollection.count -1)) {
                stringParams = [NSString stringWithFormat:@"%@%@,", stringParams, string];
            }else
                stringParams = [NSString stringWithFormat:@"%@%@]", stringParams, string];
        }
        NSString *stringURL = [NSString stringWithFormat:@"%@simiklarna/api/checkout/data/%@",kBaseURL,[stringParams stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[[NSURL alloc]initWithString:stringURL]];
        [_webView loadRequest:request];
    }else if ([noti.name isEqualToString:@"DidCheckOutKlarna"])
    {
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"SUCCESS") message:SCLocalizedString(@"Thank your for purchase") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[SCLocalizedString(@"Error") uppercaseString] message:SCLocalizedString(@"Have some errors, please try again") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

#pragma Webview Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *stringRequest = [NSString stringWithFormat:@"%@",request];
    NSLog(@"%@",stringRequest);
    if ([stringRequest containsString:@"checkout/cart"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"FAIL") message:SCLocalizedString(@"Your order has been canceled") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return NO;
    }else if([stringRequest containsString:@"/simiklarna/api/success"])
    {
        NSError *error;
        NSString *klarnaContent = [NSString stringWithContentsOfURL:[request URL]
                                                        encoding:NSASCIIStringEncoding
                                                           error:&error];
        NSData *data = [klarnaContent dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dictKlarnaContent = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if ([[dictKlarnaContent valueForKey:@"status"] isEqualToString:@"SUCCESS"]) {
            NSDictionary *params = [dictKlarnaContent valueForKey:@"data"];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotification:) name:@"DidCheckOutKlarna"object:_klarnaModelCollection];
            [_klarnaModelCollection checkoutKlarnaWithParams:params];
            return NO;
        }else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"FAIL") message:SCLocalizedString(@"Your order has been canceled") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
            [self.navigationController popToRootViewControllerAnimated:YES];
            return NO;
        }
    }else if ([stringRequest containsString:@"fullscreen_overlay"])
    {
        [self stopLoadingData];
    }
    return  YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

#pragma mark dealoc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
