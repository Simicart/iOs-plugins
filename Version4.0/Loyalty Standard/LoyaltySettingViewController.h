//
//  LoyaltySettingViewController.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 1/21/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import <SimiCartBundle/SimiTableViewController.h>
#import "LoyaltyModel.h"
static NSString *LOYALTY_EMAIL_SETTING = @"LOYALTY_EMAIL_SETTING";
static NSString *LOYALTY_EMAIL_NOTI     = @"email";
static NSString *LOYALTY_EMAIL_EXP      = @"expire";

@interface LoyaltySettingViewController : SimiTableViewController
@property (strong, nonatomic) LoyaltyModel *model;

@end
