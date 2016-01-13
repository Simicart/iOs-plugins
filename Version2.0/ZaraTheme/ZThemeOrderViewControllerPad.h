//
//  ZThemeOrderViewControllerPad.h
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 6/1/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/UILabelDynamicSize.h>
#import <SimiCartBundle/SimiToolbar.h>
#import <SimiCartBundle/SimiCheckbox.h>
#import <SimiCartBundle/UILabelDynamicSize.h>
#import <SimiCartBundle/SCCartCell.h>
#import <SimiCartBundle/SCOrderViewController.h>
#import <SimiCartBundle/SCTermConditionViewController.h>
#import <SimiCartBundle/SCCreditCardViewController.h>
#import "ZThemeShippingViewControllerPad.h"

#import "SimiViewController+ZTheme.h"
#import "SimiGlobalVar+ZTheme.h"

@interface ZThemeOrderViewControllerPad : SCOrderViewController<SimiToolbarDelegate, UIPopoverControllerDelegate, SCAddressDelegate,SCCreditCardViewDelegates , UIAlertViewDelegate, SCShippingDelegate>

@property (nonatomic, strong) UITableView* tableLeft;
@property (nonatomic, strong) UITableView* tableRight;
@property (nonatomic, strong) SimiTable *orderTableLeft;
@property (nonatomic, strong) SimiTable *orderTableRight;

@property (strong, nonatomic) UIPopoverController *popController;

@end
