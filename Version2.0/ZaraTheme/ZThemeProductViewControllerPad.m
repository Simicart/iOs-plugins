//
//  ZThemeProductViewControllerPad.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 6/2/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeProductViewControllerPad.h"
#import "ZThemeWorker.h"

@interface ZThemeProductViewControllerPad ()

@end

@implementation ZThemeProductViewControllerPad
{
    UIPopoverController * productOptionPopOver;
    UIScrollView * invisibleScrollView;
    UIView * leftFog;
    UIView * rightFog;
    CGPoint currentScollviewContentOffset;
}


#pragma mark Init
- (void)viewDidLoadBefore
{
    [self setNavigationBarOnViewDidLoadForZTheme];
    
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    [self.navigationItem setTitle:SCLocalizedString(@"Product")];
    self.arrayProductsView = [NSMutableArray new];
    self.heightScrollView = 750;
    self.widthScrollView = 624;
    
    self.scrollViewProducts = [[UIScrollView alloc]initWithFrame:CGRectMake(0, -20, 1024, 808)];
    [self.scrollViewProducts setContentSize:CGSizeMake(self.widthScrollView * self.arrayProductsID.count + 400, self.heightScrollView)];
    if(self.firstProductID == nil || [self.firstProductID isEqualToString:@""])
    {
        self.firstProductID = self.productId;
        self.arrayProductsID = [[NSMutableArray alloc]initWithArray:@[self.productId]];
    }
    for (int i = 0; i < self.arrayProductsID.count; i++) {
        ZThemeProductView *productView = [[ZThemeProductView alloc]initWithFrame:CGRectMake(self.widthScrollView *i + 205, 0, self.widthScrollView -10 , self.heightScrollView) productID:[self.arrayProductsID objectAtIndex:i]];
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
    [self.scrollViewProducts setPagingEnabled:NO];
    [self.scrollViewProducts setDelegate:self];
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
    
    
    
    invisibleScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(200, -20, 624, 788)];
    [invisibleScrollView setContentSize:CGSizeMake(self.widthScrollView * self.arrayProductsID.count, self.heightScrollView)];
    
    [invisibleScrollView setDelegate:self];
    [invisibleScrollView setContentOffset:CGPointMake(self.currentIndexProductOnArray*self.widthScrollView, 0) animated:NO];
    invisibleScrollView.userInteractionEnabled = NO;
    invisibleScrollView.pagingEnabled = YES;
    [self.scrollViewProducts addGestureRecognizer:invisibleScrollView.panGestureRecognizer];
    [self.view addSubview:invisibleScrollView];
    
    [self addSideFog];
    [self viewToolBar];
    [self.view addSubview: self.viewToolBar];
    [self addActionViews];
    
    [self.viewAction setHidden:YES];
    [self.viewToolBar setHidden:YES];
    self.isFirtLoadProduct = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZThemeProductViewControllerPad_DidLoadBefore" object:self userInfo:@{@"viewAction": self.viewAction}];
}

- (void)viewWillAppearBefore:(BOOL)animated{
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.leftBarButtonItems = [[[ZThemeWorker  sharedInstance]navigationBarPad]leftButtonItems];
    self.navigationItem.rightBarButtonItems = [[[ZThemeWorker sharedInstance]navigationBarPad]rightButtonItems];
}

#pragma mark SideFog
- (void) addSideFog
{
    if (leftFog == nil) {
        leftFog = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 768)];
        [leftFog setBackgroundColor:[UIColor whiteColor]];
        [leftFog setAlpha:0.8];
        [self.view addSubview:leftFog];
        
        rightFog = [[UIView alloc]initWithFrame:CGRectMake(824, 0, 200, 768)];
        [rightFog setBackgroundColor:[UIColor whiteColor]];
        [rightFog setAlpha:0.8];
        [self.view addSubview:rightFog];
    }
    [leftFog setHidden:NO];
    [rightFog setHidden:NO];
}

- (void) removeSideFog
{
    [leftFog setHidden:YES];
    [rightFog setHidden:YES];
}

