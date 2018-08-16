//
//  SCCustomizeProductOptionViewController.h
//  SimiCartPluginFW
//
//  Created by Liam on 3/6/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SCProductOptionViewController.h>
@protocol SCCustomizeGroupOptionCellDelegate<NSObject>
- (void)plusGroupOption:(SimiGroupOptionModel*)groupOptionModel;
- (void)minusGroupOption:(SimiGroupOptionModel*)groupOptionModel;
@end

@interface SCCustomizeProductOptionViewController : SCProductOptionViewController<SCCustomizeGroupOptionCellDelegate>

@end

@interface SCCustomizeGroupOptionCell:SimiTableViewCell
@property (weak, nonatomic) id<SCCustomizeGroupOptionCellDelegate> delegate;
@property (strong, nonatomic) SimiGroupOptionModel* groupOptionModel;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier groupOptionModel:(SimiGroupOptionModel*)groupOptionModel;
@end
