//
//  ZThemeCartViewController.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 5/13/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SCCartViewController.h>

#import "ZThemeCartCell.h"
#import "SimiViewController+ZTheme.h"

static NSString *CART_BUTTON     = @"cartbutton";

@interface ZThemeCartViewController : SCCartViewController <UITableViewDataSource, UITableViewDelegate, ZThemeCartCellDelegate, UITextFieldDelegate>

+ (instancetype)sharedInstance;
- (void)clearAllProductsInCart;

@end
