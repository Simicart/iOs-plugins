//
//  ZThemeProductView.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 5/26/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiView.h>
#import <SimiCartBundle/SimiProductModel.h>
#import <SimiCartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>
#define BIG_SCROLL_VIEW_TAG -1

@protocol ZThemeProductView_Delegate <NSObject>
@optional
- (void)didGetProductDetailWithProductID:(NSString*)productID;
- (void)touchImage;
@end


@interface ZThemeProductView : SimiView<UIScrollViewDelegate>
{
    UIActivityIndicatorView *activityIndicatorView;
    int beginTag;
}

@property (nonatomic, strong) UIScrollView *scrollViewProductImages;
@property (nonatomic, strong) SimiProductModel *productModel;
@property (nonatomic, strong) NSString* productID;
@property (nonatomic, strong) NSMutableArray *productImages;

@property (nonatomic) CGFloat heightScrollView;
@property (nonatomic) CGFloat widthScrollView;
@property (nonatomic) CGFloat topMark;
@property (nonatomic) CGFloat bottomMark;
@property (nonatomic) NSInteger offsetZoomed;
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGFloat previousScale;
@property (nonatomic) BOOL isTouchInSmallScrollView;
@property (nonatomic) BOOL isGotProduct;
@property (nonatomic) BOOL isDidGetProduct;

@property (nonatomic) CGRect frameParentView;
@property (nonatomic, weak) id<ZThemeProductView_Delegate> delegate;

@property (nonatomic) int numberImage;
@property (nonatomic, strong) UIView    *viewPageControl;

- (instancetype)initWithFrame:(CGRect)frame productID:(NSString *)productID_;
- (void)getProductDetail;
@end
