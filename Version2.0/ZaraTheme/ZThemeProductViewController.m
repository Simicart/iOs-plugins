//
//  ZThemeProductViewController.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 5/26/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeProductViewController.h"

@interface ZThemeProductViewController ()

@end

@implementation ZThemeProductViewController
@synthesize viewToolBar, hadCurrentProductModel;
@synthesize numberOfRequired;
@synthesize product, optionPopoverController;

#pragma mark Init
- (void)viewDidLoadBefore
{
    [self setNavigationBarOnViewDidLoadForZTheme];
    [self.navigationItem setTitle:SCLocalizedString(@"Product")];
    self.arrayProductsView = [NSMutableArray new];
    self.heightScrollView = CGRectGetHeight(self.view.frame) - 64;
    self.widthScrollView = CGRectGetWidth(self.view.frame);
    
    self.scrollViewProducts = [[UIScrollView alloc]initWithFrame:self.view.frame];
    [self.scrollViewProducts setContentSize:CGSizeMake(self.widthScrollView * self.arrayProductsID.count, self.heightScrollView)];
    [self.scrollViewProducts setDelegate:self];
    if(self.firstProductID == nil || [self.firstProductID isEqualToString:@""])
    {
        self.firstProductID = self.productId;
        self.arrayProductsID = [[NSMutableArray alloc]initWithArray:@[self.productId]];
    }
    for (int i = 0; i < self.arrayProductsID.count; i++) {
        ZThemeProductView *productView = [[ZThemeProductView alloc]initWithFrame:CGRectMake(self.widthScrollView *i, 0, self.widthScrollView, self.heightScrollView) productID:[self.arrayProductsID objectAtIndex:i]];
        productView.frameParentView = self.view.frame;
        productView.delegate = self;
        [self.arrayProductsView addObject:productView];
        [self.scrollViewProducts addSubview:productView];
    }
    for (int i = 0; i < self.arrayProductsID.count; i++) {
        if([[self.arrayProductsID objectAtIndex:i] isEqualToString:self.firstProductID])
        {
            self.currentIndexProductOnArray = i;
            break;
        }
    }
    [self.scrollViewProducts setPagingEnabled:YES];
    [self.scrollViewProducts setContentOffset:CGPointMake(self.currentIndexProductOnArray*self.widthScrollView, 0) animated:NO];
    for (int i = self.currentIndexProductOnArray - 1; i <= self.currentIndexProductOnArray + 1; i++) {
        if (i >= 0 && i < self.arrayProductsID.count) {
            ZThemeProductView *currentShowProduct = (ZThemeProductView*)[self.arrayProductsView objectAtIndex:i];
            if (!currentShowProduct.isGotProduct) {
                [currentShowProduct getProductDetail];
            }
        }
    }
    [self.view addSubview:self.scrollViewProducts];
    
    [self viewToolBar];
    [self.view addSubview: viewToolBar];
    
    self.viewAction = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 120, CGRectGetWidth(self.view.frame), 40)];
    [self.viewAction setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.viewAction];
    
    self.isFirtLoadProduct = YES;
    [self.viewToolBar setHidden:YES];
    [self.viewAction setHidden:YES];
    
    self.buttonAddToCart = [[UIButton alloc]initWithFrame:CGRectMake(170, 0, 130, 40)];
    [self.buttonAddToCart addTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonAddToCart setTitle:SCLocalizedString(@"Add To Cart") forState:UIControlStateNormal];
    [self.buttonAddToCart setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buttonAddToCart.backgroundColor = ZTHEME_BTN_ADD_TO_CART_COLOR;
    self.buttonAddToCart.layer.masksToBounds = YES;
    self.buttonAddToCart.layer.cornerRadius = 4.0;
    [self.viewAction addSubview:self.buttonAddToCart];
    
    self.buttonSelectOption = [[UIButton alloc]initWithFrame:CGRectMake(20, 0, 130, 40)];
    [self.buttonSelectOption addTarget:self action:@selector(buttonSelectOptionTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonSelectOption setTitle:SCLocalizedString(@"Option") forState:UIControlStateNormal];
    [self.buttonSelectOption setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buttonSelectOption.backgroundColor = [UIColor grayColor];
    self.buttonSelectOption.layer.masksToBounds = YES;
    self.buttonSelectOption.layer.cornerRadius = 4.0;
    [self.viewAction addSubview:self.buttonSelectOption];
    
    self.currentImageProduct = [UIImageView new];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZThemeProductViewController_DidLoadBefore" object:self userInfo:@{@"viewAction": self.viewAction, @"view":self.view}];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [self setNavigationBarOnViewWillAppearForZTheme:YES isShowRightItems:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (UIView *)viewToolBar
{
    if(viewToolBar == nil)
    {
        CGRect frame = self.view.frame;
        frame.size.height = 45;
        viewToolBar = [[ILTranslucentView alloc] initWithFrame:frame];
        viewToolBar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        viewToolBar.translucentTintColor = [UIColor whiteColor];
        viewToolBar.translucentAlpha = 0;
        viewToolBar.translucentStyle = UIBarStyleDefault;
        viewToolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        if (SIMI_SYSTEM_IOS < 7.0) {
            viewToolBar.backgroundColor = [UIColor whiteColor];
        }
        
        _labelProductName = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 200, 25)];
        [_labelProductName setTextColor:[UIColor blackColor]];
        [_labelProductName setTextAlignment:NSTextAlignmentCenter];
        [_labelProductName setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_BOLD size:14]];
        [viewToolBar addSubview:_labelProductName];
        
        int priceFontSize = PRICE_FONT_SIZE;
        _lblExcl = [UILabel new];
        [_lblExcl setTextColor:[UIColor blackColor]];
        [_lblExcl setBackgroundColor:[UIColor clearColor]];
        [_lblExcl setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:priceFontSize]];
        [viewToolBar addSubview:_lblExcl];
        
        _lblExclPrice = [UILabel new];
        _lblExclPrice.textColor = ZTHEME_PRICE_COLOR;
        [_lblExclPrice setBackgroundColor:[UIColor clearColor]];
        [_lblExclPrice setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:priceFontSize]];
        [viewToolBar addSubview:_lblExclPrice];
        
        _lblIncl = [UILabel new];
        [_lblIncl setTextColor:[UIColor blackColor]];
        [_lblIncl setBackgroundColor:[UIColor clearColor]];
        [_lblIncl setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:priceFontSize]];
        [viewToolBar addSubview:_lblIncl];
        
        _lblInclPrice = [UILabel new];
        _lblInclPrice.textColor = ZTHEME_PRICE_COLOR;
        [_lblInclPrice setBackgroundColor:[UIColor clearColor]];
        [_lblInclPrice setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:priceFontSize]];
        [viewToolBar addSubview:_lblInclPrice];
        
        _crossLine = [UIView new];
        [_crossLine setBackgroundColor:[UIColor blackColor]];
        [viewToolBar addSubview:_crossLine];
        
        _shareButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 45)];
        [_shareButton setBackgroundColor:[UIColor clearColor]];
        [_shareButton setTitle:SCLocalizedString(@"Share") forState:UIControlStateNormal];
        [_shareButton.titleLabel setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:14]];
        [_shareButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_shareButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(didTouchShareButton) forControlEvents:UIControlEventTouchUpInside];
        [viewToolBar addSubview:_shareButton];
        
        _detailButon = [[UIButton alloc]initWithFrame:CGRectMake(260, 0, 60, 45)];
        [_detailButon setBackgroundColor:[UIColor clearColor]];
        [_detailButon setTitle:SCLocalizedString(@"Detail") forState:UIControlStateNormal];
        [_detailButon setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_detailButon.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_detailButon.titleLabel setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:14]];
        [_detailButon addTarget:self action:@selector(didTouchDetailButton) forControlEvents:UIControlEventTouchUpInside];
        [viewToolBar addSubview:_detailButon];
    }
    return viewToolBar;
}

