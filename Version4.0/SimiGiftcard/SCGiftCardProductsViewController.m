//
//  SCGiftCardProductsViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCGiftCardProductsViewController.h"
#import "SCGiftCardCollectionViewCell.h"

@interface SCGiftCardProductsViewController ()

@end

@implementation SCGiftCardProductsViewController
- (void)viewDidLoadBefore{
    totalNumberProduct = 1000;
    UICollectionViewFlowLayout* flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.minimumLineSpacing = [SimiGlobalVar scaleValue:20];
    flowLayout.minimumInteritemSpacing = [SimiGlobalVar scaleValue:5];
    flowLayout.itemSize = [SimiGlobalVar scaleSize:CGSizeMake(152.5, 152.5 + 4* 20)];
    self.productsCollectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    [self.productsCollectionView setBackgroundColor:[UIColor whiteColor]];
    self.productsCollectionView.delegate = self;
    self.productsCollectionView.dataSource = self;
    [self.productsCollectionView setContentInset:UIEdgeInsetsMake([SimiGlobalVar scaleValue:20], [SimiGlobalVar scaleValue:5], [SimiGlobalVar scaleValue:20], [SimiGlobalVar scaleValue:5])];
     __weak SCGiftCardProductsViewController *tempSelf = self;
    [self.productsCollectionView addInfiniteScrollingWithActionHandler:^{
        [tempSelf getProducts];
    }];
    [self.view addSubview:self.productsCollectionView];
    
    noProductsLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(10, 50, SCREEN_WIDTH - 20, 40)];
    [noProductsLabel setText:SCLocalizedString(@"There are no products matching the selection")];
    [noProductsLabel resizLabelToFit];
    [noProductsLabel setTextAlignment:NSTextAlignmentCenter];
    [noProductsLabel setHidden:YES];
    [self.view addSubview:noProductsLabel];
    [self getProducts];
}

#pragma mark Get Products
- (void)getProducts{
    if (self.productModelCollection == nil) {
        self.productModelCollection = [[SimiGiftCardModelCollection alloc] init];
    }
    NSInteger offset = self.productModelCollection.count;
    if (offset >= totalNumberProduct) {
        [self.productsCollectionView.infiniteScrollingView stopAnimating];
        return;
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithDictionary:@{@"limit":@"16",@"offset":[NSString stringWithFormat:@"%ld",(long)offset],@"image_height":@"600",@"image_width":@"600"}];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:DidGetGiftCardProductCollection object:self.productModelCollection];
    [self.productModelCollection getGiftCardProductCollectionWithParams:params];
    [self.productsCollectionView.infiniteScrollingView startAnimating];
}

- (void)didGetProducts:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    [self.productsCollectionView.infiniteScrollingView stopAnimating];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddProductsForSearchableItems" object:self.productModelCollection];
        if (self.productModelCollection.total != nil && ![self.productModelCollection.total isEqualToString:@""] && ![self.productModelCollection.total isKindOfClass:[NSNull class]]) {
            totalNumberProduct = [self.productModelCollection.total intValue];
        }else
            totalNumberProduct = 0;
        
        if (totalNumberProduct == 0) {
            [noProductsLabel setHidden:NO];
        }else{
            [noProductsLabel setHidden:YES];
        }
        [self.productsCollectionView reloadData];
        [self showToastMessage:[NSString stringWithFormat:@"%@ %@(s)",self.productModelCollection.total, SCLocalizedString(@"Product")] duration:0.5];
    }
    [self removeObserverForNotification:noti];
}

#pragma mark UICollectionView Data Source

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SimiGiftCardModel *productModel = [self.productModelCollection objectAtIndex:[indexPath row]];
    NSString *stringCell = [NSString stringWithFormat:@"%@",[productModel valueForKey:@"entity_id"]];
    [collectionView registerClass:[SCGiftCardCollectionViewCell class] forCellWithReuseIdentifier:stringCell];
    SCGiftCardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:stringCell forIndexPath:indexPath];
    [cell setProductModel:productModel];
    return cell;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.productModelCollection ? [self.productModelCollection count] : 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    [collectionView.collectionViewLayout invalidateLayout];
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    float height = 0;
    if (PHONEDEVICE) {
        int numberCollectionRow = (int)indexPath.row/2;
        for (int i = numberCollectionRow*2; i <= numberCollectionRow*2+1; i++) {
            if (i < self.productModelCollection.count) {
                SimiGiftCardModel *product = [self.productModelCollection objectAtIndex:i];
                if ([product heightPriceOnGrid] > height) {
                    height = [product heightPriceOnGrid];
                }
            }
        }
    }else if (PADDEVICE){
        int numberCollectionRow = (int)indexPath.row/4;
        for (int i = numberCollectionRow*4; i <= numberCollectionRow*4+3; i++) {
            if (i < self.productModelCollection.count) {
                SimiGiftCardModel *product = [self.productModelCollection objectAtIndex:i];
                if ([product heightPriceOnGrid] > height) {
                    height = [product heightPriceOnGrid];
                }
            }
        }
    }
    return CGSizeMake([SimiGlobalVar scaleValue:152.5], [SimiGlobalVar scaleValue:152.5] + height + 20);
}

#pragma mark -
#pragma mark UICollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
