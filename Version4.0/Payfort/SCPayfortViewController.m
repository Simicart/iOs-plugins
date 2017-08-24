//
//  SCPayfortViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 7/24/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCPayfortViewController.h"
#import "SCPayfortModel.h"
#import <SimiCartBundle/SCThankYouPageViewController.h>
#import <SimiCartBundle/SimiOrderModel.h>

@interface SCPayfortViewController ()

@end

@implementation SCPayfortViewController {
    UIWebView *payfortWebView;
    SimiModel *originalOrder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    payfortWebView = [[UIWebView alloc] init];
    payfortWebView.delegate = self;
    [self.view addSubview:payfortWebView];
    originalOrder = [self.order copy];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    payfortWebView.frame = self.view.bounds;
    [payfortWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self.order objectForKey:@"redirect_url"]]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString* url = [request.URL absoluteString];
    NSLog(@"URL: %@,SUCCESS_URL: %@",url,[self.order objectForKey:@"success_url"]);
    if([url containsString:[self.order objectForKey:@"success_url"]]){
        SCPayfortModel *payfortModel = [SCPayfortModel new];
        [payfortModel updateOrderWithInvoiceNumber:[self.order objectForKey:@"invoice_number"]];
        [self startLoadingData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdatePayfortPayment:) name:DidUpdatePayfortPayment object:nil];
        return NO;
    }
    return YES;
}

- (void)didUpdatePayfortPayment: (NSNotification *)noti {
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    [self dismissViewControllerAnimated:YES completion:nil];
    SimiResponder *responder = [noti.userInfo objectForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]) {
        [self.order addData:originalOrder];
        if (PHONEDEVICE) {
            SCThankYouPageViewController *thankVC = [[SCThankYouPageViewController alloc] init];
            thankVC.order = [[SimiOrderModel alloc] initWithDictionary:originalOrder];
            [[SimiGlobalVar sharedInstance].currentlyNavigationController pushViewController:thankVC animated:YES];
        }else {
            UINavigationController *currentlyNavigationController = [SimiGlobalVar sharedInstance].currentlyNavigationController;
            SCThankYouPageViewController *thankVC = [[SCThankYouPageViewController alloc] init];
            thankVC.order = [[SimiOrderModel alloc] initWithDictionary:originalOrder];
            UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:thankVC];
            navi.modalPresentationStyle = UIModalPresentationPopover;
            UIPopoverPresentationController *popover = navi.popoverPresentationController;
            popover.sourceRect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
            popover.sourceView = currentlyNavigationController.view;
            popover.permittedArrowDirections = 0;
            [currentlyNavigationController presentViewController:navi animated:YES completion:nil];
        }
    }else {
        [self showAlertWithTitle:@"" message:responder.responseMessage];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self startLoadingData];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self stopLoadingData];
}

@end
