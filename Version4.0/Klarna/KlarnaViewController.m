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
    [super viewDidLoadBefore];
    self.navigationItem.title = SCLocalizedString(@"Klarna");
}

- (void)viewDidAppearBefore:(BOOL)animated
{
    _klarnaModel = [KlarnaModel new];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetKlarnaParam" object:_klarnaModel];
    
    _webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    [self startLoadingData];
    [_klarnaModel getParamsKlarnaWithParams:@{}];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"DidGetKlarnaParam"]) {
        NSString *stringParams = @"{%22simiklarnaapi%22:[";
        NSArray *dataParams = [_klarnaModel valueForKey:@"params"];
        for (int i = 0; i < dataParams.count; i++) {
            SimiModel *model = [dataParams objectAtIndex:i];
            NSData *data = [NSJSONSerialization dataWithJSONObject:model options:0 error:nil];
            NSString *string = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
            if (i < (dataParams.count -1)) {
                stringParams = [NSString stringWithFormat:@"%@%@,", stringParams, string];
            }else
                stringParams = [NSString stringWithFormat:@"%@%@]}", stringParams, string];
        }
        NSString *stringURL = [NSString stringWithFormat:@"%@simiklarna/api/checkout/data/%@",kBaseURL,[stringParams stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[[NSURL alloc]initWithString:stringURL]];
        [_webView loadRequest:request];
    }else if ([noti.name isEqualToString:@"DidCheckOutKlarna"])
    {
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            [self showAlertWithTitle:@"SUCCESS" message:@"Thank your for purchase"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else
        {
            [self showAlertWithTitle:@"Error" message:@"Have some errors, please try again"];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma Webview Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *stringRequest = [NSString stringWithFormat:@"%@",request];
    NSLog(@"%@",stringRequest);
    if ([stringRequest containsString:@"checkout/cart"]) {
        [self showAlertWithTitle:@"FAIL" message:@"Your order has been canceled"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }else if([stringRequest containsString:@"simiklarnaapis/success/"])
    {
        NSError *error;
        NSString *klarnaContent = [NSString stringWithContentsOfURL:[request URL]
                                                        encoding:NSASCIIStringEncoding
                                                           error:&error];
        NSData *data = [klarnaContent dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dictKlarnaContent = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if ([[dictKlarnaContent valueForKey:@"simiklarnaapi"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *params = [dictKlarnaContent valueForKey:@"simiklarnaapi"];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotification:) name:@"DidCheckOutKlarna"object:_klarnaModel];
            [_klarnaModel checkoutKlarnaWithParams:params];
            return NO;
        }else
        {
            [self showAlertWithTitle:@"FAIL" message:@"Your order has been canceled"];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            return NO;
        }
    }else if ([stringRequest containsString:@"fullscreen.html"])
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
