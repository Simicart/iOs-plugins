//
//  SimiAvenueWebView.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/3/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiAvenueWebView.h"
#import "SimiOrderModel+Avenue.h"
#import <SimiCartBundle/UIImage+SimiCustom.h>

#define BACK_ITEM 123
#define SPACE_ITEM 134

@interface SimiAvenueWebView ()

@end

@implementation SimiAvenueWebView

@synthesize webTitle, urlPath, content;

- (void)viewDidLoadBefore
{
    [super viewDidLoadBefore];
}

- (void)viewDidLoadAfter
{
    [self setToSimiView];
    self.navigationItem.title = SCLocalizedString(@"CCAvenue");
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
        
        if (!content) {
            _webView.delegate = self;
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
            [request addValue:@"YES" forHTTPHeaderField:@"Mobile-App"];
            [_webView loadRequest:request];
        }else{
            [_webView loadHTMLString:content baseURL:nil];
        }
    }
}


- (void)setUrlPath:(NSString *)path{
    if (![urlPath isEqualToString:path]) {
        urlPath = [path copy];
        if (([urlPath rangeOfString:@"http://"].location == NSNotFound) && ([urlPath rangeOfString:@"https://"].location == NSNotFound)) {
            urlPath = [NSString stringWithFormat:@"http://%@", urlPath];
        }
        url = [NSURL URLWithString:urlPath];
    }
}

- (void)setWebTitle:(NSString *)title{
    if (![webTitle isEqualToString:title]) {
        webTitle = [title copy];
        self.title = webTitle;
    }
}

#pragma mark WebView Delegates
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self startLoadingData];
    webView.hidden = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopLoadingData];
    webView.hidden = NO;
    if (webTitle == nil || webTitle.length == 0) {
        [self setWebTitle:[webView stringByEvaluatingJavaScriptFromString:@"document.title"]];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestURL = [NSString stringWithFormat:@"%@",request];
    NSLog(@"%@", requestURL);
    if([requestURL rangeOfString:@"success"].location != NSNotFound || ([requestURL rangeOfString:@"TransactionNo"].location != NSNotFound && [requestURL rangeOfString:@"AuthorizeId"].location != NSNotFound)){
        [self showAlertWithTitle:@"SUCCESS" message:@"Thank your for purchase"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }else if([requestURL rangeOfString:@"failure"].location != NSNotFound){
        [self showAlertWithTitle:@"FAIL" message:@"Your order has been canceled"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }else if([requestURL rangeOfString:@"review"].location != NSNotFound){
        [self showAlertWithTitle:@"SUCCESS" message:@"Your order is under review"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }else if([requestURL rangeOfString:@"simiavenue/api/index"].location != NSNotFound || [requestURL rangeOfString:@"transaction.do;jsessionid"].location != NSNotFound){
        [self showAlertWithTitle:@"ERROR" message:@"Have some errors, please try again"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
    return YES;
}


@end
