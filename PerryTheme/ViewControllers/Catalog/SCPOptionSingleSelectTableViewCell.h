//
//  SCPOptionSingleSelectTableViewCell.h
//  SimiCartPluginFW
//
//  Created by Liam on 6/12/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiTableViewCell.h>

@interface SCPOptionSingleSelectTableViewCell : SimiTableViewCell
@property (strong, nonatomic) SimiLabel *nameLabel;
@property (strong, nonatomic) UIImageView *selectImageView;
@property (strong, nonatomic) SimiOptionValueModel *optionValueModel;
@property (strong, nonatomic) SimiProductModel *productModel;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier optionRow:(SCProductOptionRow *)optionRow productModel:(SimiProductModel *)productModel;
- (void)updateCellWithRow:(SCProductOptionRow*)optionRow;
@end
