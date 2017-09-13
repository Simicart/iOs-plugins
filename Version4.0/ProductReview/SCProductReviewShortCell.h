//
//  ShortReviewCell.h
//  SimiCart
//
//  Created by Tan on 7/1/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

@interface SCProductReviewShortCell : UITableViewCell{
    float ratePoint;
    NSString *reviewTitle;
    NSString *reviewBody;
    NSString *reviewTime;
    NSString *customerName;
    SimiLabel *timeLabel;
    NSMutableArray *starCollection;
    SimiLabel *titleLabel;
    SimiLabel *bodyLabel;
}
@property (nonatomic) float cellHeight;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier reviewData:(SimiModel*)reviewModel numberTitleLine:(NSInteger)titleLine numberBodyLine:(NSInteger)bodyLine;

@end
