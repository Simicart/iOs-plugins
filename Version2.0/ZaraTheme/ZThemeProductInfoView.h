//
//  ZThemeProductInfoView.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 6/5/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SCProductInfoView.h>
#import <SimiCartBundle/SimiProductModelCollection.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>
#import <SimiCartBundle/UIImageView+WebCache.h>

#import "SimiGlobalVar+ZTheme.h"
@protocol ZThemeProductInfoView_Delegate<NSObject>
@optional
- (void)didSelectRelatedProductWithProductID:(NSString*)selectProductID andListRelatedProduct:(NSMutableArray*)arrayRelatedProduct;
@end

@interface ZThemeProductInfoView : SCProductInfoView<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *relateProductView;
@property (nonatomic, strong) SimiProductModelCollection *relateCollectionProduct;
@property (nonatomic, strong) UILabel *labelRelated;
@property (nonatomic, strong) NSMutableArray* arrayRelatedProductID;
@property (nonatomic, weak) id<ZThemeProductInfoView_Delegate> delegate;
@end

@interface ZThemeProductInfoCell : UICollectionViewCell
@property (strong, nonatomic) SimiProductModel *productModel;
@property (strong, nonatomic) UIImageView *productImage;

- (void)cusSetProductModel:(SimiProductModel*)productModel_;
@end