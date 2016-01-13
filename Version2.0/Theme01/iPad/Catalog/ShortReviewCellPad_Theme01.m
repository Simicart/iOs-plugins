//
//  ShortReviewCellPad_Theme01.m
//  SimiCart
//
//  Created by Tan on 7/1/13.
//  Copyright (c) 2013 Tan ;. All rights reserved.
//

#import "ShortReviewCellPad_Theme01.h"
#import <SimiCartBundle/UIImage+SimiCustom.h>

@implementation ShortReviewCellPad_Theme01

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

- (void)setReviewModel:(SimiReviewModel *)reviewModel_
{
    if (reviewModel_) {
        _reviewModel = reviewModel_;
        if ([_reviewModel valueForKey:@"customer_name"]) {
            self.reviewBody = [_reviewModel valueForKey:@"review_body"];
        }
        if ([_reviewModel valueForKey:@"review_title"]) {
            self.reviewTitle = [_reviewModel valueForKey:@"review_title"];
        }
        if ([_reviewModel valueForKey:@"customer_name"]) {
            self.customerName = [_reviewModel valueForKey:@"customer_name"];
        }
        if ([_reviewModel valueForKey:@"review_time"]) {
            self.reviewDateTime = [_reviewModel valueForKey:@"review_time"];
        }
        if ([_reviewModel valueForKey:@"rate_point"]) {
            self.ratePoint = [[_reviewModel valueForKey:@"rate_point"] floatValue];
        }
    }
    NSString *stringNameButton =  @"";
    if ([_reviewModel valueForKey:@"isSelect"]) {
        if ([[_reviewModel valueForKey:@"isSelect"] isEqualToString:@"yes"]) {
            stringNameButton = @"Show less";
        }else
        {
            stringNameButton = @"Show more";
        }
    }else
    {
        stringNameButton = @"Show more";
    }
    
    [_btnShow setTitle:SCLocalizedString(stringNameButton) forState:UIControlStateNormal];
    [_btnShow setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [_imageDate setImage:[[UIImage imageNamed:@"theme1_dateicon"] imageWithColor:THEME01_SUB_PART_COLOR]];
    
    if ([[_reviewModel valueForKey:@"isSelect"] isEqualToString:@"yes"]) {
        _isSelected = YES;
    }else
    {
        _isSelected = NO;
    }
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
            [[_starCollection objectAtIndex:i] setImage:[UIImage imageNamed:@"theme01_stardetail2"]];
        }
    }else{
        for (int i = 0; i < temp; i++) {
            [[_starCollection objectAtIndex:i] setImage:[UIImage imageNamed:@"theme01_stardetail0"]];
        }
        if (_ratePoint - temp > 0) {
            [[_starCollection objectAtIndex:temp] setImage:[UIImage imageNamed:@"theme01_stardetail1"]];
            for (int i = temp+1; i < [_starCollection count]; i++) {
                [[_starCollection objectAtIndex:i] setImage:[UIImage imageNamed:@"theme01_stardetail2"]];
            }
        }else{
            for (int i = temp; i < [_starCollection count]; i++) {
                [[_starCollection objectAtIndex:i] setImage:[UIImage imageNamed:@"theme01_stardetail2"]];
            }
        }       
        
    }
}

- (void)setReviewTitle:(NSString *)reviewTitle_{
    if (reviewTitle_) {
        _reviewTitle = reviewTitle_;
        [_lblTitle setFont:[UIFont fontWithName:THEME01_FONT_NAME_BOLD size:18]];
        [_lblTitle setText:_reviewTitle];
        _lblTitle.numberOfLines = 2;
    }
}

- (void)setReviewBody:(NSString *)reviewBody_{
    if (reviewBody_) {
        _reviewBody = reviewBody_;
        [_lblBody setFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:18]];
        [_lblBody setText:_reviewBody];
        [_lblBody resizLabelToFit];
        CGRect frame = _lblBody.frame;
        _heightReal = _lblBody.frame.size.height + 140;
        if (frame.size.height > 60) {
            if ([[_reviewModel valueForKey:@"isSelect"] isEqualToString:@"yes"]) {
                float temp = frame.size.height - 60;
                frame = _viewDateTime.frame;
                frame.origin.y += temp;
                [_viewDateTime setFrame:frame];
                
                frame = _lblName.frame;
                frame.origin.y += temp;
                [_lblName setFrame:frame];
                
                frame = _btnShow.frame;
                frame.origin.y += temp;
                [_btnShow setFrame:frame];
                
            }else
            {
                frame.size.height = 60;
                [_lblBody setFrame:frame];
            }
            [_btnShow setHidden:NO];
        }else
        {
            [_btnShow setHidden:YES];
        }
    }
}

- (void)setReviewDateTime:(NSString *)reviewDateTime_
{
    if (reviewDateTime_) {
        _reviewDateTime = reviewDateTime_;
        [_lblDateTime setFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:18]];
        [_lblDateTime setText:_reviewDateTime];
    }
}

- (void)setCustomerName:(NSString *)customerName_{
    if (customerName_) {
        _customerName = customerName_;
        [_lblName  setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:18]];
        [_lblName setText:[NSString stringWithFormat:@"By %@", _customerName]];
    }
}

- (IBAction)didClickButtonShow:(id)sender
{
    [self.delegate didClickShow:[[_reviewModel valueForKey:@"row"] intValue] withSelected:_isSelected];
}

@end
