//
//  SCCategoryProductCell_Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/18/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/SimiCategoryModel.h>
#import "SCTheme01SlideShow.h"
#import "SimiGlobalVar+Theme01.h"

@protocol SCCategoryProductCell_Theme01_Delegate <NSObject>
@optional
- (void)didSelectCateGoryWithCateModel:(SimiCategoryModel*)cateMode;
@end

@interface SCCategoryProductCell_Theme01 : UIView
{
    UIButton *btnCate;
    UILabel *lblCateName;
    UILabel *lblViewMore;
    UIImageView *imgChoice;
    UIImageView *imgCateBackGround;
    //  Liam ADD 150502
    UILabel *lblChoice;
    //  End 150502
}

@property (nonatomic, strong) SimiCategoryModel *cateModel;
@property (nonatomic, strong) SCTheme01SlideShow *slideShow;
@property (nonatomic, weak) id<SCCategoryProductCell_Theme01_Delegate> delegate;
@property (nonatomic) BOOL isAllCate;

- (id)initWithFrame:(CGRect)frame isAllCate:(BOOL)isAllCate;
- (void)cusSetCateModel:(SimiCategoryModel *)cateModel_;
@end