#pragma mark add Action views
- (void) addActionViews
{
    self.viewAction = [[UIView alloc]initWithFrame:CGRectMake(0, 600, CGRectGetWidth(self.view.frame), 40)];
    [self.viewAction setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.viewAction];
    
    self.buttonAddToCart = [[UIButton alloc]initWithFrame:CGRectMake(510, 0, 150, 50)];
    [self.buttonAddToCart setTitle:SCLocalizedString(@"Add To Cart") forState:UIControlStateNormal];
    [self.buttonAddToCart addTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonAddToCart setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buttonAddToCart.backgroundColor = ZTHEME_BTN_ADD_TO_CART_COLOR;
    self.buttonAddToCart.layer.masksToBounds = YES;
    self.buttonAddToCart.layer.cornerRadius = 4.0;
    [self.viewAction addSubview:self.buttonAddToCart];
    
    self.buttonSelectOption = [[UIButton alloc]initWithFrame:CGRectMake(340, 0, 150, 50)];
    [self.buttonSelectOption addTarget:self action:@selector(buttonSelectOptionTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonSelectOption setTitle:SCLocalizedString(@"Option") forState:UIControlStateNormal];
    [self.buttonSelectOption setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buttonSelectOption.backgroundColor = [UIColor grayColor];
    self.buttonSelectOption.layer.masksToBounds = YES;
    self.buttonSelectOption.layer.cornerRadius = 4.0;
    [self.viewAction addSubview:self.buttonSelectOption];
}

#pragma mark ViewToolBar

- (UIView *)viewToolBar
{
    UIView * toolBar = [super viewToolBar];
    
    [self.labelProductName setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:18]];
    [self.labelProductName setText:[self.labelProductName.text uppercaseString]];
    [self.labelProductName setFrame:CGRectMake(250, 0, 524, 25)];
    [self.labelProductName setTextAlignment:NSTextAlignmentCenter];
    
    [self.shareButton setFrame:CGRectMake(50, 0, 100, 45)];
    [self.shareButton.titleLabel setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:18]];
    [self.shareButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.detailButon setFrame:CGRectMake(884, 0, 100, 45)];
    [self.detailButon.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.detailButon.titleLabel setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:18]];
    
    return  toolBar;
}