#pragma mark UIScroll View Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZThemeProductViewController_BeginChangeProduct" object:self];
    [self configureProductViewWithStatus:NO];
    self.currentIndexProductOnArray = self.scrollViewProducts.contentOffset.x/self.widthScrollView;
    for (int i = self.currentIndexProductOnArray - 1; i <= self.currentIndexProductOnArray + 1; i++) {
        if (i >= 0 && i < self.arrayProductsID.count) {
            ZThemeProductView *currentShowProduct = (ZThemeProductView*)[self.arrayProductsView objectAtIndex:i];
            if (!currentShowProduct.isGotProduct) {
                [currentShowProduct getProductDetail];
            }
        }
    }
    
    ZThemeProductView *productView = [_arrayProductsView objectAtIndex:self.currentIndexProductOnArray];
    if (productView.isDidGetProduct) {
        [self setProduct:productView.productModel];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZThemeProductViewController_DidChangeProduct" object:self];
}

#pragma mark Action Touch Button
- (void)didTouchDetailButton
{
    if (hadCurrentProductModel) {
        ZThemeProductDetailViewController *productDetailController = [[ZThemeProductDetailViewController alloc] init];
        [productDetailController setProduct:product];
        [self.navigationController pushViewController:productDetailController animated:YES];
    }
}

