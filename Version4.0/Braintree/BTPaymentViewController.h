//
//  BTPaymentViewController.h
//  SimiCartPluginFW
//
//  Created by Axe on 12/8/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//
@import PassKit;
#import "BraintreeApplePay.h"
#import <SimiCartBundle/SimiCartBundle.h>
#import "BraintreeUI.h"
#import <SimiCartBundle/SimiOrderModel.h>
#import "BraintreeApplePay.h"
#import <Foundation/Foundation.h>
#import "BraintreeCore.h"
#import "BraintreeUI.h"
#import "BTCardClient.h"
#import <SimiCartBundle/SimiGlobalVar.h>

static NSString* const PAYMENTSECTION = @"PAYMENTSECTION";

@interface BTPaymentViewController: SimiViewController<UITableViewDelegate, UITableViewDataSource,PKPaymentAuthorizationViewControllerDelegate,BTViewControllerPresentingDelegate,BTAppSwitchDelegate, BTDropInViewControllerDelegate>


@property (nonatomic, strong) BTAPIClient *braintreeClient;
@property (nonatomic,strong) SimiOrderModel* order;
@property NSDictionary* payment;
@property NSDictionary* shipping;
@end
