//
//  SCGiftCardProductsViewController.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/UIScrollView+SVInfiniteScrolling.h>
#import "SimiGiftCardModelCollection.h"

@interface SCGiftCardProductsViewController : SimiViewController<UICollectionViewDelegate, UICollectionViewDataSource>{
    float totalNumberProduct;
    SimiLabel *noProductsLabel;
}
@property (strong, nonatomic) SimiGiftCardModelCollection *productModelCollection;
@property (strong, nonatomic) UICollectionView *productsCollectionView;
@end