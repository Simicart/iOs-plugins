//
//  SCPOptionGridTableViewCell.m
//  SimiCartPluginFW
//
//  Created by Liam on 6/12/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPOptionGridTableViewCell.h"
#import "UICollectionViewLeftAlignedLayout.h"

@implementation SCPOptionGridTableViewCell{
    float itemWidth;
    float itemHeight;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andRow:(SCProductOptionRow *)row{
    float padding = SCP_GLOBALVARS.padding;
    float widthCell = SCREEN_WIDTH - padding *2;
    if (PADDEVICE) {
        widthCell = SCALEVALUE(510) - padding *2;
    }
    itemWidth = 120;
    itemHeight = 26;
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.optionModel = (SimiConfigurableOptionModel*)row.model;
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        self.simiContentView = [[UIView alloc]initWithFrame:CGRectMake(padding, 0, widthCell, row.height)];
        [self.simiContentView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.simiContentView];
        
        self.optionNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding, 0, 80, 44)];
        [self.optionNameLabel setFont:[UIFont fontWithName:SCP_FONT_SEMIBOLD size:FONT_SIZE_LARGE]];
        [self.optionNameLabel setTextColor:THEME_CONTENT_COLOR];
        [self.optionNameLabel setNumberOfLines:0];
        [self.optionNameLabel setText:[self.optionModel.title uppercaseString]];
        [self.simiContentView addSubview:self.optionNameLabel];
        
        UICollectionViewLeftAlignedLayout *flowLayout = [UICollectionViewLeftAlignedLayout new];
        flowLayout.minimumLineSpacing = 18;
        flowLayout.minimumInteritemSpacing = 18;
        flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
        self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(padding + 80, 0, widthCell - padding*2 - 80, row.height) collectionViewLayout:flowLayout];
        [self.collectionView setContentInset:UIEdgeInsetsMake(9, 0, 9, 0)];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.collectionView setBackgroundColor:[UIColor whiteColor]];
        [self.simiContentView addSubview:self.collectionView];
        [SimiGlobalFunction sortViewForRTL:self.contentView andWidth:widthCell];
    }
    return self;
}

#pragma mark  CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.optionModel.values count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.optionModel.code isEqualToString:@"size"]) {
        return CGSizeMake(itemHeight, itemHeight);
    }
    SimiConfigurableOptionValueModel *valueModel = [self.optionModel.values objectAtIndex:indexPath.row];
    NSString *labelString = valueModel.title;
    float width = [labelString sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:SCP_FONT_SEMIBOLD size:FONT_SIZE_LARGE]}].width + 30;
    if (width < itemHeight) {
        width = itemHeight;
    }
    return CGSizeMake(width, itemHeight);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"CellID";
    [collectionView registerClass:[SCPGridOptionCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    SCPGridOptionCollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    SimiConfigurableOptionValueModel *valueModel = [self.optionModel.values objectAtIndex:indexPath.row];
    [collectionViewCell updateCellInfo:valueModel];
    return collectionViewCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SimiConfigurableOptionValueModel *valueModel = [self.optionModel.values objectAtIndex:indexPath.row];
    valueModel.isSelected = YES;
    for (int i = 0; i < self.optionModel.values.count; i++) {
        if (i != indexPath.row) {
            SimiConfigurableOptionValueModel *tempOptionValueModel = [self.optionModel.values objectAtIndex:i];
            tempOptionValueModel.isSelected = NO;
        }
    }
    [self.delegate updateOptionsWithProductOptionModel:self.optionModel andValueModel:valueModel];
}

@end