- (void)didTouchShareButton
{
     NSURL *productURL = [NSURL URLWithString:@"Hello"];
    if ([product valueForKey:@"product_url"]) {
       productURL = [NSURL URLWithString:[product valueForKey:@"product_url"]];
    }
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[productURL]
                                      applicationActivities:nil];
    [self.navigationController presentViewController:activityViewController
                                       animated:YES
                                     completion:^{
                                         // ...
                                     }];
}

#pragma mark ZThemeProductView Delegate
- (void)didGetProductDetailWithProductID:(NSString *)productID
{
    ZThemeProductView *productView = [_arrayProductsView objectAtIndex:self.currentIndexProductOnArray];
    if ([productView.productID isEqualToString:productID]) {
        if (self.isFirtLoadProduct) {
            [self.viewToolBar setHidden:NO];
            [self.viewAction setHidden:NO];
            self.isFirtLoadProduct = NO;
        }
        [self setProduct:productView.productModel];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ZThemeProductViewController_DidGetProduct" object:self];
    }
}

- (void)touchImage
{
    self.isShowOnlyImage = !self.isShowOnlyImage;
    if (self.isShowOnlyImage) {
        [viewToolBar setHidden:YES];
        [_viewAction setHidden:YES];
    }else
    {
        [viewToolBar setHidden:NO];
        [_viewAction setHidden:NO];
    }
}

#pragma mark Set Data
- (void)setProduct:(SimiProductModel *)product_
{
    if (product_ != nil) {
        product = product_;
        [self configureProductViewWithStatus:YES];
        [_labelProductName setText:[product valueForKey:@"product_name"]];
        NSMutableArray *arrayImage = [product valueForKey:@"product_images"];
        [self.currentImageProduct sd_setImageWithURL:[arrayImage objectAtIndex:0]];
        [self setPrice];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ZThemeProductViewController_DidSetNewProductModel" object:self userInfo:@{@"productmodel":product}];
    }
}

