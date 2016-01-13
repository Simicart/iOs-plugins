//
//  SCProductViewControllerPad_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/24/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCProductViewControllerPad_Theme01.h"
#import "SimiViewController+Theme01.h"
#import <SimiCartBundle/UIImage+SimiCustom.h>

@class  SCProductViewControllerPad_Theme01;

@implementation SCProductViewControllerPad_Theme01
@synthesize productId, product;
#pragma mark Main Method

- (void)viewDidLoadBefore
{
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    beginTag = 100;
    if (!_isSecondScreen) {
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_activityIndicator setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _activityIndicator.hidesWhenStopped =  YES;
        [self.view addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
        [self getProduct];
    }
    [self setNavigationBarOnViewDidLoadForTheme01];
}

- (void)viewWillAppearAfter:(BOOL)animated
{
    [self setNavigationBarOnViewWillAppearForTheme01];
    if (_isSecondScreen) {
        [self setInformationProduct];
    }
}

- (void)viewWillDisappearAfter:(BOOL)animated
{
    [self deleteBackItemForTheme01];
}

#pragma mark Info Product
- (void)setInformationProduct
{
    self.imagesProduct = (NSMutableArray*)[self.product valueForKey:PROD_product_images];
    self.productRate = [[self.product valueForKey:PROD_product_rate]floatValue];
    self.productName = [self.product valueForKey:PROD_product_name];
    
    [self setInterfaceButtonDetailReview];
    if (!_isSecondScreen) {
        _detailViewController = [[SCDetailViewControllerPad_Theme01 alloc]init];
        _detailViewController.product = self.product;
        _detailViewController.delegate = self;
        [_detailViewController.view setFrame:CGRectMake(570, 115, 425, 585)];
        [self.view addSubview:_detailViewController.view];
        
        _reviewViewController = [[SCReviewViewControllerPad_Theme01 alloc]init];
        _reviewViewController.product = self.product;
        [_reviewViewController.view setFrame:CGRectMake(570, 115, 425, 585)];
        [self.view addSubview:_reviewViewController.view];
        [_reviewViewController.view setHidden:YES];
    }else
    {
        _descriptionViewController = [[SCProductDetailViewControllerPad_Theme01 alloc]init];
        _descriptionViewController.product = self.product;
        [_descriptionViewController.view setFrame:CGRectMake(570, 0, 425, 600)];
        [self.view addSubview:_descriptionViewController.view];
        [self addChildViewController:_descriptionViewController];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SCProductViewControllerPad_Theme01-DidGetProductInfomation" object:self userInfo:@{@"productmodel":self.product}];
}

- (void)setInterfaceButtonDetailReview
{
    if (!_isSecondScreen) {
        _imageDetailReview = [[UIImageView alloc]initWithFrame:CGRectMake(585, 28, 410, 45)];
        [_imageDetailReview setImage:[UIImage imageNamed:@"theme1_detailreview2"]];
        [self.view addSubview:_imageDetailReview];
        
        UILabel *lblDetail = [[UILabel alloc]initWithFrame:CGRectMake(585, 28, 205, 45)];
        [lblDetail setFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:22]];
        [lblDetail setTextAlignment:NSTextAlignmentCenter];
        [lblDetail setText:SCLocalizedString(@"Details")];
        [lblDetail setTextColor:[UIColor blackColor]];
        [self.view addSubview:lblDetail];
        
        UILabel *lblReview = [[UILabel alloc]initWithFrame:CGRectMake(790, 28, 205, 45)];
        [lblReview setFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:22]];
        [lblReview setTextAlignment:NSTextAlignmentCenter];
        [lblReview setText:SCLocalizedString(@"Reviews")];
        [lblReview setTextColor:[UIColor blackColor]];
        [self.view addSubview:lblReview];
        
        UIButton *btnDetail = [[UIButton alloc]initWithFrame:CGRectMake(585, 23, 205, 55)];
        btnDetail.backgroundColor = [UIColor clearColor];
        [btnDetail addTarget:self action:@selector(didClickButtonDetail) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnDetail];
        
        UIButton *btnReview = [[UIButton alloc]initWithFrame:CGRectMake(790, 23, 205, 55)];
        btnReview.backgroundColor = [UIColor clearColor];
        [btnReview addTarget:self action:@selector(didClickButtonReview) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnReview];
    }
}

