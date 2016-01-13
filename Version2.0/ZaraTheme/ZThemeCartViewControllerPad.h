//
//  ZThemeCartViewControllerPad.h
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 5/28/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeCartViewController.h"
#import "ZThemeCartCellPad.h"
#import "ZThemeScreenBeforeOrderViewControllerPad.h"

@interface ZThemeCartViewControllerPad : ZThemeCartViewController <UITableViewDataSource, UITableViewDelegate, ZThemeCartCellPad_Delegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIView * headerView;
@property (strong, nonatomic) UILabel * emptyLabel;
@property (strong, nonatomic) UITableView * tableviewProduct;
@property (strong, nonatomic) UIPopoverController * popController;

@end
