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
    CheckoutcomModel* checkoutcomModel;
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
        if(!checkoutcomModel){
            checkoutcomModel = [CheckoutcomModel new];
        }
        [checkoutcomModel completeOrderWithParams:@{@"invoice_number":[self.order objectForKey:@"invoice_number"]}];
        [self startLoadingData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCompleteOrder:) name:DidUpdateCheckoutComPayment object:nil];
        return NO;
    }
    return YES;
}

-(void) webViewDidStartLoad:(UIWebView *)webView{
    [self startLoadingData];
}

-(void) webViewDidFinishLoad:(UIWebView *)webView{
    [self stopLoadingData];
}

-(void) didCompleteOrder:(NSNotification*) noti{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    SimiResponder* responder = [noti.userInfo objectForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]){
        [self showAlertWithTitle:@"" message:@"Thank you for your purchase" completionHandler:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }else{
        [self showAlertWithTitle:@"" message:responder.responseMessage completionHandler:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

@end
