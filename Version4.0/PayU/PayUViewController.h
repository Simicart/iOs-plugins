//
//  PayUViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/15/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SCRedirectPaymentViewController.h>

@interface PayUViewController : SCRedirectPaymentViewController<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *stringURL;
@end
