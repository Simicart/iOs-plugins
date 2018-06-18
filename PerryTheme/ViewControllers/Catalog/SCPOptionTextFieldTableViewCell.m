//
//  SCPOptionTextFieldTableViewCell.m
//  SimiCartPluginFW
//
//  Created by Liam on 6/12/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPOptionTextFieldTableViewCell.h"

@implementation SCPOptionTextFieldTableViewCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier optionRow:(SCProductOptionRow *)optionRow{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        float padding = SCP_GLOBALVARS.padding;
        float widthCell = SCREEN_WIDTH - padding *2;
        if (PADDEVICE) {
            widthCell = SCALEVALUE(510) - padding *2;
        }
        self.simiContentView = [[UIView alloc]initWithFrame:CGRectMake(padding, 0, widthCell, optionRow.height)];
        [self.simiContentView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.simiContentView];
        
        self.optionTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(padding, 5, widthCell - padding*2, 40) placeHolder:@"" font:[UIFont fontWithName:SCP_FONT_REGULAR size:FONT_SIZE_MEDIUM] textColor:[UIColor blackColor] backgroundColor:[UIColor whiteColor] borderWidth:1 borderColor:[UIColor lightGrayColor] paddingLeft:10];
        self.optionTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.optionTextField.layer.cornerRadius = 4;
        [self.simiContentView addSubview:self.optionTextField];
    }
    return self;
}
@end
