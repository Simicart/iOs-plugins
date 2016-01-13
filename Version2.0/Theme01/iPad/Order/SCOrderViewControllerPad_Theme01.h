//
//  SCOrderViewControllerPad_Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 10/2/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//
#import <SimiCartBundle/UILabelDynamicSize.h>
#import <SimiCartBundle/SimiToolbar.h>
#import <SimiCartBundle/SimiCheckbox.h>
#import <SimiCartBundle/UILabelDynamicSize.h>
#import <SimiCartBundle/SCCartCell.h>
#import <SimiCartBundle/SCOrderViewController.h>
#import <SimiCartBundle/SCTermConditionViewController.h>
#import <SimiCartBundle/SCCreditCardViewController.h>
#import "SCShippingViewControllerPad_Theme01.h"

#import "SimiViewController+Theme01.h"
#import "SimiGlobalVar+Theme01.h"
#import "SCCartTotalCellPad_Theme01.h"

@interface SCOrderViewControllerPad_Theme01 : SCOrderViewController<SimiToolbarDelegate, UIPopoverControllerDelegate, SCAddressDelegate,SCCreditCardViewDelegates , UIAlertViewDelegate, SCShippingDelegate>

@property (nonatomic, strong) UITableView* tableLeft;
@property (nonatomic, strong) UITableView* tableRight;
@property (nonatomic, strong) SimiTable *orderTableLeft;
@property (nonatomic, strong) SimiTable *orderTableRight;

@property (strong, nonatomic) UIPopoverController *popController;

@end
