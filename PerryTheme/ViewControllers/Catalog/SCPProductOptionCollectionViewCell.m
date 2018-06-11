//
//  SCPProductOptionCollectionViewCell.m
//  SimiCartPluginFW
//
//  Created by Liam on 5/30/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/UIView+WebCache.h>
#import "SCPProductOptionCollectionViewCell.h"

@implementation SCPProductOptionCollectionViewCell{
    float itemHeight;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backGroudImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        self.backGroudImageView.layer.cornerRadius = CGRectGetHeight(frame)/2;
        self.backGroudImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.backGroudImageView];
        
        self.optionLabel = [[UILabel alloc]initWithFrame:self.bounds];
        self.optionLabel.numberOfLines = 1;
        [self.optionLabel setFont:[UIFont fontWithName:SCP_FONT_REGULAR size:FONT_SIZE_MEDIUM]];
        [self.optionLabel setTextColor:[UIColor blackColor]];
        [self.optionLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:self.optionLabel];
        
        self.invalidOptionImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(frame)/2-1, CGRectGetWidth(frame), 1)];
        [self.invalidOptionImageView setBackgroundColor:[UIColor blackColor]];
        [self.optionLabel addSubview:self.invalidOptionImageView];
    }
    return self;
}

- (void)updateCellInfo:(SimiConfigurableOptionValueModel *)valueModel{
    self.configOptionValueModel = valueModel;
    if (self.configOptionValueModel.isSelected) {
        [self.backGroudImageView setBackgroundColor:COLOR_WITH_HEX(@"#2d2d2d")];
        [self.optionLabel setTextColor:[UIColor whiteColor]];
        [self.optionLabel setFont:[UIFont fontWithName:SCP_FONT_SEMIBOLD size:FONT_SIZE_MEDIUM]];
        [self.invalidOptionImageView setBackgroundColor:[UIColor whiteColor]];
    }else{
        [self.backGroudImageView setBackgroundColor:COLOR_WITH_HEX(@"#f2f2f2")];
        [self.optionLabel setTextColor:[UIColor blackColor]];
        [self.optionLabel setFont:[UIFont fontWithName:SCP_FONT_REGULAR size:FONT_SIZE_MEDIUM]];
        [self.invalidOptionImageView setBackgroundColor:[UIColor blackColor]];
    }
    if (self.configOptionValueModel.hightLight) {
        [self.invalidOptionImageView setHidden:YES];
    }else{
        [self.invalidOptionImageView setHidden:NO];
    }
    [self.optionLabel setText:self.configOptionValueModel.title];
    float titleWidth = [self.configOptionValueModel.title sizeWithAttributes:@{NSFontAttributeName:self.optionLabel.font}].width;
    CGRect frame = self.invalidOptionImageView.frame;
    frame.origin.x = (CGRectGetWidth(self.frame) - titleWidth)/2;
    frame.size.width = titleWidth;
    [self.invalidOptionImageView setFrame:frame];
}
@end
