//
//  SCPPadProductCollectionView.m
//  SimiCartPluginFW
//
//  Created by Liam on 5/14/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPPadProductCollectionView.h"
#import "SCPProductCollectionViewCell.h"

@implementation SCPPadProductCollectionView
- (void)setLayout{
    minimumImageSize = (SCREEN_WIDTH - SCP_GLOBALVARS.padding*2 - SCP_GLOBALVARS.interitemSpacing*3)/4;
    UICollectionViewFlowLayout *grid = [[UICollectionViewFlowLayout alloc]init];
    grid.minimumInteritemSpacing = SCP_GLOBALVARS.interitemSpacing;
    grid.minimumLineSpacing = SCP_GLOBALVARS.lineSpacing;
    grid.itemSize = CGSizeMake(minimumImageSize, 80);
    [self setCollectionViewLayout:grid animated:NO completion:^(BOOL finished) {
    }];
    [self setContentInset:UIEdgeInsetsMake(SCP_GLOBALVARS.lineSpacing, SCP_GLOBALVARS.padding, SCP_GLOBALVARS.lineSpacing, SCP_GLOBALVARS.padding)];
    self.showsVerticalScrollIndicator = NO;
    [self registerClass:[SCPProductCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self setBackgroundColor:COLOR_WITH_HEX(@"#f2f2f2")];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(minimumImageSize, minimumImageSize + 80);
}
@end
