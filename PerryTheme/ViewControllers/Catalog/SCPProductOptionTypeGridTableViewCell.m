//
//  SCPProductOptionTypeGridTableViewCell.m
//  SimiCartPluginFW
//
//  Created by Liam on 5/30/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPProductOptionTypeGridTableViewCell.h"

@implementation SCPProductOptionTypeGridTableViewCell{
    float itemWidth;
    float itemHeight;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andRow:(SCProductOptionRow *)row{
    float widthCell = SCREEN_WIDTH;
    if (PADDEVICE) {
        widthCell = SCREEN_WIDTH *2/3;
    }
    float padding = 10;
    float paddingLeft = SCALEVALUE(15);
    float heightLabel = 25;
    itemWidth = 120;
    itemHeight = SCALEVALUE(20);
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.optionModel = (SimiConfigurableOptionModel*)row.model;
    if (self) {
        self.optionNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(paddingLeft, padding, widthCell - padding - paddingLeft, heightLabel)];
        [self.optionNameLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:16]];
        [self.optionNameLabel setTextColor:THEME_CONTENT_COLOR];
        [self.optionNameLabel setText:[NSString stringWithFormat:@"%@(*)",self.optionModel.title]];
        [self.contentView addSubview:self.optionNameLabel];
        
        UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
        flowLayout.minimumLineSpacing = padding;
        flowLayout.minimumInteritemSpacing = padding;
        flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
        self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(paddingLeft, padding + heightLabel,widthCell - padding - paddingLeft, row.height - padding*2 - heightLabel) collectionViewLayout:flowLayout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.collectionView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.collectionView];
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
    float width = [labelString sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:FONT_SIZE_LARGE]}].width + 30;
    if (width < itemHeight) {
        width = itemHeight;
    }
    return CGSizeMake(width, itemHeight);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"CellID";
    [collectionView registerClass:[SCPProductOptionCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    SCPProductOptionCollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    SimiConfigurableOptionValueModel *valueModel = [self.optionModel.values objectAtIndex:indexPath.row];
    [collectionViewCell updateCellInfo:valueModel];
    return collectionViewCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SimiConfigurableOptionValueModel *valueModel = [self.optionModel.values objectAtIndex:indexPath.row];
    if (!valueModel.hightLight) {
        return;
    }
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
