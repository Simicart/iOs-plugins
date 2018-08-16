//
//  SCCreditCardDetailViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 2/5/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "SimiTableCustomizeViewController.h"
#import "SimiCustomizeTableViewCell.h"

@protocol SCCreditCardDetailDelegate
- (void)didSaveCreditCard;
@end

@interface SCCreditCardDetailViewController : SimiTableCustomizeViewController<UIPickerViewDelegate, UIPickerViewDataSource,SimiCustomizeTableViewCellDelegate>
@property (nonatomic, strong) SimiModel *creditCard;
@property (weak, nonatomic) id<SCCreditCardDetailDelegate>delegate;
@end
