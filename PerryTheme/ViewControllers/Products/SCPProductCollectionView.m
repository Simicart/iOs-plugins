//
//  SCPProductCollectionView.m
//  SimiCartPluginFW
//
//  Created by Liam on 4/27/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPProductCollectionView.h"
#import "SCPProductCollectionViewCell.h"
#import "SCPProductViewController.h"

@implementation SCPProductCollectionView
- (void)setLayout{
    minimumImageSize = (SCREEN_WIDTH - SCP_GLOBALVARS.padding*2 - SCP_GLOBALVARS.interitemSpacing)/2;
    maximumImageSize = SCREEN_WIDTH - SCP_GLOBALVARS.padding*2;
    UICollectionViewFlowLayout *grid = [[UICollectionViewFlowLayout alloc]init];
    grid.minimumInteritemSpacing = SCP_GLOBALVARS.interitemSpacing;
    grid.minimumLineSpacing = SCP_GLOBALVARS.lineSpacing;
    if (self.gridMode) {
        grid.itemSize = CGSizeMake(minimumImageSize, 60);
    }else{
        grid.itemSize = CGSizeMake(maximumImageSize, 80);
    }
    [self setCollectionViewLayout:grid animated:NO completion:^(BOOL finished) {
    }];
    [self setContentInset:UIEdgeInsetsMake(SCP_GLOBALVARS.lineSpacing, SCP_GLOBALVARS.padding, SCP_GLOBALVARS.lineSpacing, SCP_GLOBALVARS.padding)];
    self.showsVerticalScrollIndicator = NO;
    [self registerClass:[SCPProductCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self setBackgroundColor:COLOR_WITH_HEX(@"#f2f2f2")];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SimiProductModel *product = [self.productModelCollection objectAtIndex:[indexPath row]];
    NSString *stringCell = @"cellIdentifier";
    SCPProductCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:stringCell forIndexPath:indexPath];
    [cell setProductModelForCell:product];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.gridMode) {
        float height = 0;
        int numberCollectionRow = (int)indexPath.row/2;
        for (int i = numberCollectionRow*2; i <= numberCollectionRow*2+1; i++) {
            if (i < self.productModelCollection.count) {
                SimiProductModel *product = [self.productModelCollection objectAtIndex:i];
                if ([product heightPriceOnGrid] > height) {
                    height = [product heightPriceOnGrid];
                }
            }
        }
        return CGSizeMake(minimumImageSize, minimumImageSize + 40 + height);
    }else{
        SimiProductModel *product = [self.productModelCollection objectAtIndex:indexPath.row];
        return CGSizeMake(maximumImageSize, maximumImageSize + 45 + [product heightPriceOnGrid]);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // Do nothing
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.productModelCollection.count > indexPath.row){
        SimiProductModel *product = [self.productModelCollection objectAtIndex:indexPath.row];
        [self.actionDelegate selectedProduct:product];
    }
}
@end
