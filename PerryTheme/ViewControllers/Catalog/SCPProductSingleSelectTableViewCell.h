//
//  SCPProductSingleSelectTableViewCell.h
//  SimiCartPluginFW
//
//  Created by Liam on 6/10/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SCPProductSingleSelectTableViewCell : SimiTableViewCell
@property (strong, nonatomic) SimiLabel *nameLabel;
@property (strong, nonatomic) UIImageView *selectImageView;
@property (strong, nonatomic) SimiOptionValueModel *optionValueModel;
@property (strong, nonatomic) SimiProductModel *productModel;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier optionRow:(SCProductOptionRow *)optionRow productModel:(SimiProductModel *)productModel;
- (void)updateCellWithRow:(SCProductOptionRow*)optionRow;
@end
