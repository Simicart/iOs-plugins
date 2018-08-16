//
//  SCProductCollectionView+Customize.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 3/9/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCProductCollectionView+Customize.h"

@implementation SCProductCollectionView (Customize)
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    float height = 0;
    if(!GLOBALVAR.isLogin){
        
    }else{
        int numberCollectionRow = (int)indexPath.row/2;
        for (int i = numberCollectionRow*2; i <= numberCollectionRow*2+1; i++) {
            if (i < self.productModelCollection.count) {
                SimiProductModel *product = [self.productModelCollection objectAtIndex:i];
                if([[product objectForKey:@"final_price"] floatValue] == 0 && product.productType != ProductTypeGrouped){
                    height = 54;
                }else{
                    if ([product heightPriceOnGrid] > height) {
                        height = [product heightPriceOnGrid];
                    }
                }
            }
        }
    }
    heightLabel = 25;
    NSValue *sizeValue = [NSValue valueWithCGSize:CGSizeMake(SCALEVALUE(maximumImageSize), SCALEVALUE(maximumImageSize) + height + 3*heightLabel)];
    [[NSNotificationCenter defaultCenter]postNotificationName:SCProductCollectionView_UpdateSizeForItem object:self userInfo:@{KEYEVENT.PRODUCTCOLLECTIONVIEW.item_size:sizeValue, KEYEVENT.PRODUCTCOLLECTIONVIEW.indexpath:indexPath}];
    if (collectionView.isDiscontinue) {
        collectionView.isDiscontinue = NO;
        return self.itemSize;
    }
    return sizeValue.CGSizeValue;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SimiProductModel *product = [self.productModelCollection objectAtIndex:[indexPath row]];
    NSString *stringCell = [NSString stringWithFormat:@"CELL_ID_%@",product.entityId];
    [[NSNotificationCenter defaultCenter]postNotificationName:SCProductCollectionView_RegisterCollectionViewCell object:self userInfo:@{KEYEVENT.PRODUCTCOLLECTIONVIEW.identifier:stringCell}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
    }else
        [collectionView registerClass:[SCProductCollectionViewCell class] forCellWithReuseIdentifier:stringCell];
    SCProductCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:stringCell forIndexPath:indexPath];
    [cell setProductModelForCell:product];
    [[NSNotificationCenter defaultCenter]postNotificationName:SCProductCollectionView_InitializedCellEnd object:self userInfo:@{KEYEVENT.PRODUCTCOLLECTIONVIEW.cell:cell, KEYEVENT.PRODUCTCOLLECTIONVIEW.indexpath:indexPath}];
    return cell;
}

@end
