//
//  ZThemeProductInfoView.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 6/5/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeProductInfoView.h"

@implementation ZThemeProductInfoView
{
    UIActivityIndicatorView *activityView;
}
@synthesize productName, manufacturerName, specialPrice, productNameLabel, manufacturerNameLabel, specialPriceLabel, stockStatusLabel, regularPriceLabel, specialPriceView, regularPriceView, regularLabel, specialLabel, regularPrice, shortDescription, shortDescriptionLabel, stockStatus, otherInfo, otherInfos, otherInfoLabel;
@synthesize exclPrice, inclPrice, exclLabel, inclLabel, exclPriceLabel, exclPriceView, inclPriceLabel,inclPriceView, isDetailInfo, tierPrices, tierPrice, tierLabel, showPriceV2;

@synthesize priceFrom, priceTo, fromLabel, priceFromLabel, toLabel, exclPriceFrom, inclPriceFrom, exclPriceTo, inclPriceTo, exclPriceFromLabel, exclFromLabel, inclPriceFromLabel, inclFromLabel, exclPriceToLabel, exclToLabel, inclPriceToLabel, inclToLabel;
@synthesize priceFromView, priceToView, exclPriceFromView, inclPriceFromView, exclPriceToView, inclPriceToView, configLabel, priceConfig, priceConfigLabel, priceConfigView, priceToLabel, exclConfigLabel, exclPriceConfig, exclPriceConfigLabel, exclPriceConfigView, inclConfigLabel, inclPriceConfig, inclPriceConfigLabel, inclPriceConfigView, clickOtherInfos;

- (void)setInterfaceCell
{
    [super setInterfaceCell];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ZThemeProductInfoView-DidSetBasicInfoView" object:self userInfo:@{@"productModel":self.product}];
    if (self.relateCollectionProduct == nil) {
        self.relateCollectionProduct = [SimiProductModelCollection new];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetRelatedProducts:) name:@"DidGetRelatedProductCollection" object:self.relateCollectionProduct];
    [self.relateCollectionProduct getRelatedProductCollectionWithProductId:[self.product valueForKey:@"product_id"] limit:20 otherParams:@{@"width": @"200", @"height": @"200"}];
    
    activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, self.heightCell, 320, 160)];
    activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    activityView.hidesWhenStopped = YES;
    [self addSubview:activityView];
    [activityView startAnimating];
}

- (void)didGetRelatedProducts:(NSNotification*)noti
{
    [activityView stopAnimating];
    [activityView removeFromSuperview];
    
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if ([self.relateCollectionProduct count] > 0) {
            self.arrayRelatedProductID = (NSMutableArray*)[[responder.other objectAtIndex:0] valueForKey:@"product_id_array"];
            if (self.relateProductView == nil) {
                self.labelRelated = [[UILabel alloc]initWithFrame:CGRectMake(15, self.heightCell + 20, CGRectGetWidth(self.frame) - 20, 25)];
                [self.labelRelated setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:16]];
                [self.labelRelated setBackgroundColor:[UIColor clearColor]];
                [self.labelRelated setTextColor:[UIColor blackColor]];
                [self.labelRelated setText:SCLocalizedString(@"Related Product")];
                [self addSubview:self.labelRelated];
                self.heightCell += 45;
                
                UICollectionViewLayout *layout = [[UICollectionViewLayout alloc]init];
                self.relateProductView = [[UICollectionView alloc]initWithFrame:CGRectMake(0 , self.heightCell, CGRectGetWidth(self.frame), 120) collectionViewLayout:layout];
                self.heightCell += 120;
                self.relateProductView.dataSource = self;
                self.relateProductView.delegate = self;
                [self.relateProductView setBackgroundColor:[UIColor clearColor]];
                [self addSubview:self.relateProductView];
                
                UICollectionViewFlowLayout *grid = [[UICollectionViewFlowLayout alloc]init];
                [grid setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                grid.itemSize = CGSizeMake(80, 120);
                grid.minimumInteritemSpacing = 20;
                grid.minimumLineSpacing = 20;
                [self.relateProductView setCollectionViewLayout:grid animated:YES];
                [self.relateProductView setContentInset:UIEdgeInsetsMake(0, 20, 0, 20)];
                self.relateProductView.showsVerticalScrollIndicator = NO;
                [self.relateProductView setBackgroundColor:[UIColor whiteColor]];
            }
        }
    }
    [[NSNotificationCenter defaultCenter]removeObserverForNotification:noti];
}

#pragma mark UICollection Delegate, Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.relateCollectionProduct.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SimiProductModel *productModel = [self.relateCollectionProduct objectAtIndex:indexPath.row];
    NSString *stringCell = [NSString stringWithFormat:@"CELL_ID%@",[productModel valueForKey:@"product_id"]];
    [collectionView registerClass:[ZThemeProductInfoCell class] forCellWithReuseIdentifier:stringCell];
    ZThemeProductInfoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:stringCell forIndexPath:indexPath];
    [cell cusSetProductModel:productModel];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate didSelectRelatedProductWithProductID:[self.product valueForKey:@"product_id"] andListRelatedProduct:self.arrayRelatedProductID];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end

@implementation ZThemeProductInfoCell
- (void)cusSetProductModel:(SimiProductModel *)productModel_
{
    if (![_productModel isEqual:productModel_]) {
        _productModel = productModel_;
        _productImage = [[UIImageView alloc]initWithFrame:self.bounds];
        NSString *firstImage = [productModel_ valueForKey:@"product_image"];
        [_productImage sd_setImageWithURL:[NSURL URLWithString:firstImage ] placeholderImage:[UIImage imageNamed:@"logo"]];
        [_productImage setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_productImage];
    }
}
@end
