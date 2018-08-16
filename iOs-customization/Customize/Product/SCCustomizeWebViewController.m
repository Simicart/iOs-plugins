
//
//  SCCustomizeWebViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 7/20/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCustomizeWebViewController.h"

@interface SCCustomizeWebViewController ()

@end

@implementation SCCustomizeWebViewController{
    UIWebView *webView;
    UIActivityIndicatorView *simiLoading;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    float width = SCREEN_WIDTH - 40;
    float height = width * 720/1280;
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0 , width, height)];
    if(PADDEVICE)
        webView.frame = self.view.bounds;
    webView.delegate = self;
    webView.backgroundColor = [UIColor whiteColor];
    webView.scrollView.scrollEnabled = NO;
    webView.allowsInlineMediaPlayback = YES;

    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlPath]]];
    [self.view addSubview:webView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    webView.frame = self.view.bounds;
    if (!self.tapOutsideRecognizer) {
        self.tapOutsideRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
        self.tapOutsideRecognizer.numberOfTapsRequired = 1;
        self.tapOutsideRecognizer.cancelsTouchesInView = NO;
        self.tapOutsideRecognizer.delegate = self;
        [self.view.window addGestureRecognizer:self.tapOutsideRecognizer];
    }
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:nil]; //Passing nil gives us coordinates in the window
        
        //Then we convert the tap's location into the local view's coordinate system, and test to see if it's in or outside. If outside, dismiss the view.
        
        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil])
        {
            // Remove the recognizer first so it's view.window is valid.
            [self.view.window removeGestureRecognizer:sender];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - Gesture Recognizer
// because of iOS8
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)startLoadingData{
    if (!simiLoading.isAnimating) {
        CGRect frame = self.view.bounds;
        simiLoading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        simiLoading.hidesWhenStopped = YES;
        simiLoading.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [self.view addSubview:simiLoading];
        self.view.userInteractionEnabled = NO;
        [simiLoading startAnimating];
    }
}

- (void)stopLoadingData{
    self.view.userInteractionEnabled = YES;
    [simiLoading stopAnimating];
    [simiLoading removeFromSuperview];
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self startLoadingData];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopLoadingData];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self stopLoadingData];
}
@end
