//
//  SCHomeViewControlleriPad_Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/9/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiBannerModelCollection.h>
#import <SimiCartBundle/SimiTableView.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/SimiCategoryModel.h>
#import <SimiCartBundle/SimiProductModel.h>
#import "SCHomeViewController_Theme01.h"

#import "SCGridViewControllerPad_Theme01.h"
#import "SCTheme01SlideShow.h"
#import "SCTheme01SpotProductModelCollection.h"
#import "SCTheme01CategoryModelCollection.h"
#import "SCCategoryProductCellPad_Theme01.h"
#import "SCSpotProductCellPad_Theme01.h"
#import "iCarousel.h"
#import "SCTheme01_APIKey.h"

@interface SCHomeViewControllerPad_Theme01 :SCHomeViewController_Theme01<UITableViewDataSource, UITableViewDelegate, SCCategoryProductCell_Theme01_Delegate, iCarouselDataSource, iCarouselDelegate, SCSpotProductCell_Theme01_Delegate>

@property (nonatomic, strong) iCarousel *carousel;
@property (nonatomic, strong) NSMutableArray *arrayImageBanner;
@property (nonatomic, strong) NSMutableArray *arrayBannerModel;
@end
