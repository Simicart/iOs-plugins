//
//  SCCartViewController_Theme01.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/11/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <SimiCartBundle/SimiCartModelCollection.h>
#import <SimiCartBundle/SCCartViewController.h>

#import "SCCartCell_Theme01.h"
#import "SCLoginViewController_Theme01.h"
static NSString *CART_BUTTON     = @"cartbutton";

@interface SCCartViewController_Theme01 : SCCartViewController<UITableViewDataSource, UITableViewDelegate, SCCartCellDelegate_Theme01, UITextFieldDelegate>

/*
 The function tableView cellForRowAtIndexPath raise notification name: "InitializedCartCell-After" after created a cell.
 The function tableView didSelectRowAtIndexPath raise notification name: "DidSelectCartCellAtIndexPath" before TO-DO list in the function.
 */
+ (instancetype)sharedInstance;

@end
