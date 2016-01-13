//
//  SCCollectionViewController_Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 12/18/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/SimiProductModelCollection.h>
#import <SimiCartBundle/UIScrollView+SVInfiniteScrolling.h>
#import <SimiCartBundle/NSObject+SimiObject.h>

#import "SimiGlobalVar+Theme01.h"
#import "SCTheme01ProductModelCollection.h"
#import "SCCollectionViewCell_Theme01.h"
#import "SCTheme01_APIKey.h"

typedef NS_ENUM(NSInteger, SCCollectionGetProductType) {
    SCCollectionGetProductTypeFromSearch,
    SCCollectionGetProductTypeFromCategory,
    SCCollectionGetProductTypeFromSpotProduct
};

@protocol SCCollectionViewController_Theme01_Delegate <NSObject>
@optional
- (void)selectedProduct:(NSString*)productId_;
- (void)numberProductChange:(int)numberProduct;
//  Liam ADD 150325
- (void)didGetProductModelCollection:(NSDictionary*)layerNavigation;
- (void)startGetProductModelCollection;
//  End
@end


@interface SCCollectionViewController_Theme01 : UICollectionViewController{
    SimiResponder *responder;
}

@property (strong, nonatomic) SCTheme01ProductModelCollection *productCollection;
@property (nonatomic) ProductCollectionSortType sortType;
@property (nonatomic, strong) id<SCCollectionViewController_Theme01_Delegate> delegate;
@property (nonatomic) SCCollectionGetProductType scColllectionGetProductType;

@property (strong, nonatomic) NSMutableArray *dataSourceArray;
@property (strong, nonatomic) NSString *categoryId;
@property (strong, nonatomic) NSString *searchProduct;
@property (strong, nonatomic) NSString *spotKey;
@property (nonatomic) SCCollectionGetProductType scCollectionGetProductType;
@property (nonatomic) BOOL isRelatedProduct;
@property (nonatomic, strong) UILabel *lbNotFound;
@property (nonatomic) BOOL isTax;
//  Liam ADD 150325
@property (nonatomic, strong) NSMutableDictionary* filterParam;
//  End

- (void)viewDidLoadAfter;
- (void)viewWillAppearAfter;
- (void)getProducts;
- (void)setLayout;
- (void)didGetProducts:(NSNotification *)noti;
@end
