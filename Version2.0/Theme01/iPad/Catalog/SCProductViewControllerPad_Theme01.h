//
//  SCProductViewControllerPad_Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/24/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//
#import <SimiCartBundle/SimiProductModel.h>
#import <SimiCartBundle/SimiProductModelCollection.h>
#import <SimiCartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/UILabelDynamicSize.h>
#import <SimiCartBundle/CoreAPI_Key.h>

#import "SimiGlobalVar+Theme01.h"
#import "SCDetailViewControllerPad_Theme01.h"
#import "SCReviewViewControllerPad_Theme01.h"
#import "SCProductDetailViewControllerPad_Theme01.h"
#import "SCProductViewController_Theme01.h"

@interface SCProductViewControllerPad_Theme01 : SCProductViewController_Theme01<UIScrollViewDelegate, SCDetailViewControllerPad_Theme01_Delegate>
{
    int beginTag;
}

@property (nonatomic) BOOL isSecondScreen;
@property (nonatomic, strong) NSString  *productName;
@property (nonatomic) float productRate;
@property (nonatomic, strong) NSMutableArray *imagesProduct;
@property (nonatomic, strong) UIScrollView  *scrollImageProduct;
@property (nonatomic, strong) UILabel   *lblNameProduct;
@property (nonatomic, strong) UIImageView   *imageDetailReview;
@property (nonatomic, strong) UIView    *viewPageControl;
@property (nonatomic, strong) UIView    *viewStar;
@property (nonatomic, strong) UIButton  *btnViewStar;
@property (nonatomic, strong) UIActivityIndicatorView   *activityIndicator;

@property (nonatomic, strong) SCDetailViewControllerPad_Theme01 *detailViewController;
@property (nonatomic, strong) SCReviewViewControllerPad_Theme01 *reviewViewController;
@property (nonatomic, strong) SCProductDetailViewControllerPad_Theme01 *descriptionViewController;
@end
