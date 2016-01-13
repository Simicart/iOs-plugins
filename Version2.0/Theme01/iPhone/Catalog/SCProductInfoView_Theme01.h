//
//  SCProductInfoView.h
//  SimiCart
//
//  Created by Tan on 7/4/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/SimiProductModel.h>
#import <SimiCartBundle/SCProductInfoView.h>
#import "SCTheme01_APIKey.h"
#import "SimiGlobalVar+Theme01.h"

@protocol SCProductInfoView_Theme01_Delegate <NSObject>
@optional
- (void)didSelectProductImage:(NSArray *)imageArray;
@end

@interface SCProductInfoView_Theme01 : SCProductInfoView<UIScrollViewDelegate>

@property id<SCProductInfoView_Theme01_Delegate> delegate;
@property (strong, nonatomic) NSString *imagePath;
@property (nonatomic, strong) UIScrollView  *scrollImageProduct;
@property (nonatomic, strong) UIView  *viewPageControl;

@property (nonatomic) float productRate;
@property (nonatomic) int currentIndex;
@property (nonatomic) CGRect mainFrame;
@property (strong, nonatomic)  NSMutableArray *imagesProduct;

- (void)setImagePageControl:(int)index;
@end
