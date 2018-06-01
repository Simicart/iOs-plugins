//
//  SCPProductOptionCollectionViewCell.h
//  SimiCartPluginFW
//
//  Created by Liam on 5/30/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPGlobalVars.h"

@interface SCPProductOptionCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) SimiConfigurableOptionValueModel *configOptionValueModel;
@property (nonatomic, strong) UIImageView *backGroudImageView;
@property (nonatomic, strong) UILabel *optionLabel;
@property (nonatomic, strong) UIImageView *invalidOptionImageView;
- (void)updateCellInfo:(SimiConfigurableOptionValueModel *)valueModel;
@end
