//
//  SCPProductOptionTypeGridTableViewCell.h
//  SimiCartPluginFW
//
//  Created by Liam on 5/30/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//
#import "SCPProductOptionCollectionViewCell.h"
@protocol SCPProductOptionTypeGridDelegate <NSObject>
@optional
- (void)updateOptionsWithProductOptionModel:(SimiConfigurableOptionModel*)optionModel andValueModel:(SimiConfigurableOptionValueModel*)valueModel;
@end

@interface SCPProductOptionTypeGridTableViewCell : SimiTableViewCell<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *optionNameLabel;
@property (nonatomic, strong) SimiConfigurableOptionModel *optionModel;
@property (weak, nonatomic) id<SCPProductOptionTypeGridDelegate> delegate;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andRow:(SCProductOptionRow*)row;
@end
