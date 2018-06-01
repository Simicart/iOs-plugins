//
//  SCPProductViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 5/3/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPTableViewController.h"
#import "SCPProductOptionTypeGridTableViewCell.h"

static NSString *scpproduct_option_item_select_row = @"scpproduct_otion_item_select_row";
static NSString *scpproduct_option_single_select_row = @"scpproduct_option_single_select_row";
static NSString *scpproduct_option_multi_select_row = @"scpproduct_option_multi_select_row";
@interface SCPProductViewController : SCProductSecondDesignViewController<SCPProductOptionTypeGridDelegate>

@end
