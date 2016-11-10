//
//  SimiTwoCheckoutWebView.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/3/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiTwoCheckoutWebView.h"
#import "SimiOrderModel+TwoCheckout.h"

@interface SimiTwoCheckoutWebView ()

@end

@implementation SimiTwoCheckoutWebView

@synthesize webTitle, urlPath, content, urlCallBack, invoiceNumber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoadBefore
{
    [super viewDidLoadBefore];
    [self setToSimiView];
    self.navigationItem.title = SCLocalizedString(@"2Checkout");
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    
}

- (void)viewDidAppearBefore:(BOOL)animated
{
    if (_webView == nil) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.scalesPageToFit = NO;
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
    if([requestURL rangeOfString:@"jsessionid="].location != NSNotFound){
        NSArray *params = [requestURL componentsSeparatedByString:@"jsessionid="];
        NSString *orderNumber = params[1];
        [self updateTwoCheckoutPayment:orderNumber];
        return NO;
    }
    return YES;
}

- (void)updateTwoCheckoutPayment:(NSString *)orderNumber
{
    SimiOrderModel *twoCheckoutModel = [[SimiOrderModel alloc]init];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:orderNumber forKey:@"transaction_id"];
    [params setValue:invoiceNumber forKey:@"invoice_number"];
    [params setValue:@"1" forKey:@"payment_status"];
    [twoCheckoutModel updateTwoutOrderWithParams:params];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdatePayment:) name:@"DidUpdate2CheckoutPayment" object:twoCheckoutModel];
    [self startLoadingData];
}

- (void)didUpdatePayment:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    [self stopLoadingData];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:SCLocalizedString(@"Thank you for your purchase") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];

        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    [self removeObserverForNotification:noti];
}


@end
