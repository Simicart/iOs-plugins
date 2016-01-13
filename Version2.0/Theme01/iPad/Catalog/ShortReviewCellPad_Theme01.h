//
//  ShortReviewCellPad_Theme01.h
//  SimiCart
//
//  Created by Tan on 7/1/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/SimiReviewModel.h>
#import <SimiCartBundle/UILabelDynamicSize.h>
#import "SimiGlobalVar+Theme01.h"

@protocol ShortReviewCellPad_Theme01_Delegate <NSObject>
- (void)didClickShow:(int)row withSelected:(BOOL)isSelect;
@end

@interface ShortReviewCellPad_Theme01 : UITableViewCell

@property (nonatomic, strong) SimiReviewModel *reviewModel;
@property (nonatomic) float ratePoint;
@property (strong, nonatomic) NSString *reviewTitle;
@property (strong, nonatomic) NSString *reviewBody;
@property (strong, nonatomic) NSString *reviewDateTime;
@property (strong, nonatomic) NSString *customerName;
@property (strong, nonatomic) NSString *isShowMore;

@property (nonatomic) float heightReal;

@property (strong, nonatomic) IBOutlet UIButton *btnShow;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblBody;
@property (strong, nonatomic) IBOutlet UIView *viewDateTime;
@property (strong, nonatomic) IBOutlet UILabel *lblDateTime;
@property (strong, nonatomic) IBOutlet UIImageView *imageDate;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *starCollection;
@property (strong, nonatomic) IBOutlet UILabel *lblName;

@property (nonatomic) BOOL isSelected;

@property (weak, nonatomic) id<ShortReviewCellPad_Theme01_Delegate> delegate;

- (IBAction)didClickButtonShow:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil;

@end
