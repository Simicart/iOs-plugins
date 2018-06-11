//
//  SCPProductMultiSelectTableViewCell.m
//  SimiCartPluginFW
//
//  Created by Liam on 6/11/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPProductMultiSelectTableViewCell.h"

@implementation SCPProductMultiSelectTableViewCell
- (void)updateCellWithRow:(SCProductOptionRow *)optionRow{
    self.optionValueModel = optionRow.optionValueModel;
    if (self.optionValueModel.isSelected) {
        [self.selectImageView setImage:[UIImage imageNamed:@"scp_ic_option_multi_selected"]];
    }else{
        [self.selectImageView setImage:[UIImage imageNamed:@"scp_ic_option_multi_unselect"]];
    }
}
@end