#pragma mark UIScroll View Delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if((invisibleScrollView == scrollView)&&(!CGPointEqualToPoint(invisibleScrollView.contentOffset, currentScollviewContentOffset)))
    {
        currentScollviewContentOffset = invisibleScrollView.contentOffset;
        self.scrollViewProducts.contentOffset = invisibleScrollView.contentOffset;
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZThemeProductViewController_BeginChangeProduct" object:self];
    [self configureProductViewWithStatus:NO];
    self.currentIndexProductOnArray = (invisibleScrollView.contentOffset.x)/self.widthScrollView;
    for (int i = self.currentIndexProductOnArray - 1; i <= self.currentIndexProductOnArray + 1; i++) {
        if (i >= 0 && i < self.arrayProductsID.count) {
            ZThemeProductView *currentShowProduct = (ZThemeProductView*)[self.arrayProductsView objectAtIndex:i];
            if (!currentShowProduct.isGotProduct) {
                [currentShowProduct getProductDetail];
            }
        }
    }
    
    ZThemeProductView *productView = [self.arrayProductsView objectAtIndex:self.currentIndexProductOnArray];
    if (productView.isDidGetProduct) {
        [self setProduct:productView.productModel];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZThemeProductViewControllerPad_DidChangeProduct" object:self];
}

#pragma mark Configure Interface

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
        [simpleProductData setValue:[self.product valueForKey:@"product_id"] forKey:@"product_id"];
        [simpleProductData setValue:[self.product valueForKey:@"product_images"] forKey:@"product_images"];
        
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
        
        [self convertOptionToDictFromArray:[self.product valueForKey:@"options"]];
        [self sortOption];
        self.selectedOptionPrice = [NSMutableDictionary new];
        self.numberOfRequired = [self countNumberOfRequired];
        if (self.allKeys.count > 0) {
            if (CGRectGetWidth(self.buttonAddToCart.frame) != 130) {
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [self.buttonAddToCart setFrame:CGRectMake(510, 0, 150, 50)];
                                 }
                                 completion:^(BOOL finished) {
                                 }];
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [self.buttonSelectOption setHidden:NO];
                                     [self.buttonSelectOption setFrame:CGRectMake(340, 0, 150, 50)];
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
                                     [self.buttonAddToCart setFrame:CGRectMake(340, 0, 320, 50)];
                                 }
                                 completion:^(BOOL finished) {
                                 }];
            }
            self.buttonAddToCart.alpha = 1.0;
            [self.buttonAddToCart setEnabled:YES];
        }
        
        [self.buttonAddToCart setTitle:SCLocalizedString(@"Add To Cart") forState:UIControlStateNormal];
        if (![[self.product valueForKey:@"stock_status"] boolValue]) {
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

- (void)touchImage
{
    self.isShowOnlyImage = !self.isShowOnlyImage;
    if (self.isShowOnlyImage) {
        [self.viewToolBar setHidden:YES];
        [self.viewAction setHidden:YES];
        [self removeSideFog];
    }else
    {
        [self.viewToolBar setHidden:NO];
        [self.viewAction setHidden:NO];
        [self addSideFog];
    }
}

#pragma mark Set Price


- (void)setPrice
{
    if ([self.product valueForKey:@"show_price_v2"]) {
        NSDictionary *productPrice = [self.product valueForKey:@"show_price_v2"] ;
        self.lblExcl.hidden = YES;
        self.lblExclPrice.hidden = YES;
        self.lblIncl.hidden = YES;
        self.lblInclPrice.hidden = YES;
        self.crossLine.hidden = YES;
        float priceOfProduct = 0;
        float priceOfProductIncl = 0;
        if ([[self.product valueForKey:@"product_type"] isEqualToString:@"bundle"]) {
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
                [self.lblExclPrice setFrame:CGRectMake(410, 25, 200, 20)];
                [self.lblExclPrice setTextAlignment:NSTextAlignmentCenter];
                if ([self.product valueForKey:@"total_option_price"]) {
                    priceOfProduct += [[self.product valueForKey:@"total_option_price"] floatValue];
                }
                priceOfProduct += [[productPrice valueForKey:@"product_price_config"] floatValue];
                [self.lblExclPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceOfProduct]]];
                [self.lblExclPrice setHidden:NO];
                return;
            }
            
            if ([productPrice valueForKey:@"excl_tax_config"] &&[productPrice valueForKey:@"incl_tax_config"]) {
                int sumWidthPrice = 0;
                int sumWidthTitle = 0;
                [self.lblExcl setFrame:CGRectMake(410, 25, 50, 20)];
                [self.lblExcl setTextAlignment:NSTextAlignmentLeft];
                [self.lblExcl setText:[NSString stringWithFormat:@"%@:",SCLocalizedString(@"Excl.Tax")]];
                [self.lblExcl setHidden:NO];
                sumWidthTitle += [self.lblExcl.text sizeWithAttributes:@{NSFontAttributeName:[self.lblExcl font]}].width;
                
                [self.lblExclPrice setFrame:CGRectMake(460, 25, 50, 20)];
                [self.lblExclPrice setTextAlignment:NSTextAlignmentLeft];
                if ([self.product valueForKey:@"total_option_price"]) {
                    priceOfProduct += [[self.product valueForKey:@"total_option_price"] floatValue];
                }
                priceOfProduct+= [[productPrice valueForKey:@"excl_tax_config"] floatValue];
                [self.lblExclPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceOfProduct]]];
                [self.lblExclPrice setHidden:NO];
                sumWidthPrice += [self.lblExclPrice.text sizeWithAttributes:@{NSFontAttributeName:[self.lblExclPrice font]}].width;
                
                [self.lblIncl setFrame:CGRectMake(510, 25, 50, 20)];
                [self.lblIncl setTextAlignment:NSTextAlignmentLeft];
                [self.lblIncl setText:[NSString stringWithFormat:@"%@:",SCLocalizedString(@"Incl.Tax")]];
                [self.lblIncl setHidden:NO];
                sumWidthTitle += [self.lblIncl.text sizeWithAttributes:@{NSFontAttributeName:[self.lblIncl font]}].width;
                
                [self.lblInclPrice setFrame:CGRectMake(560, 25, 50, 20)];
                [self.lblInclPrice setTextAlignment:NSTextAlignmentLeft];
                if ([self.product valueForKey:@"total_option_price_incl_tax"]) {
                    priceOfProductIncl = [[self.product valueForKey:@"total_option_price_incl_tax"] floatValue];
                }
                priceOfProductIncl += [[productPrice valueForKey:@"incl_tax_config"] floatValue];
                [self.lblInclPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceOfProductIncl]]];
                [self.lblInclPrice setHidden:NO];
                sumWidthPrice += [self.lblInclPrice.text sizeWithAttributes:@{NSFontAttributeName:[self.lblInclPrice font]}].width;
                CGRect frame = self.viewToolBar.frame;
                if (sumWidthPrice >= 100 || sumWidthTitle >= 100 ) {
                    [self.lblExcl setFrame:CGRectMake(410, 25, 90, 15)];
                    [self.lblExclPrice setFrame:CGRectMake(500, 25, 110, 15)];
                    [self.lblIncl setFrame:CGRectMake(410, 40, 90, 15)];
                    [self.lblInclPrice setFrame:CGRectMake(500, 40, 110, 15)];
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
                [self.lblExcl setFrame:CGRectMake(410, 25, 50, 20)];
                [self.lblExcl setTextAlignment:NSTextAlignmentLeft];
                [self.lblExcl setText:[NSString stringWithFormat:@"%@:",SCLocalizedString(@"Excl.Tax")]];
                [self.lblExcl setHidden:NO];
                sumWidthTitle += [self.lblExcl.text sizeWithAttributes:@{NSFontAttributeName:[self.lblExcl font]}].width;
                
                [self.lblExclPrice setFrame:CGRectMake(460, 25, 50, 20)];
                [self.lblExclPrice setTextAlignment:NSTextAlignmentLeft];
                if ([productPrice valueForKey:@"total_option_price"]) {
                    priceOfProduct += [[productPrice valueForKey:@"total_option_price"] floatValue] ;
                }
                priceOfProduct += [[productPrice valueForKey:@"excl_tax"] floatValue];
                [self.lblExclPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceOfProduct]]];
                [self.lblExclPrice setHidden:NO];
                sumWidthPrice += [self.lblExclPrice.text sizeWithAttributes:@{NSFontAttributeName:[self.lblExclPrice font]}].width;
                
                [self.lblIncl setFrame:CGRectMake(510, 25, 50, 20)];
                [self.lblIncl setTextAlignment:NSTextAlignmentLeft];
                [self.lblIncl setText:[NSString stringWithFormat:@"%@:",SCLocalizedString(@"Incl.Tax")]];
                [self.lblIncl setHidden:NO];
                sumWidthTitle += [self.lblIncl.text sizeWithAttributes:@{NSFontAttributeName:[self.lblIncl font]}].width;
                
                [self.lblInclPrice setFrame:CGRectMake(560, 25, 50, 20)];
                [self.lblInclPrice setTextAlignment:NSTextAlignmentLeft];
                if ([self.product valueForKey:@"total_option_price_incl_tax"]) {
                    priceOfProductIncl += [[self.product valueForKey:@"total_option_price_incl_tax"] floatValue];
                }
                priceOfProductIncl += [[productPrice valueForKey:@"incl_tax"] floatValue];
                [self.lblInclPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceOfProductIncl]]];
                [self.lblInclPrice setHidden:NO];
                sumWidthPrice += [self.lblInclPrice.text sizeWithAttributes:@{NSFontAttributeName:[self.lblInclPrice font]}].width;
                CGRect frame = self.viewToolBar.frame;
                if (sumWidthPrice >= 100 || sumWidthTitle >= 100 ) {
                    [self.lblExcl setFrame:CGRectMake(410, 25, 90, 15)];
                    [self.lblExclPrice setFrame:CGRectMake(500, 25, 110, 15)];
                    [self.lblIncl setFrame:CGRectMake(410, 40, 90, 15)];
                    [self.lblInclPrice setFrame:CGRectMake(500, 40, 110, 15)];
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
                    [self.lblExclPrice setFrame:CGRectMake(410, 25, 100, 20)];
                    [self.lblExclPrice setTextAlignment:NSTextAlignmentCenter];
                    if ([self.product valueForKey:@"total_option_price"]) {
                        priceOfProduct += [[self.product valueForKey:@"total_option_price"] floatValue];
                    }
                    priceOfProduct += [[productPrice valueForKey:@"product_regular_price"] floatValue];
                    [self.lblExclPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceOfProduct]]];
                    [self.lblExclPrice setHidden:NO];
                    
                    CGFloat priceWidth = [self.lblExclPrice.text sizeWithAttributes:@{NSFontAttributeName:[self.lblExclPrice font]}].width;
                    [self.crossLine setFrame:CGRectMake(self.lblExclPrice.frame.origin.x + (CGRectGetWidth(self.lblExclPrice.frame) - priceWidth)/2 , self.lblExclPrice.center.y, priceWidth, 1)];
                    [self.crossLine setHidden:NO];
                    
                    [self.lblInclPrice setFrame:CGRectMake(510, 25, 100, 20)];
                    [self.lblInclPrice setTextAlignment:NSTextAlignmentCenter];
                    if ([productPrice valueForKey:@"total_option_price"]) {
                        priceOfProductIncl += [[productPrice valueForKey:@"total_option_price"] floatValue];
                    }
                    priceOfProductIncl += [[productPrice valueForKey:@"product_price"] floatValue];
                    
                    [self.lblInclPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceOfProductIncl]]];
                    [self.lblInclPrice setHidden:NO];
                    return;
                }
                
                [self.lblExclPrice setFrame:CGRectMake(410, 25, 200, 20)];
                [self.lblExclPrice setTextAlignment:NSTextAlignmentCenter];
                if ([self.product valueForKey:@"total_option_price"]) {
                    priceOfProduct += [[self.product valueForKey:@"total_option_price"] floatValue];
                }
                priceOfProduct += [[productPrice valueForKey:@"product_regular_price"] floatValue];
                [self.lblExclPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceOfProduct]]];
                [self.lblExclPrice setHidden:NO];
            }
        }
    }
}


