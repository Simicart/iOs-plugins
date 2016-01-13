//
//  ShortReviewCell_Theme01.h
//  SimiCart
//
//  Created by Tan on 7/1/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShortReviewCell_Theme01 : UITableViewCell

@property (nonatomic) float ratePoint;
@property (strong, nonatomic) NSString *reviewTitle;
@property (strong, nonatomic) NSString *reviewBody;
@property (strong, nonatomic) NSString *reviewTime;
@property (strong, nonatomic) NSString *customerName;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *starCollection;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *bodyLabel;
@property (strong, nonatomic) IBOutlet UILabel *customerNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *timeImageView;

- (void)reArrangeLabelWithTitleLine:(int)titleLine BodyLine:(int) bodyLine;
- (CGFloat)getActualCellHeight;
- (id)initWithNibName:(NSString *)nibNameOrNil;

@end
