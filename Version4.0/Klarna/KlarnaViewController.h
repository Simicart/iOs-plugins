//
//  KlarnaViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController.h>
#import <SimiCartBundle/SimiResponder.h>
#import "KlarnaModel.h"
#import <SimiCartBundle/SCRedirectPaymentViewController.h>

@interface KlarnaViewController : SCRedirectPaymentViewController<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) KlarnaModel *klarnaModel;
@end
