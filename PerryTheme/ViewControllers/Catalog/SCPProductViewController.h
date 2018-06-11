//
//  SCPProductViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 5/3/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPTableViewController.h"
#import "SCPProductOptionTypeGridTableViewCell.h"
#import "SCPProductSingleSelectTableViewCell.h"
#import "SCPProductMultiSelectTableViewCell.h"
#import "SCPTableViewHeaderFooterView.h"

static NSString *scpproduct_configurableoption_section = @"scpproduct_configurableoption_section";
static NSString *scpproduct_customoption_section = @"scpproduct_customoption_section";
static NSString *scpproduct_bundleoption_section = @"scpproduct_bundleoption_section";
static NSString *scpproduct_groupoption_section = @"scpproduct_groupoption_section";
static NSString *scpproduct_downloadableoption_section = @"scpproduct_downloadableoption_section";

static NSString *scpproduct_description_section = @"product_description_section";

static NSString *scpproduct_option_item_select_row = @"scpproduct_otion_item_select_row";
static NSString *scpproduct_option_single_select_row = @"scpproduct_option_single_select_row";
static NSString *scpproduct_option_multi_select_row = @"scpproduct_option_multi_select_row";
static NSString *scpproduct_option_datetime_row = @"scpproduct_option_multi_select_row";
static NSString *scpproduct_option_textfield_row = @"scpproduct_option_textfield_row";
@interface SCPProductViewController : SCProductSecondDesignViewController<SCPProductOptionTypeGridDelegate>

@end
