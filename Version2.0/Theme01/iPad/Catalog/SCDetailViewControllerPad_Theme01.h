//
//  SCDetailViewControllerPad_Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/24/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiProductModel.h>
#import <SimiCartBundle/NSString+HTML.h>
#import <SimiCartBundle/CoreAPI_Key.h>

#import "SCProductViewController_Theme01.h"
#import "SCOptionGroupViewCellPad_Theme01.h"
#import "SimiGlobalVar+Theme01.h"
#import "SCCollectionViewControllerPad_Theme01.h"
#import "SCProductInfoViewPad_Theme01.h"
#import "SCOptionTypeView_Theme01.h"

static NSString *PRODUCT_PRICE_CELL_ID              = @"PRODUCT_PRICE_CELL_ID";
static NSString *PRODUCT_ADDTOCART_CELL_ID          = @"PRODUCT_OPTION_ADDTOCART_CELL_ID";
@protocol SCDetailViewControllerPad_Theme01_Delegate <NSObject>
@optional
- (void)didSelectDescriptionRow;
- (void)selectedProductRelate:(NSString *)productId_;
@end

@interface SCDetailViewControllerPad_Theme01 : SCProductViewController_Theme01<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SCCollectionViewController_Theme01_Delegate>
{
    SCProductInfoViewPad_Theme01 *productInfoViewPad_Theme01;
}
@property (strong, nonatomic) id<SCDetailViewControllerPad_Theme01_Delegate> delegate;
@property (nonatomic, strong) SCCollectionViewControllerPad_Theme01 *relatedProductViewController;
@property (nonatomic, strong) SCOptionGroupViewCellPad_Theme01 * optionViewCell;
@property (nonatomic, strong) SimiProductModelCollection *relatedCollection;

@end
