//
//  SCSpotProductCell_Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/18/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/SimiModel.h>

#import "SCTheme01SlideShow.h"
#import "SimiGlobalVar+Theme01.h"
@protocol SCSpotProductCell_Theme01_Delegate <NSObject>
@optional
- (void)didSelectedSpotProductWithSpotProductModel:(SimiModel*)spotModel;

@end
@interface SCSpotProductCell_Theme01 : UIView
{
    UILabel *lblSpotName;
    UILabel *lblViewMore;
    UIImageView *imgViewBackGround;
    UIImageView *imgViewMore;
    UIButton *btnSpot;
}

@property (nonatomic, strong) SCTheme01SlideShow* slideShow;
@property (nonatomic, strong) SimiModel* spotModel;
@property (nonatomic, weak) id<SCSpotProductCell_Theme01_Delegate> delegate;
- (void)setViewSpot;
- (void)cusSetSpotModel:(SimiModel *)spotModel;
@end
