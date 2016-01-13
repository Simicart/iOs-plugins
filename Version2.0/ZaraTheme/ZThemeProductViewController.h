//
//  ZThemeProductViewController.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 5/26/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SCProductViewController.h>
#import <SimiCartBundle/ILTranslucentView.h>
#import <SimiCartBundle/SimiFormatter.h>

#import "ZThemeProductView.h"
#import "SimiGlobalVar+ZTheme.h"
#import "SimiViewController+ZTheme.h"
#import "WYPopoverController.h"
#import "ZThemeProductOptionViewController.h"
#import "ZThemeProductDetailViewController.h"

#define PRICE_FONT_SIZE UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone? 12:14;

@interface ZThemeProductViewController : SCProductViewController<UIScrollViewDelegate, ZThemeProductView_Delegate, WYPopoverControllerDelegate, ZThemeProductOptionViewController_Delegate>

@property (nonatomic, strong) UIScrollView *scrollViewProducts;
@property (nonatomic, strong) NSMutableArray *arrayProductsID;
@property (nonatomic, strong) NSMutableArray *arrayProductsView;
@property (nonatomic, strong) NSString *firstProductID;
@property (nonatomic) float heightScrollView;
@property (nonatomic) float widthScrollView;
@property (nonatomic) int currentIndexProductOnArray;

@property (nonatomic, strong) ILTranslucentView *viewToolBar;
@property (nonatomic, strong) UILabel *labelProductName;
@property (nonatomic, strong) UILabel *lblExcl;
@property (nonatomic, strong) UILabel *lblExclPrice;
@property (nonatomic, strong) UILabel *lblIncl;
@property (nonatomic, strong) UILabel *lblInclPrice;
@property (nonatomic, strong) UIView *crossLine;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *detailButon;

@property (nonatomic, strong) UIButton *buttonAddToCart;
@property (nonatomic, strong) UIButton *buttonSelectOption;
@property (nonatomic, strong) UIView *viewAction;

@property (nonatomic) BOOL hadCurrentProductModel;
@property (nonatomic) BOOL isShowOnlyImage;

@property (nonatomic) BOOL isFirtLoadProduct;

@property (nonatomic, strong) WYPopoverController *optionPopoverController;
@property (nonatomic, strong) ZThemeProductOptionViewController *optionViewController;

@property (nonatomic, strong) UIImageView *currentImageProduct;
- (void)configureProductViewWithStatus:(BOOL)isStatus;

@end
