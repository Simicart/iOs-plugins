//
//  SCPProductViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 5/3/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPTableViewController.h"
#import "SCPOptionGridTableViewCell.h"
#import "SCPOptionSingleSelectTableViewCell.h"
#import "SCPOptionMultiSelectTableViewCell.h"
#import "SCPTableViewHeaderFooterView.h"
#import "SCPOptionTextFieldTableViewCell.h"
#import "SCPOptionDateTimeTableViewCell.h"
#import "SCPBundleOptionMultiSelectTableViewCell.h"
#import "SCPProductCollectionViewCell.h"

static NSString *scpproduct_configurableoption_section = @"scpproduct_configurableoption_section";
static NSString *scpproduct_customoption_section = @"scpproduct_customoption_section";
static NSString *scpproduct_bundleoption_section = @"scpproduct_bundleoption_section";
static NSString *scpproduct_groupoption_section = @"scpproduct_groupoption_section";
static NSString *scpproduct_downloadableoption_section = @"scpproduct_downloadableoption_section";

static NSString *scpproduct_nameprice_section = @"scpproduct_nameprice_section";
static NSString *scpproduct_addtocart_section = @"scpproduct_addtocart_section";
static NSString *scpproduct_description_section = @"scpproduct_description_section";
static NSString *scpproduct_techspecs_section = @"scpproduct_techspecs_section";

static NSString *scpproduct_option_item_select_row = @"scpproduct_otion_item_select_row";
static NSString *scpproduct_option_single_select_row = @"scpproduct_option_single_select_row";
static NSString *scpproduct_option_multi_select_row = @"scpproduct_option_multi_select_row";
static NSString *scpproduct_option_datetime_row = @"scpproduct_option_datetime_row";
static NSString *scpproduct_option_textfield_row = @"scpproduct_option_textfield_row";
static NSString *scpproduct_addtocart_row = @"scpproduct_addtocart_row";


static NSString *scpproduct_name_row = @"scpproduct_name_row";
static NSString *scpproduct_price_row = @"scpproduct_price_row";

@interface SCPProductViewController : SCProductSecondDesignViewController<SCPOptionGridDelegate>{
    NSMutableDictionary *headerManages;
    UIButton *plusQuantityButton;
    UIButton *minusQuantityButton;
    UIButton *quantityButton;
}

@end