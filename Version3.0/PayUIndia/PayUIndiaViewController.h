//
//  PayUIndiaViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/17/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface PayUIndiaViewController : SimiViewController<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *stringURL;
@end