- (void)setPrice
{
    if ([product valueForKey:@"show_price_v2"]) {
        NSDictionary *productPrice = [product valueForKey:@"show_price_v2"] ;
        self.lblExcl.hidden = YES;
        self.lblExclPrice.hidden = YES;
        self.lblIncl.hidden = YES;
        self.lblInclPrice.hidden = YES;
        self.crossLine.hidden = YES;
        float priceOfProduct = 0;
        float priceOfProductIncl = 0;
        if ([[product valueForKey:@"product_type"] isEqualToString:@"bundle"]) {
            if ([productPrice valueForKey:@"product_price_config"]) {
                CGRect frame = self.viewToolBar.frame;
                frame.size.height = 45;
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [self.viewToolBar setFrame:frame];
                                 }
                                 completion:^(BOOL finished) {
                                 }];
                [_lblExclPrice setFrame:CGRectMake(60, 25, 200, 20)];
                [_lblExclPrice setTextAlignment:NSTextAlignmentCenter];
                if ([self.product valueForKey:@"total_option_price"]) {
                    priceOfProduct += [[self.product valueForKey:@"total_option_price"] floatValue];
                }
                priceOfProduct += [[productPrice valueForKey:@"product_price_config"] floatValue];
                [_lblExclPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceOfProduct]]];
                [_lblExclPrice setHidden:NO];
                return;
            }
            
            if ([productPrice valueForKey:@"excl_tax_config"] &&[productPrice valueForKey:@"incl_tax_config"]) {
                int sumWidthPrice = 0;
                int sumWidthTitle = 0;
                [_lblExcl setFrame:CGRectMake(60, 25, 50, 20)];
                [_lblExcl setTextAlignment:NSTextAlignmentLeft];
                [_lblExcl setText:[NSString stringWithFormat:@"%@:",SCLocalizedString(@"Excl.Tax")]];
                [_lblExcl setHidden:NO];
                sumWidthTitle += [self.lblExcl.text sizeWithAttributes:@{NSFontAttributeName:[self.lblExcl font]}].width;
                
                [_lblExclPrice setFrame:CGRectMake(110, 25, 50, 20)];
                [_lblExclPrice setTextAlignment:NSTextAlignmentLeft];
                if ([self.product valueForKey:@"total_option_price"]) {
                    priceOfProduct += [[self.product valueForKey:@"total_option_price"] floatValue];
                }
                priceOfProduct+= [[productPrice valueForKey:@"excl_tax_config"] floatValue];
                [_lblExclPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceOfProduct]]];
                [_lblExclPrice setHidden:NO];
                sumWidthPrice += [self.lblExclPrice.text sizeWithAttributes:@{NSFontAttributeName:[self.lblExclPrice font]}].width;
                
                [_lblIncl setFrame:CGRectMake(160, 25, 50, 20)];
                [_lblIncl setTextAlignment:NSTextAlignmentLeft];
                [_lblIncl setText:[NSString stringWithFormat:@"%@:",SCLocalizedString(@"Incl.Tax")]];
                [_lblIncl setHidden:NO];
                sumWidthTitle += [self.lblIncl.text sizeWithAttributes:@{NSFontAttributeName:[self.lblIncl font]}].width;
                
                [_lblInclPrice setFrame:CGRectMake(210, 25, 50, 20)];
                [_lblInclPrice setTextAlignment:NSTextAlignmentLeft];
                if ([self.product valueForKey:@"total_option_price_incl_tax"]) {
                    priceOfProductIncl = [[self.product valueForKey:@"total_option_price_incl_tax"] floatValue];
                }
                priceOfProductIncl += [[productPrice valueForKey:@"incl_tax_config"] floatValue];
                [_lblInclPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceOfProductIncl]]];
                [_lblInclPrice setHidden:NO];
                sumWidthPrice += [self.lblInclPrice.text sizeWithAttributes:@{NSFontAttributeName:[self.lblInclPrice font]}].width;
                CGRect frame = self.viewToolBar.frame;
                //  Liam Update RTL
                if([[SimiGlobalVar sharedInstance]isReverseLanguage])
                {
                    [_lblExcl setText:[NSString stringWithFormat:@":%@",SCLocalizedString(@"Excl.Tax")]];
                    [_lblIncl setText:[NSString stringWithFormat:@":%@",SCLocalizedString(@"Incl.Tax")]];
                    [_lblExcl setFrame:CGRectMake(210, 25, 50, 20)];
                    [_lblExclPrice setFrame:CGRectMake(160, 25, 50, 20)];
                    [_lblIncl setFrame:CGRectMake(110, 25, 50, 20)];
                    [_lblInclPrice setFrame:CGRectMake(60, 25, 50, 20)];
                    [_lblExcl setTextAlignment:NSTextAlignmentRight];
                    [_lblIncl setTextAlignment:NSTextAlignmentRight];
                    [_lblExclPrice setTextAlignment:NSTextAlignmentRight];
                    [_lblInclPrice setTextAlignment:NSTextAlignmentRight];
                }
                //  End RTL
                if (sumWidthPrice >= 100 || sumWidthTitle >= 100 ) {
                    [_lblExcl setFrame:CGRectMake(60, 25, 90, 15)];
                    [_lblExclPrice setFrame:CGRectMake(150, 25, 110, 15)];
                    [_lblIncl setFrame:CGRectMake(60, 40, 90, 15)];
                    [_lblInclPrice setFrame:CGRectMake(150, 40, 110, 15)];
                    //  Liam Update RTL
                    if([[SimiGlobalVar sharedInstance]isReverseLanguage])
                    {
                        [_lblExcl setFrame:CGRectMake(170, 25, 90, 15)];
                        [_lblExclPrice setFrame:CGRectMake(60, 25, 110, 15)];
                        [_lblIncl setFrame:CGRectMake(170, 40, 90, 15)];
                        [_lblInclPrice setFrame:CGRectMake(60, 40, 110, 15)];
                    }
                    //  End RTL
                    frame.size.height = 55;
                    [UIView animateWithDuration:0.2
                                          delay:0
                                        options:UIViewAnimationOptionCurveEaseOut
                                     animations:^{
                                         [self.viewToolBar setFrame:frame];
                                     }
                                     completion:^(BOOL finished) {
                                     }];
                    
                }else
                {
                    frame.size.height = 45;
                    [UIView animateWithDuration:0.2
                                          delay:0
                                        options:UIViewAnimationOptionCurveEaseOut
                                     animations:^{
                                         [self.viewToolBar setFrame:frame];
                                     }
                                     completion:^(BOOL finished) {
                                     }];
                }
                return;
            }
        }else
        {
            if ([productPrice valueForKey:@"excl_tax"] && [productPrice valueForKey:@"incl_tax"]) {
                int sumWidthPrice = 0;
                int sumWidthTitle = 0;
                [_lblExcl setFrame:CGRectMake(60, 25, 50, 20)];
                [_lblExcl setTextAlignment:NSTextAlignmentLeft];
                [_lblExcl setText:[NSString stringWithFormat:@"%@:",SCLocalizedString(@"Excl.Tax")]];
                [_lblExcl setHidden:NO];
                sumWidthTitle += [self.lblExcl.text sizeWithAttributes:@{NSFontAttributeName:[self.lblExcl font]}].width;
                
                [_lblExclPrice setFrame:CGRectMake(110, 25, 50, 20)];
                [_lblExclPrice setTextAlignment:NSTextAlignmentLeft];
                if ([productPrice valueForKey:@"total_option_price"]) {
                    priceOfProduct += [[productPrice valueForKey:@"total_option_price"] floatValue] ;
                }
                priceOfProduct += [[productPrice valueForKey:@"excl_tax"] floatValue];
                [_lblExclPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceOfProduct]]];
                [_lblExclPrice setHidden:NO];
                sumWidthPrice += [self.lblExclPrice.text sizeWithAttributes:@{NSFontAttributeName:[self.lblExclPrice font]}].width;
                
                [_lblIncl setFrame:CGRectMake(160, 25, 50, 20)];
                [_lblIncl setTextAlignment:NSTextAlignmentLeft];
                [_lblIncl setText:[NSString stringWithFormat:@"%@:",SCLocalizedString(@"Incl.Tax")]];
                [_lblIncl setHidden:NO];
                sumWidthTitle += [self.lblIncl.text sizeWithAttributes:@{NSFontAttributeName:[self.lblIncl font]}].width;
                
                [_lblInclPrice setFrame:CGRectMake(210, 25, 50, 20)];
                [_lblInclPrice setTextAlignment:NSTextAlignmentLeft];
                if ([self.product valueForKey:@"total_option_price_incl_tax"]) {
                    priceOfProductIncl += [[self.product valueForKey:@"total_option_price_incl_tax"] floatValue];
                }
                priceOfProductIncl += [[productPrice valueForKey:@"incl_tax"] floatValue];
                [_lblInclPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceOfProductIncl]]];
                [_lblInclPrice setHidden:NO];
                sumWidthPrice += [self.lblInclPrice.text sizeWithAttributes:@{NSFontAttributeName:[self.lblInclPrice font]}].width;
                //  Liam Update RTL
                if([[SimiGlobalVar sharedInstance]isReverseLanguage])
                {
                    [_lblExcl setText:[NSString stringWithFormat:@":%@",SCLocalizedString(@"Excl.Tax")]];
                    [_lblIncl setText:[NSString stringWithFormat:@":%@",SCLocalizedString(@"Incl.Tax")]];
                    [_lblExcl setFrame:CGRectMake(210, 25, 50, 20)];
                    [_lblExclPrice setFrame:CGRectMake(160, 25, 50, 20)];
                    [_lblIncl setFrame:CGRectMake(110, 25, 50, 20)];
                    [_lblInclPrice setFrame:CGRectMake(60, 25, 50, 20)];
                    [_lblExcl setTextAlignment:NSTextAlignmentRight];
                    [_lblIncl setTextAlignment:NSTextAlignmentRight];
                    [_lblExclPrice setTextAlignment:NSTextAlignmentRight];
                    [_lblInclPrice setTextAlignment:NSTextAlignmentRight];
                }
                //  End RTL
                CGRect frame = self.viewToolBar.frame;
                if (sumWidthPrice >= 100 || sumWidthTitle >= 100 ) {
                    [_lblExcl setFrame:CGRectMake(60, 25, 90, 15)];
                    [_lblExclPrice setFrame:CGRectMake(150, 25, 110, 15)];
                    [_lblIncl setFrame:CGRectMake(60, 40, 90, 15)];
                    [_lblInclPrice setFrame:CGRectMake(150, 40, 110, 15)];
                    //  Liam Update RTL
                    if([[SimiGlobalVar sharedInstance]isReverseLanguage])
                    {
                        [_lblExcl setFrame:CGRectMake(170, 25, 90, 15)];
                        [_lblExclPrice setFrame:CGRectMake(60, 25, 110, 15)];
                        [_lblIncl setFrame:CGRectMake(170, 40, 90, 15)];
                        [_lblInclPrice setFrame:CGRectMake(60, 40, 110, 15)];
                    }
                    //  End RTL
                    frame.size.height = 55;
                    [UIView animateWithDuration:0.2
                                          delay:0
                                        options:UIViewAnimationOptionCurveEaseOut
                                     animations:^{
                                         [self.viewToolBar setFrame:frame];
                                     }
                                     completion:^(BOOL finished) {
                                     }];
                }else
                {
                    frame.size.height = 45;
                    [UIView animateWithDuration:0.2
                                          delay:0
                                        options:UIViewAnimationOptionCurveEaseOut
                                     animations:^{
                                         [self.viewToolBar setFrame:frame];
                                     }
                                     completion:^(BOOL finished) {
                                     }];
                }
                return;
            }
            
            if ([productPrice valueForKey:@"product_regular_price"]) {
                CGRect frame = self.viewToolBar.frame;
                frame.size.height = 45;
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [self.viewToolBar setFrame:frame];
                                 }
                                 completion:^(BOOL finished) {
                                 }];
                if ([productPrice valueForKey:@"product_price"]) {
                    [_lblExclPrice setFrame:CGRectMake(60, 25, 100, 20)];
                    [_lblExclPrice setTextAlignment:NSTextAlignmentCenter];
                    if ([self.product valueForKey:@"total_option_price"]) {
                        priceOfProduct += [[self.product valueForKey:@"total_option_price"] floatValue];
                    }
                    priceOfProduct += [[productPrice valueForKey:@"product_regular_price"] floatValue];
                    [_lblExclPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceOfProduct]]];
                    [_lblExclPrice setHidden:NO];
                    
                    CGFloat priceWidth = [self.lblExclPrice.text sizeWithAttributes:@{NSFontAttributeName:[self.lblExclPrice font]}].width;
                    [self.crossLine setFrame:CGRectMake(self.lblExclPrice.frame.origin.x + (CGRectGetWidth(self.lblExclPrice.frame) - priceWidth)/2 , self.lblExclPrice.center.y, priceWidth, 1)];
                    [self.crossLine setHidden:NO];
                    
                    [_lblInclPrice setFrame:CGRectMake(160, 25, 100, 20)];
                    [_lblInclPrice setTextAlignment:NSTextAlignmentCenter];
                    if ([self.product valueForKey:@"total_option_price"]) {
                        priceOfProductIncl += [[self.product valueForKey:@"total_option_price"] floatValue];
                    }
                    priceOfProductIncl += [[productPrice valueForKey:@"product_price"] floatValue];

                    [_lblInclPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceOfProductIncl]]];
                    [_lblInclPrice setHidden:NO];
                    return;
                }
                
                [_lblExclPrice setFrame:CGRectMake(60, 25, 200, 20)];
                [_lblExclPrice setTextAlignment:NSTextAlignmentCenter];
                if ([self.product valueForKey:@"total_option_price"]) {
                    priceOfProduct += [[self.product valueForKey:@"total_option_price"] floatValue];
                }
                priceOfProduct += [[productPrice valueForKey:@"product_regular_price"] floatValue];
                [_lblExclPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceOfProduct]]];
                [_lblExclPrice setHidden:NO];
            }
        }
    }
}

