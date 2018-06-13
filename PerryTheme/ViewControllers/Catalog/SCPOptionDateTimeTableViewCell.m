//
//  SCPOptionDateTimeTableViewCell.m
//  SimiCartPluginFW
//
//  Created by Liam on 6/12/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPOptionDateTimeTableViewCell.h"

@implementation SCPOptionDateTimeTableViewCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier optionRow:(SCProductOptionRow *)optionRow{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        float padding = SCP_GLOBALVARS.padding;
        float widthCell = SCREEN_WIDTH - padding *2;
        if (PADDEVICE) {
            widthCell = SCREEN_WIDTH *2/3 - padding *2;
        }
        self.simiContentView = [[UIView alloc]initWithFrame:CGRectMake(padding, 0, widthCell, optionRow.height)];
        [self.simiContentView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.simiContentView];
        
        SimiCustomOptionModel *optionModel = (SimiCustomOptionModel*)optionRow.model;
        self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(padding, padding, widthCell - padding*2, optionRow.height - padding*2)];
        if ([optionModel.type isEqualToString:@"date"]) {
            self.datePicker.datePickerMode = UIDatePickerModeDate;
        } else if ([optionModel.type isEqualToString:@"date_time"]) {
            self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        } else {
            self.datePicker.datePickerMode = UIDatePickerModeTime;
        }
        [self.simiContentView addSubview:self.datePicker];
    }
    return self;
}
@end
