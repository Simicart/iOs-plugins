//
//  SCPOptionGridTableViewCell.h
//  SimiCartPluginFW
//
//  Created by Liam on 6/12/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPGridOptionCollectionViewCell.h"
@protocol SCPOptionGridDelegate <NSObject>
@optional
- (void)updateOptionsWithProductOptionModel:(SimiConfigurableOptionModel*)optionModel andValueModel:(SimiConfigurableOptionValueModel*)valueModel;
@end
@interface SCPOptionGridTableViewCell : SimiTableViewCell<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *optionNameLabel;
@property (nonatomic, strong) SimiConfigurableOptionModel *optionModel;
@property (weak, nonatomic) id<SCPOptionGridDelegate> delegate;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andRow:(SCProductOptionRow*)row;
@end
