//
//  SimiAvenueWebView.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/3/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <SimiCartBundle/SimiViewController.h>

@interface SimiAvenueWebView : SimiViewController<UIWebViewDelegate>{
    NSURL *url;
    UIBarButtonItem *backItem;
}

@property (strong, nonatomic) NSString *urlPath;
@property (strong, nonatomic) NSString *webTitle;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSString *content;

@end