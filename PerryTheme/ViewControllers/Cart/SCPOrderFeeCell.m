//
//  SCPOrderFeeCell.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 6/6/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPOrderFeeCell.h"
#import "SCPGlobalVars.h"

@implementation SCPOrderFeeCell
@synthesize paddingX, paddingY, paddingContentX, paddingContentY, heightLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        paddingY = SCALEVALUE(10);
        paddingX = SCALEVALUE(15);
        if(PADDEVICE)
            paddingX = SCALEVALUE(5);
        paddingContentX = SCALEVALUE(20);
        paddingContentY = SCALEVALUE(15);
        heightLabel = SCALEVALUE(30);
    }
    return self;
}
- (void)setData:(NSMutableArray*)cartPrices andWidthCell:(float)widthCell{
    float cellWidth = widthCell - 2*paddingX;
    self.heightCell = paddingY;
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(paddingX, self.heightCell, cellWidth, 0)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:contentView];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    int titleTag = 99;
    int valueTag = 999;
    int titleBoldTag = 111;
    int valueBoldTag = 1111;
    float contentHeight = paddingContentY;
    float contentWidth = cellWidth - 2*paddingContentX;
    for (int i = 0; i < cartPrices.count; i++) {
        NSDictionary *rowData = [cartPrices objectAtIndex:i];
        BOOL isShowBold = NO;
        if ([[rowData valueForKey:@"font_bold"]boolValue]) {
            isShowBold = YES;
        }
        if ([[rowData valueForKey:@"show_both"]boolValue]) {
            UILabel *exclTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(paddingContentX, contentHeight, contentWidth/2, heightLabel)];
            exclTitleLabel.text = [NSString stringWithFormat:@"%@",[rowData valueForKey:@"excl_title"]];
            exclTitleLabel.tag = titleTag;
            [contentView addSubview:exclTitleLabel];
            
            UILabel *exclValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(paddingContentX + contentWidth/2, contentHeight, contentWidth/2, heightLabel)];
            exclValueLabel.text = [NSString stringWithFormat:@"%@",[rowData valueForKey:@"excl_value"]];
            exclValueLabel.tag = valueTag;
            [contentView addSubview:exclValueLabel];
            contentHeight += heightLabel;
            
            UILabel *inclTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(paddingContentX, contentHeight, contentWidth/2, heightLabel)];
            inclTitleLabel.text = [NSString stringWithFormat:@"%@",[rowData valueForKey:@"incl_title"]];
            inclTitleLabel.tag = titleTag;
            [contentView addSubview:inclTitleLabel];
            
            UILabel *inclValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(paddingContentX + contentWidth/2, contentHeight, contentWidth/2, heightLabel)];
            inclValueLabel.text = [NSString stringWithFormat:@"%@",[rowData valueForKey:@"incl_value"]];
            inclValueLabel.tag = valueTag;
            [contentView addSubview:inclValueLabel];
            contentHeight += heightLabel;
            
            if (isShowBold) {
                exclTitleLabel.tag = titleBoldTag;
                exclValueLabel.tag = valueBoldTag;
                inclTitleLabel.tag = titleBoldTag;
                inclValueLabel.tag = valueBoldTag;
            }
        }else if([[rowData valueForKey:@"show_excl"]boolValue])
        {
            UILabel *exclTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(paddingContentX, contentHeight, contentWidth/2, heightLabel)];
            exclTitleLabel.text = [NSString stringWithFormat:@"%@",[rowData valueForKey:@"title"]];
            exclTitleLabel.tag = titleTag;
            [contentView addSubview:exclTitleLabel];
            
            UILabel *exclValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(paddingContentX + contentWidth/2, contentHeight, contentWidth/2, heightLabel)];
            exclValueLabel.text = [NSString stringWithFormat:@"%@",[rowData valueForKey:@"excl_value"]];
            exclValueLabel.tag = valueTag;
            [contentView addSubview:exclValueLabel];
            contentHeight += heightLabel;
            if (isShowBold) {
                exclTitleLabel.tag = titleBoldTag;
                exclValueLabel.tag = valueBoldTag;
            }
        }else
        {
            UILabel *inclTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(paddingContentX, contentHeight, contentWidth/2, heightLabel)];
            inclTitleLabel.text = [NSString stringWithFormat:@"%@",[rowData valueForKey:@"title"]];
            inclTitleLabel.tag = titleTag;
            [contentView addSubview:inclTitleLabel];
            
            UILabel *inclValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(paddingContentX + contentWidth/2, contentHeight, contentWidth/2, heightLabel)];
            inclValueLabel.text = [NSString stringWithFormat:@"%@",[rowData valueForKey:@"incl_value"]];
            inclValueLabel.tag = valueTag;
            [contentView addSubview:inclValueLabel];
            contentHeight += heightLabel;
            if (isShowBold) {
                inclTitleLabel.tag = titleBoldTag;
                inclValueLabel.tag = valueBoldTag;
            }
        }
    }
    contentHeight += paddingContentY;
    CGRect frame = contentView.frame;
    frame.size.height = contentHeight;
    contentView.frame = frame;
    self.heightCell += contentHeight + 2*paddingY;
    [SimiGlobalFunction sortViewForRTL:contentView andWidth:cellWidth];
    for (UIView * label in contentView.subviews) {
        if ([label isKindOfClass:[UILabel class]]) {
            UILabel *labelTemp = (UILabel *)label;
            if (labelTemp.tag == titleTag) {
                [labelTemp setFont:[UIFont fontWithName:SCP_FONT_LIGHT size:FONT_SIZE_SMALL]];
                [labelTemp setTextColor:[UIColor blackColor]];
                labelTemp.textAlignment = NSTextAlignmentLeft;
                if(GLOBALVAR.isReverseLanguage)
                    labelTemp.textAlignment = NSTextAlignmentRight;
            }else if(labelTemp.tag == valueTag)
            {
                [labelTemp setFont:[UIFont fontWithName:SCP_FONT_REGULAR size:FONT_SIZE_MEDIUM]];
                [labelTemp setTextColor:[UIColor blackColor]];
                labelTemp.textAlignment = NSTextAlignmentRight;
                if(GLOBALVAR.isReverseLanguage){
                    labelTemp.textAlignment = NSTextAlignmentLeft;
                }
            }else if(labelTemp.tag == titleBoldTag)
            {
                [labelTemp setFont:[UIFont fontWithName:SCP_FONT_SEMIBOLD size:FONT_SIZE_HEADER]];
                [labelTemp setTextColor:[UIColor blackColor]];
                labelTemp.textAlignment = NSTextAlignmentLeft;
                if(GLOBALVAR.isReverseLanguage)
                    labelTemp.textAlignment = NSTextAlignmentRight;
            }else if(labelTemp.tag == valueBoldTag)
            {
                [labelTemp setFont:[UIFont fontWithName:SCP_FONT_SEMIBOLD size:FONT_SIZE_HEADER]];
                [labelTemp setTextColor:COLOR_WITH_HEX(@"#ff7d00")];
                labelTemp.textAlignment = NSTextAlignmentRight;
                if(GLOBALVAR.isReverseLanguage){
                    labelTemp.textAlignment = NSTextAlignmentLeft;
                }
            }
        }
    }
}

@end