- (void) didClickButtonDetail
{
    [_imageDetailReview setImage:[UIImage imageNamed:@"theme1_detailreview2"]];
    [_detailViewController.view setHidden:NO];
    [_reviewViewController.view setHidden:YES];
}

- (void) didClickButtonReview
{
    [_imageDetailReview setImage:[UIImage imageNamed:@"theme1_detailreview"]];
    [_detailViewController.view setHidden:YES];
    [_reviewViewController.view setHidden:NO];
}

- (void)setImagesProduct:(NSMutableArray *)imagesProduct_
{
//    Set scroll image product
    if (imagesProduct_.count > 0) {
        _imagesProduct = imagesProduct_;
        float heightImage = 500;
        float widthImage = 500;
        _scrollImageProduct = [[UIScrollView alloc]initWithFrame:CGRectMake(35, 115, heightImage, widthImage)];
        _scrollImageProduct.layer.borderWidth = 1;
        _scrollImageProduct.layer.borderColor = [UIColor colorWithRed:202.0/255 green:202.0/255 blue:202.0/255 alpha:0.5].CGColor;
        _scrollImageProduct.showsHorizontalScrollIndicator = NO;
        _scrollImageProduct.showsVerticalScrollIndicator = NO;
        _scrollImageProduct.pagingEnabled = YES;
        _scrollImageProduct.delegate = self;

        for (int i = 0; i < _imagesProduct.count; i++) {
            UIImageView *imageProduct = [[UIImageView alloc]initWithFrame:CGRectMake(0, i*heightImage, widthImage, heightImage)];
            [imageProduct sd_setImageWithURL:[_imagesProduct objectAtIndex:i]];
            imageProduct.contentMode = UIViewContentModeScaleAspectFit;
            [_scrollImageProduct addSubview:imageProduct];
        }
        
        [_scrollImageProduct setContentSize:CGSizeMake(widthImage, heightImage*_imagesProduct.count)];
        [self.view addSubview:_scrollImageProduct];
        
        //    set pagecontrol
        _viewPageControl = [[UIView alloc]initWithFrame:CGRectMake(15, 300, 11, 100)];
        float sizeItem = 11;
        float distanceItem = 7;
        
        for (int i = 0; i < _imagesProduct.count; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, i*(sizeItem + distanceItem), sizeItem, sizeItem)];
            imageView.tag = beginTag + i;
            [_viewPageControl addSubview:imageView];
        }
        
        [self setImagePageControl:0];
        [self.view addSubview:_viewPageControl];
    }
}

- (void)setProductName:(NSString *)productName_
{
    if (productName_ != nil) {
        _productName = productName_;
        _lblNameProduct = [[UILabel alloc]initWithFrame:CGRectMake(60, 35, 425, 40)];
        _lblNameProduct.numberOfLines = 2;
        [_lblNameProduct setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:30]];
        [_lblNameProduct setTextColor:[UIColor colorWithRed:64.0/255 green:64.0/255 blue:66.0/255 alpha:1.0]];
        [_lblNameProduct setTextAlignment:NSTextAlignmentCenter];
        [_lblNameProduct setLineBreakMode:NSLineBreakByWordWrapping];
        [_lblNameProduct setText:_productName];
        [_lblNameProduct resizLabelToFit];
        if (_lblNameProduct.frame.size.height > 60) {
            CGRect frame = _lblNameProduct.frame;
            frame.origin.y -= 15;
            frame.size.height = 80;
            [_lblNameProduct setFrame:frame];
            
            frame = _viewStar.frame;
            frame.origin.y += 40;
            [_viewStar setFrame:frame];
            [_btnViewStar setFrame:frame];
            
            frame = _scrollImageProduct.frame;
            frame.origin.y += 40;
            [_scrollImageProduct setFrame:frame];
        }else
        {
            CGRect frame = _lblNameProduct.frame;
            frame.size.height = 40;
            [_lblNameProduct setFrame:frame];
        }
        [self.view addSubview:_lblNameProduct];
    }
}

