//
//  SCProductCollectionViewPad+Customize.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 3/9/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCProductCollectionViewPad+Customize.h"

@implementation SCProductCollectionViewPad (Customize)
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SimiProductModel *product = [self.productModelCollection objectAtIndex:[indexPath row]];
    NSString *stringCell = [NSString stringWithFormat:@"CELL_ID_%@",product.entityId];
    [[NSNotificationCenter defaultCenter]postNotificationName:SCProductCollectionView_RegisterCollectionViewCell object:self userInfo:@{KEYEVENT.PRODUCTCOLLECTIONVIEW.identifier:stringCell}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
    }else
        [collectionView registerClass:[SCProductCollectionViewCellPad class] forCellWithReuseIdentifier:stringCell];
    SCProductCollectionViewCellPad *cell = [collectionView dequeueReusableCellWithReuseIdentifier:stringCell forIndexPath:indexPath];
    [cell setProductModelForCell:product];
    [[NSNotificationCenter defaultCenter]postNotificationName:SCProductCollectionView_InitializedCellEnd object:self userInfo:@{KEYEVENT.PRODUCTCOLLECTIONVIEW.cell:cell, KEYEVENT.PRODUCTCOLLECTIONVIEW.indexpath:indexPath}];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    float height = 0;
    
    if(!GLOBALVAR.isLogin){
        
    }else{
        int numberCollectionRow = (int)indexPath.row/4;
        for (int i = numberCollectionRow*4; i <= numberCollectionRow*4+3; i++) {
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
    NSValue *sizeValue = [NSValue valueWithCGSize:CGSizeMake(SCALEVALUE(maximumImageSize), SCALEVALUE(maximumImageSize) + height + 3*heightLabel + 20)];
    [[NSNotificationCenter defaultCenter]postNotificationName:SCProductCollectionView_UpdateSizeForItem object:self userInfo:@{KEYEVENT.PRODUCTCOLLECTIONVIEW.item_size:sizeValue, KEYEVENT.PRODUCTCOLLECTIONVIEW.indexpath:indexPath}];
    if (collectionView.isDiscontinue) {
        collectionView.isDiscontinue = NO;
        return self.itemSize;
    }
    return sizeValue.CGSizeValue;
}
@end
