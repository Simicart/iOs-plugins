//
//  SCPaypalExpressWebViewController.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/19/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController.h>

@interface SCPaypalExpressWebViewController : SimiViewController <UIWebViewDelegate>

@property UIWebView * paypalExpCheckOutWebView;
@property NSNumber * reviewAddress;

@end
