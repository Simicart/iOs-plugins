//
//  SCPaypalExpressCoreWorker.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/17/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SCThemeWorker.h>
#import <SimiCartBundle/SCOrderViewController.h>
#import <SimiCartBundle/SCCartViewController.h>
#import "SCPaypalExpressWebViewController.h"


@interface SCPaypalExpressCoreWorker : NSObject <UIPopoverControllerDelegate>

//for product View
@property (strong, nonatomic) SCProductViewController *productViewController;
@property (strong, nonatomic) UIView *productActionView;

@property (strong, nonatomic) UIButton *btnPaypalProduct; //Paypal On Product Screen
@property (strong, nonatomic) UIButton *btnPaypalCart; //Paypal On Cart Screen

@property (strong, nonatomic) UIButton *btnPaypalProductNew;

@property (strong, nonatomic) SCPaypalExpressWebViewController *webViewController;
@property (nonatomic) CGRect productActionViewFrame;

@end