#pragma mark Configure Interface
- (void)configureProductViewWithStatus:(BOOL)isStatus // Yes: had ProductModel
{
    if (isStatus) {
        self.hadCurrentProductModel = YES;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *productCollection = [[NSMutableArray alloc]initWithArray:[defaults valueForKey:@"Recent Products"]];
        if (productCollection == nil) {
            productCollection = [NSMutableArray new];
        }
        
        NSMutableDictionary *simpleProductData = [NSMutableDictionary new];
        [simpleProductData setValue:[product valueForKey:@"product_id"] forKey:@"product_id"];
        [simpleProductData setValue:[product valueForKey:@"product_images"] forKey:@"product_images"];
        
        if ([productCollection containsObject:simpleProductData]) {
            [productCollection removeObject:simpleProductData];
            NSMutableArray *productCollectionTemp = [productCollection mutableCopy];
            [productCollection removeAllObjects];
            [productCollection addObject:simpleProductData];
            for (int i = 0; i < (int)productCollectionTemp.count; i++) {
                [productCollection addObject:[productCollectionTemp objectAtIndex:i]];
            }
        }else
        {
            if (productCollection.count == 10) {
                [productCollection removeObjectAtIndex:9];
            }
            NSMutableArray *productCollectionTemp = [productCollection mutableCopy];
            [productCollection removeAllObjects];
            [productCollection addObject:simpleProductData];
            for (int i = 0; i < (int)productCollectionTemp.count; i++) {
                [productCollection addObject:[productCollectionTemp objectAtIndex:i]];
            }
        }
        [defaults setObject:productCollection forKey:@"Recent Products"];
        [defaults synchronize];
        
        [self convertOptionToDictFromArray:[product valueForKey:@"options"]];
        [self sortOption];
        self.selectedOptionPrice = [NSMutableDictionary new];
        numberOfRequired = [self countNumberOfRequired];
        if (self.allKeys.count > 0) {
            if (CGRectGetWidth(self.buttonAddToCart.frame) != 130) {
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [self.buttonAddToCart setFrame:CGRectMake(170, 0, 130, 40)];
                                 }
                                 completion:^(BOOL finished) {
                                 }];
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [self.buttonSelectOption setHidden:NO];
                                     [self.buttonSelectOption setFrame:CGRectMake(20, 0, 130, 40)];
                                 }
                                 completion:^(BOOL finished) {
                                 }];
            }
            
            
            self.buttonAddToCart.alpha = 1.0;
            self.buttonSelectOption.alpha = 1.0;
            [self.buttonAddToCart setEnabled:YES];
            [self.buttonSelectOption setEnabled:YES];
        }else
        {
            [self.buttonSelectOption setHidden:YES];
            if (CGRectGetWidth(self.buttonAddToCart.frame) != 280) {
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [self.buttonAddToCart setFrame:CGRectMake(20, 0, 280, 40)];
                                 }
                                 completion:^(BOOL finished) {
                                 }];
            }
            self.buttonAddToCart.alpha = 1.0;
            [self.buttonAddToCart setEnabled:YES];
        }
        
        [self.buttonAddToCart setTitle:SCLocalizedString(@"Add To Cart") forState:UIControlStateNormal];
        if (![[product valueForKey:@"stock_status"] boolValue]) {
            [self.buttonAddToCart setTitle:SCLocalizedString(@"Out Stock") forState:UIControlStateNormal];
            [self.buttonAddToCart setEnabled:NO];
            [self.buttonAddToCart setAlpha:0.5];
        }
        
        [self.shareButton setEnabled:YES];
        [self.detailButon setEnabled:YES];
        self.shareButton.alpha = 1.0;
        self.detailButon.alpha = 1.0;
    }else
    {
        [self.shareButton setEnabled:NO];
        [self.detailButon setEnabled:NO];
        [self.buttonAddToCart setEnabled:NO];
        [self.buttonSelectOption setEnabled:NO];
        
        self.buttonSelectOption.alpha = 0.5;
        self.shareButton.alpha = 0.5;
        self.buttonAddToCart.alpha = 0.5;
        self.detailButon.alpha = 0.5;
    }
}

