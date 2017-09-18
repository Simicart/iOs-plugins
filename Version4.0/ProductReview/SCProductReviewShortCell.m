
//
//  ShortReviewCell.m
//  SimiCart
//
//  Created by Tan on 7/1/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//
#import "SCProductReviewShortCell.h"

@implementation SCProductReviewShortCell{
    float padding;
    float sizeStar;
    float titleWidth;
    float labelHeight;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier reviewData:(SimiModel*)reviewModel numberTitleLine:(NSInteger)titleLine numberBodyLine:(NSInteger)bodyLine{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    padding = [SimiGlobalVar scaleValue:15];
    sizeStar = [SimiGlobalVar scaleValue:12];
    titleWidth = [SimiGlobalVar scaleValue:270];
    labelHeight = 22;
    if (PADDEVICE) {
        titleWidth = SCREEN_WIDTH/2 - 50;
    }
    if (self) {
        self.cellHeight = 10;
        starCollection = [[NSMutableArray alloc] init];
        for(int i = 0; i< 5; i++){
            UIImageView *imgStar = [[UIImageView alloc] initWithFrame:CGRectMake(padding + sizeStar*i, self.cellHeight, sizeStar, sizeStar)];
            [self.contentView addSubview:imgStar];
            [starCollection addObject:imgStar];
        }
        [self setRatePoint:[[reviewModel valueForKey:@"rate_points"] floatValue]];
        self.cellHeight += sizeStar;
        
        titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, self.cellHeight, titleWidth, labelHeight*titleLine) andFontSize:[SimiGlobalVar scaleValue:13]];
        [titleLabel setText:[reviewModel valueForKey:@"title"]];
        if (titleLine == 0) {
            [titleLabel resizLabelToFit];
        }
        [self.contentView addSubview:titleLabel];
        self.cellHeight += CGRectGetHeight(titleLabel.frame);
        
        
        bodyLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, self.cellHeight, titleWidth, labelHeight*bodyLine) andFontSize:[SimiGlobalVar scaleValue:11]];
        bodyLabel.numberOfLines = bodyLine;
        [bodyLabel setText:[reviewModel valueForKey:@"detail"]];
        if (bodyLine == 0) {
            [bodyLabel resizLabelToFit];
        }
        [self.contentView addSubview:bodyLabel];
        self.cellHeight += CGRectGetHeight(bodyLabel.frame);
        
        timeLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding,self.cellHeight, titleWidth, labelHeight) andFontSize:[SimiGlobalVar scaleValue:10]];
        [timeLabel setText:[NSString stringWithFormat:@"%@ by %@", [reviewModel valueForKey:@"created_at"], [reviewModel valueForKey:@"nickname"]]];
        [self.contentView addSubview:timeLabel];
        
        self.cellHeight += labelHeight*2;
        float screenWidth = SCREEN_WIDTH;
        if (PADDEVICE) {
            screenWidth = SCREEN_WIDTH/2;
        }
        [SimiGlobalVar sortViewForRTL:self.contentView andWidth:screenWidth];
        [self setBackgroundColor:THEME_APP_BACKGROUND_COLOR];
    }
    return self;
}

- (void)setRatePoint:(float)rp{
    if ((rp > 0) && (rp <= 5)){
        ratePoint = rp;
    }else{
        ratePoint = 0;
    }
    
    int temp = (int)ratePoint;
    
    if (ratePoint == 0) {
        for (int i = 0; i < [starCollection count]; i++) {
            [[starCollection objectAtIndex:i] setImage:[UIImage imageNamed:@"ic_star2"]];
        }
    }else{
        for (int i = 0; i < temp; i++) {
            [[starCollection objectAtIndex:i] setImage:[UIImage imageNamed:@"ic_star"]];
        }
        if (ratePoint - temp > 0) {
            [[starCollection objectAtIndex:temp] setImage:[UIImage imageNamed:@"ic_star_50"]];
            for (int i = temp+1; i < [starCollection count]; i++) {
                [[starCollection objectAtIndex:i] setImage:[UIImage imageNamed:@"ic_star2"]];
            }
        }else{
            for (int i = temp; i < [starCollection count]; i++) {
                [[starCollection objectAtIndex:i] setImage:[UIImage imageNamed:@"ic_star2"]];
            }
        }
        
    }
}
@end
