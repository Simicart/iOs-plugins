//
//  SCCheckoutcomViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 11/10/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCCheckoutcomViewController.h"

@interface SCCheckoutcomViewController ()

@end

@implementation SCCheckoutcomViewController
{
    UIWebView* checkoutWebView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    checkoutWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:checkoutWebView];
    checkoutWebView.delegate = self;
    NSString* actionURL = [[self.order objectForKey:@"redirect_url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [checkoutWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:actionURL]]];
    self.navigationItem.title = SCLocalizedString(@"Checkout.com");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UIWebViewDelegate
-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString* url = [request.URL absoluteString];
    if([url containsString:[self.order objectForKey:@"success_url"]]){
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

-(void) webViewDidStartLoad:(UIWebView *)webView{
    [self startLoadingData];
}

-(void) webViewDidFinishLoad:(UIWebView *)webView{
    [self stopLoadingData];
}

@end