#pragma mark Selection & Add To Cart
- (void)addToCart
{
    if ((self.optionDict.count > 0 && [self isCheckedAllRequiredOptions]) || (self.optionDict.count == 0)) {
        //Create animation
        UIImageView *thumnailView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 100, 300, 400)];
        thumnailView.image = self.currentImageProduct.image;
        [thumnailView setContentMode:UIViewContentModeScaleAspectFit];
        [self.view addSubview:thumnailView];
        [UIView animateWithDuration:0.6
                              delay:0
                            options:UIViewAnimationOptionAllowAnimatedContent
                         animations:^{
                             thumnailView.frame = CGRectMake(260, 0, 60, 90);
                             thumnailView.transform = CGAffineTransformMakeRotation(140);
                         }
                         completion:^(BOOL finished){
                             [thumnailView removeFromSuperview];
                         }];
        [self startLoadingData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddToCart" object:nil userInfo:@{@"data":self.product, @"optionDict":self.optionDict, @"allKeys":self.allKeys}];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidAddToCart" object:nil];
    }else{
        [self buttonSelectOptionTouch:self.buttonSelectOption];
    }
}

- (void)buttonSelectOptionTouch:(id)sender
{
    if (_optionViewController == nil) {
        _optionViewController = [ZThemeProductOptionViewController new];
        _optionViewController.tableViewOption.showsVerticalScrollIndicator = NO;
        _optionViewController.delegate = self;
    }
    _optionViewController.allKeys = self.allKeys;
    _optionViewController.optionDict = self.optionDict;
    _optionViewController.product = self.product;
    _optionViewController.selectedOptionPrice = self.selectedOptionPrice;
    
    if (optionPopoverController == nil)
    {
        UIView *btn = (UIView *)sender;
        optionPopoverController = [[WYPopoverController alloc] initWithContentViewController:_optionViewController];
        optionPopoverController.delegate = self;
        optionPopoverController.passthroughViews = @[btn];
        optionPopoverController.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
        optionPopoverController.wantsDefaultContentAppearance = NO;
        [optionPopoverController setPopoverContentSize:CGSizeMake(300, 400)];
        optionPopoverController.noDismissWhenTouchBackgroud = YES;
        [optionPopoverController presentPopoverFromRect:btn.bounds
                                               inView:btn
                             permittedArrowDirections:WYPopoverArrowDirectionDown
                                             animated:YES
                                              options:WYPopoverAnimationOptionFadeWithScale];
    }
    else
    {
        [self doneButtonTouch];
    }
}

