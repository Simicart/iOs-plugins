//
//  SimiAvenueWebView.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/3/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiPaymentWebView.h"
#import <SimiCartBundle/SimiOrderModel.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>

#define BACK_ITEM 123
#define SPACE_ITEM 134

@interface SimiPaymentWebView ()

@end

@implementation SimiPaymentWebView


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoadAfter
{
    [self setToSimiView];
    self.navigationItem.title = SCLocalizedString(self.navigationItem.title);
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    _webView.scalesPageToFit = YES;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_webView];
    
    _webView.delegate = self;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:_urlPath]];
    [request addValue:@"YES" forHTTPHeaderField:@"Mobile-App"];
    [_webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    webView.hidden = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopLoadingData];
    webView.hidden = NO;
    if (_webTitle == nil || _webTitle.length == 0) {
        [self setWebTitle:[webView stringByEvaluatingJavaScriptFromString:@"document.title"]];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(_payment){
        NSString *requestURL = [NSString stringWithFormat:@"%@",request];
        if([requestURL rangeOfString:[_payment valueForKey:@"url_success"] ].location != NSNotFound){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"SUCCESS") message:SCLocalizedString([_payment valueForKey:@"message_success"]) delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
            [self.navigationController popToRootViewControllerAnimated:YES];
            return NO;
            
        }else if([requestURL rangeOfString:[_payment valueForKey:@"url_fail"]].location != NSNotFound){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"FAIL") message:SCLocalizedString([_payment valueForKey:@"message_fail"]) delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
            [self.navigationController popToRootViewControllerAnimated:YES];
            return NO;
        }else if([requestURL rangeOfString:[_payment valueForKey:@"url_cancel"]].location != NSNotFound){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Cancel") message:SCLocalizedString([_payment valueForKey:@"message_cancel"]) delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
            [self.navigationController popToRootViewControllerAnimated:YES];
            return NO;
        }else if([requestURL rangeOfString:[_payment valueForKey:@"url_error"]].location != NSNotFound){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString([_payment valueForKey:@"message_error"]) delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
            [self.navigationController popToRootViewControllerAnimated:YES];
            return NO;
        }
    }
    return YES;
}


@end
