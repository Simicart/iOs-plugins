//
//  ZThemeCollectionViewController.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/7/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/SimiProductModelCollection.h>
#import <SimiCartBundle/UIScrollView+SVInfiniteScrolling.h>
#import <SimiCartBundle/NSObject+SimiObject.h>

#import "ZThemeProductModelCollection.h"

typedef NS_ENUM(NSInteger, ZThemeCollectioViewGetProductType) {
    ZThemeCollectioViewGetProductTypeFromCategory,
    ZThemeCollectioViewGetProductTypeFromSearch,
    ZThemeCollectioViewGetProductTypeFromSpot
};

@protocol ZThemeCollectionViewController_Delegate <NSObject>
@optional
- (void)selectedProduct:(NSString*)productID_;
- (void)numberProductChange:(int)numberProduct;
- (void)didGetProductModelCollection:(NSDictionary*)layerNavigation;
- (void)startGetProductModelCollection;
- (void)setHideViewToolBar:(BOOL)isHide;
@end

@interface ZThemeCollectionViewController : UICollectionViewController<UIScrollViewDelegate>
{
    SimiResponder *responder;
}

@property (strong, nonatomic)  ZThemeProductModelCollection *productCollection;
@property (nonatomic) ProductCollectionSortType sortType;
@property (nonatomic, strong) id<ZThemeCollectionViewController_Delegate> delegate;
@property (nonatomic) ZThemeCollectioViewGetProductType collectionGetProductType;

@property (strong, nonatomic) NSMutableArray *dataSourceArray;
@property (strong, nonatomic) NSString *categoryId;
@property (strong, nonatomic) NSString *searchProduct;
@property (strong, nonatomic) NSString *spot_ID;
@property (nonatomic) BOOL isRelatedProduct;
@property (nonatomic, strong) UILabel *lbNotFound;
@property (nonatomic, strong) NSDictionary* filterParam;
@property (nonatomic, strong) NSMutableArray *arrayProductsID;

@property (nonatomic) BOOL isShowOnlyImage;
@property (nonatomic, strong) UIPinchGestureRecognizer *gesture;
@property (nonatomic,assign) CGFloat scale;
@property (nonatomic,assign) BOOL animatedZooming;
@property (nonatomic) CGFloat lastContentOffset;

@property (nonatomic) int totalNumberProduct;

- (void)viewDidLoadAfter;
- (void)viewWillAppearAfter;
- (void)getProducts;
- (void)setLayout;
- (void)didGetProducts:(NSNotification *)noti;
@end