- (void)close:(id)sender
{
    [optionPopoverController dismissPopoverAnimated:YES completion:^{
        [self sortPopupControllerDidDismissPopover:optionPopoverController];
    }];
}

#pragma mark - WYPopoverControllerDelegate
- (void)popoverControllerDidPresentPopover:(WYPopoverController *)controller
{
    
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    [self sortPopupControllerDidDismissPopover:optionPopoverController];
    return YES;
}

- (void)sortPopupControllerDidDismissPopover:(WYPopoverController *)controller
{
    if (controller == optionPopoverController)
    {
        optionPopoverController.delegate = nil;
        optionPopoverController = nil;
    }
}

- (BOOL)popoverControllerShouldIgnoreKeyboardBounds:(WYPopoverController *)popoverController
{
    return YES;
}

- (void)popoverController:(WYPopoverController *)popoverController willTranslatePopoverWithYOffset:(float *)value
{
    // keyboard is shown and the popover will be moved up by 163 pixels for example ( *value = 163 )
    *value = 0; // set value to 0 if you want to avoid the popover to be moved
}

#pragma mark Option Delegate
- (void)cancelButtonTouch
{
    [self close:nil];
    [self convertOptionToDictFromArray:[product valueForKey:@"options"]];
    [self sortOption];
    self.selectedOptionPrice = [NSMutableDictionary new];
}