#pragma mark ZThemeProductView Delegate
- (void)didGetProductDetailWithProductID:(NSString *)productID
{
    ZThemeProductView *productView = [self.arrayProductsView objectAtIndex:self.currentIndexProductOnArray];
    if ([productView.productID isEqualToString:productID]) {
        if (self.isFirtLoadProduct) {
            [self.viewToolBar setHidden:NO];
            [self.viewAction setHidden:NO];
            self.isFirtLoadProduct = NO;
        }
        [self setProduct:productView.productModel];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ZThemeProductViewControllerPad_DidGetProduct" object:self];
    }
}


#pragma mark Selection & Add To Cart
- (void)buttonSelectOptionTouch:(id)sender
{
    if (self.optionViewController == nil) {
        self.optionViewController = [ZThemeProductOptionViewController new];
        self.optionViewController.tableViewOption.showsVerticalScrollIndicator = NO;
        self.optionViewController.delegate = self;
    }
    self.optionViewController.allKeys = self.allKeys;
    self.optionViewController.optionDict = self.optionDict;
    self.optionViewController.product = self.product;
    self.optionViewController.selectedOptionPrice = self.selectedOptionPrice;
    
    if(productOptionPopOver == nil){
        productOptionPopOver = [[UIPopoverController alloc]initWithContentViewController:self.optionViewController];
    }
    
    [productOptionPopOver presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
    [productOptionPopOver setPopoverContentSize:CGSizeMake(320, 320)];
    productOptionPopOver.delegate = self;
    
}

- (void)close:(id)sender
{
    [productOptionPopOver dismissPopoverAnimated:YES];
}


#pragma mark Action Touch Button

- (void)didTouchShareButton
{
    NSURL *productURL = [NSURL URLWithString:@"Hello"];
    if ([self.product valueForKey:@"product_url"]) {
        productURL = [NSURL URLWithString:[self.product valueForKey:@"product_url"]];
    }
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[productURL]
                                      applicationActivities:nil];
    activityViewController.popoverPresentationController.sourceView = self.view;
    [self.navigationController presentViewController:activityViewController
                                            animated:YES
                                          completion:^{
                                              // ...
                                          }];
}

@end
