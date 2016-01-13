//
//  ZThemeOrderViewController.h
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 5/28/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//


#import <SimiCartBundle/SimiViewController.h>
#import <SimiCartBundle/SCOrderViewController.h>
#import <SimiCartBundle/SCAddressViewController.h>
#import <SimiCartBundle/SimiAddressModel.h>
#import <SimiCartBundle/SimiCartModelCollection.h>
#import <SimiCartBundle/SimiPaymentModelCollection.h>
#import <SimiCartBundle/SimiShippingModelCollection.h>
#import <SimiCartBundle/SimiShippingModel.h>
#import <SimiCartBundle/SimiOrderModel.h>
#import <SimiCartBundle/SimiToolbar.h>
#import <SimiCartBundle/SCCreditCardViewController.h>
#import <SimiCartBundle/UILabelDynamicSize.h>
#import <SimiCartBundle/SCNewAddressViewController.h>
#import <SimiCartBundle/SimiViewController_Theme.h>
#import <SimiCartBundle/SCShippingViewController.h>

#import "SimiViewController+ZTheme.h"

static NSString *ORDER_ASK_CUSTOMER_ROLE_SECTION = @"AskCustomerRole";

@interface ZThemeOrderViewController : SCOrderViewController<SCShippingDelegate>

@end
