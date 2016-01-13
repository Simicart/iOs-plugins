//
//  ShortReviewCell_Theme01.m
//  SimiCart
//
//  Created by Tan on 7/1/13.
//  Copyright (c) 2013 Tan ;. All rights reserved.
//

#import "ShortReviewCell_Theme01.h"
#import <SimiCartBundle/UIImage+SimiCustom.h>
#import "SimiGlobalVar+Theme01.h"

@implementation ShortReviewCell_Theme01

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil{
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:nibNameOrNil owner:self options:nil];
    self = [nibObjects objectAtIndex:0];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRatePoint:(float)rp{
    if ((rp > 0) && (rp <= 5)){
        _ratePoint = rp;
    }else{
        _ratePoint = 0;
    }
    
    int temp = (int)_ratePoint;
    
    if (_ratePoint == 0) {
        for (int i = 0; i < [_starCollection count]; i++) {
            [[_starCollection objectAtIndex:i] setImage:[UIImage imageNamed:@"theme01_ratestar2.png"]];
        }
    }else{
        for (int i = 0; i < temp; i++) {
            [[_starCollection objectAtIndex:i] setImage:[UIImage imageNamed:@"theme01_ratestar1.png"]];
        }
        if (_ratePoint - temp > 0) {
            [[_starCollection objectAtIndex:temp] setImage:[UIImage imageNamed:@"theme01_ratestar0.png"]];
            for (int i = temp+1; i < [_starCollection count]; i++) {
                [[_starCollection objectAtIndex:i] setImage:[UIImage imageNamed:@"theme01_ratestar2.png"]];
            }
        }else{
            for (int i = temp; i < [_starCollection count]; i++) {
                [[_starCollection objectAtIndex:i] setImage:[UIImage imageNamed:@"theme01_ratestar2.png"]];
            }
        }       
        
    }
}

- (void)setReviewTitle:(NSString *)reviewTitle{
    if (![_reviewTitle isEqualToString:reviewTitle]) {
        _reviewTitle = [reviewTitle copy];
        _titleLabel.text = _reviewTitle;
    }
}

- (void)setReviewBody:(NSString *)reviewBody{
    if (![_reviewBody isEqualToString:reviewBody]) {
        _reviewBody = [reviewBody copy];
        _bodyLabel.text = _reviewBody;
    }
}

- (void)setReviewTime:(NSString *)reviewTime{
    if (![_reviewTime isEqualToString:reviewTime]) {
        UIImage *imgTime = [[UIImage imageNamed:@"theme01_review_date"] imageWithColor:THEME01_SUB_PART_COLOR];
        _timeImageView.image = imgTime;
        _reviewTime = [reviewTime copy];
        _timeLabel.text = _reviewTime;
        _timeLabel.text = [NSString stringWithFormat:@"%@", _reviewTime];
    }
}

- (void)setCustomerName:(NSString *)customerName{
    if (![_customerName isEqualToString:customerName]){
        _customerName = [customerName copy];
        _customerNameLabel.text = [@"By " stringByAppendingString:_customerName];
    }
}

- (void)reArrangeLabelWithTitleLine:(int)titleLine BodyLine:(int)bodyLine{
    _titleLabel.numberOfLines = titleLine;
    [_titleLabel sizeToFit];
    
    _bodyLabel.numberOfLines = bodyLine;
    [_bodyLabel sizeToFit];
    
    if (bodyLine == 0) {                    //Set order: star-title-time-body
        CGRect frame = _bodyLabel.frame;
        frame.origin.y += 8;
        _bodyLabel.frame = frame;
        
        frame = _timeLabel.frame;
        frame.origin.y = _titleLabel.frame.size.height + 16;
        _timeLabel.frame = frame;
        
        frame = _timeImageView.frame;
        frame.origin.y = _titleLabel.frame.size.height + 22;
        _timeImageView.frame = frame;
        
        frame = _customerNameLabel.frame;
        frame.origin.y = _timeLabel.frame.size.height + 20;
        _customerNameLabel.frame = frame;
        
        frame = _bodyLabel.frame;
        frame.origin.y = _timeLabel.frame.origin.y + 30;
        _bodyLabel.frame = frame;
    }else{                                  //Set order: star-title-body-time
        CGRect frame = _bodyLabel.frame;
        frame.origin.y = _titleLabel.frame.origin.y + 16;
        _bodyLabel.frame = frame;
        
        frame = _timeLabel.frame;
        frame.origin.y = _bodyLabel.frame.origin.y + 27;
        _timeLabel.frame = frame;
        
        frame = _timeImageView.frame;
        frame.origin.y = _bodyLabel.frame.origin.y + 33;
        _timeImageView.frame = frame;
        
        frame = _customerNameLabel.frame;
        frame.origin.y = _bodyLabel.frame.origin.y + 40;
        _customerNameLabel.frame = frame;
    }
    
}

- (CGFloat)getActualCellHeight{
    return _bodyLabel.frame.size.height + _bodyLabel.frame.origin.y + 100;
}

@end
