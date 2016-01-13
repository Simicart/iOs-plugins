//
//  SCOrderViewController_Theme01.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/18/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
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

static NSString *ORDER_ASK_CUSTOMER_ROLE_SECTION = @"AskCustomerRole";

@interface SCOrderViewController_Theme01 : SCOrderViewController<SCShippingDelegate>

/*
 The function tableView cellForRowAtIndexPath raise notification name: "InitializedOrderCell-After" after created a cell.
 The function tableView didSelectRowAtIndexPath raise notification name: "DidSelectOrderCellAtIndexPath" before TO-DO list in the function.
 */
@end
