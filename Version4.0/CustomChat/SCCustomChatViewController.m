//
//  SCCustomChatViewController.m
//  SimiCartPluginFW
//
//  Created by MAC on 8/16/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCustomChatViewController.h"

@interface SCCustomChatViewController ()

@end

@implementation SCCustomChatViewController{
    UIWebView *webView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    NSString *urlString =[NSString stringWithFormat:@"%@%@", kBaseURL,@"simiconnector/customchat/index"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [webView loadRequest:urlRequest];
    [self.view addSubview:webView];
    webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [webView setFrame:self.view.bounds];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *url = [request URL];
    if ([[url absoluteString] isEqualToString:kBaseURL]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    return YES;
}

@end
