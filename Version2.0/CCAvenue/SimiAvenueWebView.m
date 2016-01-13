//
//  SimiAvenueWebView.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/3/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiAvenueWebView.h"
#import "SimiOrderModel+Avenue.h"
#import "SimiCartPadWorker.h"
#import <SimiCartBundle/UIImage+SimiCustom.h>

#define BACK_ITEM 123
#define SPACE_ITEM 134

@interface SimiAvenueWebView ()

@end

@implementation SimiAvenueWebView

@synthesize webTitle, urlPath, content;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppearAfter:(BOOL)animated{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //        [super viewWillAppearAfter:animated];
        //Set logo
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.navigationItem.titleView = imageView;
        self.navigationItem.titleView.contentMode = UIViewContentModeCenter;
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [super viewDidDisappear:animated];
        self.navigationItem.rightBarButtonItems = nil;
        self.navigationItem.leftBarButtonItems = nil;
        if (([[[[[SimiCartPadWorker sharedInstance] navigationBarWorker] leftButtonItems] lastObject] tag] == BACK_ITEM) || ([[[[[SimiCartPadWorker sharedInstance] navigationBarWorker] leftButtonItems] lastObject] tag] == SPACE_ITEM)) {
            //Remove back item
            [[[[SimiCartPadWorker sharedInstance] navigationBarWorker] leftButtonItems] removeLastObject];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [super viewDidAppear:animated];
        [self.navigationController.view addSubview:[[[SimiCartPadWorker sharedInstance] navigationBarWorker] leftMenu]];
        
        if ((self != [self.navigationController.viewControllers objectAtIndex:0]) && (self.navigationController.viewControllers != NULL) ){
            backItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_back"] imageWithColor:THEME_COLOR] style:UIBarButtonItemStyleBordered target:self action:@selector(didSelectBackBarItem:)];
            backItem.tag = BACK_ITEM;
        }
        NSMutableArray *leftItems = [[[SimiCartPadWorker sharedInstance] navigationBarWorker] leftButtonItems];
        CGFloat width = 0;
        if (backItem) {
            [leftItems addObject:backItem];
            width += 32;
        }else{
            UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            space.width = 58;
            space.tag = SPACE_ITEM;
            width += space.width;
            [leftItems addObject:space];
        }
        self.navigationItem.rightBarButtonItems = [[[SimiCartPadWorker sharedInstance] navigationBarWorker] rightButtonItems];
        self.navigationItem.leftBarButtonItems = leftItems;
    }
}

- (void)didSelectBackBarItem:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [self setToSimiView];
    self.navigationItem.title = SCLocalizedString(self.navigationItem.title);
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
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
	
    [super viewDidLoad];
    [self setContentSizeForViewInPopover:CGSizeMake(3*SCREEN_WIDTH/4, 3*SCREEN_HEIGHT/4)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if([requestURL rangeOfString:@"onepage/success"].location != NSNotFound){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"SUCCESS") message:SCLocalizedString(@"Thank your for purchase") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return NO;
    }else if([requestURL rangeOfString:@"onepage/failure"].location != NSNotFound){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"FAIL") message:SCLocalizedString(@"Your order has been canceled") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return NO;
    }else if([requestURL rangeOfString:@"onepage/review"].location != NSNotFound){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[SCLocalizedString(@"SUCCESS") uppercaseString] message:SCLocalizedString(@"Your order is under review") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return NO;
    }else if([requestURL rangeOfString:@"simiavenue/api/index"].location != NSNotFound){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[SCLocalizedString(@"Error") uppercaseString] message:SCLocalizedString(@"Have some errors, please try again") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return NO;
    }
    return YES;
}


@end