- (void)setProductRate:(float)productRate_
{
//    Set name && star
    if (productRate_ > 0 && productRate_ < 6) {
        _productRate = productRate_;
    }else
    {
        _productRate = 0;
    }
    _viewStar = [[UIView alloc]initWithFrame:CGRectMake(215, 80, 100, 15)];
    int temp = (int)_productRate;
    int sizeStar = 15;
    int sizeStarWithDistance = 22;
    
    if (_productRate == 0) {
        for (int i = 0; i < 5; i++) {
            UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(i*sizeStarWithDistance, 0, sizeStar, sizeStar)];
            [imageStar setImage:[UIImage imageNamed:@"theme01_stardetail2"]];
            [_viewStar addSubview:imageStar];
        }
    }else{
        for (int i = 0; i < temp; i++) {
            UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(i*sizeStarWithDistance, 0, sizeStar, sizeStar)];
            [imageStar setImage:[UIImage imageNamed:@"theme01_stardetail0"]];
            [_viewStar addSubview:imageStar];
        }
        if (_productRate - temp > 0) {
            UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(temp*sizeStarWithDistance, 0, sizeStar, sizeStar)];
            [imageStar setImage:[UIImage imageNamed:@"theme01_stardetail1"]];
            [_viewStar addSubview:imageStar];
            
            for (int i = temp + 1; i < 5; i++) {
                UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(i*sizeStarWithDistance, 0, sizeStar, sizeStar)];
                [imageStar setImage:[UIImage imageNamed:@"theme01_stardetail2"]];
                [_viewStar addSubview:imageStar];;
            }
        }else{
            for (int i = temp; i < 5; i++) {
                UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(i*sizeStarWithDistance, 0, sizeStar, sizeStar)];
                [imageStar setImage:[UIImage imageNamed:@"theme01_stardetail2"]];
                [_viewStar addSubview:imageStar];
            }
        }
    }

    [self.view addSubview:_viewStar];
    
    _btnViewStar = [[UIButton alloc]initWithFrame:_viewStar.frame];
    [_btnViewStar setBackgroundColor:[UIColor clearColor]];
    [_btnViewStar addTarget:self action:@selector(didSelectStar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnViewStar];
}

#pragma mark Get Product

- (void)getProduct
{
    if (self.productId != nil) {
        if (self.product ==  nil) {
            self.product = [[SimiProductModel alloc]init];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProduct:) name: @"DidGetProductWithProductId" object:self.product];
        [self.product getProductWithProductId:self.productId otherParams:@{@"width": [NSString stringWithFormat:@"%ld", (long)SCREEN_WIDTH], @"height": [NSString stringWithFormat:@"%ld", (long)SCREEN_WIDTH]}];
    }
}

- (void)didGetProduct:(NSNotification*)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([[responder.status uppercaseString] isEqualToString:@"SUCCESS"]) {
        [_activityIndicator stopAnimating];
        [_activityIndicator removeFromSuperview];
        [self setInformationProduct];
    }
}

#pragma mark ScrollView Delegate + PageControl
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = _scrollImageProduct.frame.size.height;
    int page = floor((_scrollImageProduct.contentOffset.y - pageWidth / 2) / pageWidth) + 1;
    [self setImagePageControl:page];
}

- (void)setImagePageControl:(int)index
{
    for (UIView *subview in _viewPageControl.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView*)subview;
            if (imageView.tag == (index + beginTag)) {
                [imageView setImage:[[UIImage imageNamed:@"theme1_pagecontrolchoice"] imageWithColor:THEME01_SUB_PART_COLOR]];
            }else
            {
                [imageView setImage:[[UIImage imageNamed:@"theme1_pagecontrolnochoice"] imageWithColor:THEME01_SUB_PART_COLOR]];
            }
        }
    }
}

#pragma mark Detail Delegate
- (void)didSelectDescriptionRow
{
    SCProductViewControllerPad_Theme01 *productViewControllerScreen2 = [[SCProductViewControllerPad_Theme01 alloc]init];
    productViewControllerScreen2.productId = self.productId;
    productViewControllerScreen2.isSecondScreen = YES;
    productViewControllerScreen2.product = self.product;
    [self.navigationController pushViewController:productViewControllerScreen2 animated:NO];
}

- (void)selectedProductRelate:(NSString *)productId_
{
    SCProductViewControllerPad_Theme01 *productViewRelated = [[SCProductViewControllerPad_Theme01 alloc]init];
    productViewRelated.productId = productId_;
    [self.navigationController pushViewController:productViewRelated animated:YES];
}

#pragma mark Select Star
- (void)didSelectStar
{
    [self didClickButtonReview];
}
@end
