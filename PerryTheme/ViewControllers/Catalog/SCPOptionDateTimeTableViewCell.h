//
//  SCPOptionDateTimeTableViewCell.h
//  SimiCartPluginFW
//
//  Created by Liam on 6/12/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiTableViewCell.h>
#import "SCPGlobalVars.h"

@interface SCPOptionDateTimeTableViewCell : SimiTableViewCell
@property (nonatomic, strong) UIDatePicker *datePicker;
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier optionRow:(SCProductOptionRow *)optionRow;
@end