- (void)doneButtonTouch
{
    [self close:nil];
    CGFloat price = [[self.product valueForKey:@"product_price"] floatValue];
    switch (self.product.productType) {
        case ProductTypeGrouped:
            price = 0;
            break;
        default:
            break;
    }
    CGFloat totalOptionPrice = 0;
    CGFloat totalOptionPriceInclTax = 0;
    for (NSString *tempKey in self.allKeys) {
        CGFloat optionPrice = 0;
        CGFloat optionPriceInclTax = 0;
        BOOL isSelected = NO;
        for (NSDictionary *opt in [self.optionDict valueForKey:tempKey]) {
            if ([[opt valueForKey:@"is_selected"] boolValue]) {
                if (self.product.productType == ProductTypeGrouped) {
                    optionPrice += [[opt valueForKey:@"option_price"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                    if([opt valueForKey:@"option_price_incl_tax"]){
                        optionPriceInclTax += [[opt valueForKey:@"option_price_incl_tax"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                    }else if([opt valueForKey:@"option_price"]){
                        optionPriceInclTax += [[opt valueForKey:@"option_price"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                    }
                }else{
                    CGFloat optionQty = 1.0f;
                    if ([[opt valueForKey:@"option_qty"] floatValue] > 0.01f) {
                        optionQty = [[opt valueForKey:@"option_qty"] floatValue];
                    }
                    optionPrice += optionQty * [[opt valueForKey:@"option_price"] floatValue];
                    if([opt valueForKey:@"option_price_incl_tax"]){
                        optionPriceInclTax += optionQty * [[opt valueForKey:@"option_price_incl_tax"] floatValue];
                    }else if([opt valueForKey:@"option_price"]){
                        optionPriceInclTax += optionQty * [[opt valueForKey:@"option_price"] floatValue];
                    }
                }
                isSelected = YES;
            }
        }
        if (isSelected) {
            [self.selectedOptionPrice setValue:[NSString stringWithFormat:@"%.2f", optionPrice] forKey:tempKey];
        }else{
            [self.selectedOptionPrice removeObjectForKey:tempKey];
        }
        price += optionPrice;
        totalOptionPrice += optionPrice;
        totalOptionPriceInclTax += optionPriceInclTax;
    }
    
    //Set product price
    [self.product setValue:[NSString stringWithFormat:@"%.2f", price] forKey:@"option_product_price"];
    [self.product setValue:[NSString stringWithFormat:@"%.2f", totalOptionPrice] forKey:@"total_option_price"];
    [self.product setValue:[NSString stringWithFormat:@"%.2f", totalOptionPriceInclTax] forKey:@"total_option_price_incl_tax"];
    [self setPrice];
}
@end
