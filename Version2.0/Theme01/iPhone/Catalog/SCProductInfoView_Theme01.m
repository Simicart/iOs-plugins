//
//  SCProductInfoView.m
//  SimiCart
//
//  Created by Tan on 7/4/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SCProductImageViewController.h>
#import <SimiCartBundle/NSString+HTML.h>
#import <SimiCartBundle/SimiFormatter.h>
#import <SimiCartBundle/UILabelDynamicSize.h>
#import <SimiCartBundle/SCWebViewController.h>
#include <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/UIImageView+WebCache.h>
#import "SCProductInfoView_Theme01.h"
#import "SimiGlobalVar+Theme01.h"
#import <SimiCartBundle/UIImage+SimiCustom.h>

@implementation SCProductInfoView_Theme01

@synthesize productName, specialPrice, productNameLabel, specialPriceLabel, regularPriceLabel, specialPriceView, regularPriceView, regularLabel, specialLabel, regularPrice, productRate, imagePath;
@synthesize exclPrice, inclPrice, exclLabel, inclLabel, exclPriceLabel;
@synthesize exclPriceView, inclPriceLabel, inclPriceView, isDetailInfo, showPriceV2;
@synthesize priceFrom, priceTo, fromLabel, priceFromLabel, toLabel, exclPriceFrom;
@synthesize inclPriceFrom, exclPriceTo, inclPriceTo, exclPriceFromLabel, exclFromLabel;
@synthesize inclPriceFromLabel, inclFromLabel, exclPriceToLabel, exclToLabel;
@synthesize inclPriceToLabel, inclToLabel, scrollImageProduct, viewPageControl;
@synthesize priceFromView, priceToView, exclPriceFromView, inclPriceFromView;
@synthesize exclPriceToView, inclPriceToView, configLabel, priceConfig, priceConfigLabel;
@synthesize priceConfigView, priceToLabel, exclConfigLabel, exclPriceConfig;
@synthesize exclPriceConfigLabel, exclPriceConfigView, inclConfigLabel, inclPriceConfig;
@synthesize inclPriceConfigLabel, inclPriceConfigView;
@synthesize heightCell;

@synthesize product = _product;

#pragma mark Set Interface
- (void)setInterfaceCell
{
    if ([_product valueForKey:scTheme01_03_product_rate]) {
        self.productRate = [[_product valueForKey:scTheme01_03_product_rate]floatValue];
    }
    self.heightCell = 15;
    int heightLabelWithDistance = 20;
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *lblView = (UILabel*)subview;
            [lblView removeFromSuperview];
        }else if ([subview isKindOfClass:[UIImageView class]]) {
            UIImageView *imgView = (UIImageView*)subview;
            [imgView removeFromSuperview];
        }else if ([subview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView*)subview;
            [scrollView removeFromSuperview];
        }
    }

    int numberRows = 0;
    
    if(productName){
        productNameLabel = [[UILabel alloc]init];
        productNameLabel.text = [productName uppercaseString];
        productNameLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:18];
        productNameLabel.textColor = [UIColor blackColor];
        productNameLabel.textAlignment = NSTextAlignmentCenter;
        CGFloat nameWidth = [productNameLabel.text sizeWithFont:productNameLabel.font].width;
        if(nameWidth <= [[UIScreen mainScreen] bounds].size.width - 10 && nameWidth > 250){
            [productNameLabel setFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width - nameWidth)/2 - 5, self.heightCell, 290, 20)];
            numberRows = 1;
        }else if(nameWidth > ([[UIScreen mainScreen] bounds].size.width - 10)*2){
            [productNameLabel setFrame:CGRectMake(15, -20, 290, 20)];
            numberRows = 1;
        }else if(nameWidth > ([[UIScreen mainScreen] bounds].size.width - 10)){
            [productNameLabel setFrame:CGRectMake(15, self.heightCell, 290, 20)];
            numberRows = 1;
        }else{
            [productNameLabel setFrame:CGRectMake(15, self.heightCell, 290, 20)];
        }
        [productNameLabel resizLabelToFit];
        CGRect frame = productNameLabel.frame;
        productNameLabel.numberOfLines = 1;
        if (frame.size.height > 65) {
            frame.size.height = 75;
            productNameLabel.numberOfLines = 3;
        }else if(frame.size.height > 45){
            frame.size.height = 50;
            productNameLabel.numberOfLines = 2;
        }
        [productNameLabel setFrame:frame];
        self.heightCell += productNameLabel.frame.size.height;
        [self addSubview:productNameLabel];
    }
    
    int originXstar = ([[UIScreen mainScreen] bounds].size.width - 12*5)/2 - 5;
    int temp = (int)productRate;
    
    if (productRate == 0) {
        for (int i = 0; i < 5; i++) {
            UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*17, self.heightCell, 13, 13)];
            [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar2.png"]];
            [self addSubview:imageStar];
        }
    }else{
        for (int i = 0; i < temp; i++) {
            UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*17, self.heightCell, 13, 13)];
            [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar1.png"]];
            [self addSubview:imageStar];
        }
        if (productRate - temp > 0) {
            UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + temp*17, self.heightCell, 13, 13)];
            [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar0.png"]];
            [self addSubview:imageStar];
            
            for (int i = temp + 1; i < 5; i++) {
                UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*17, self.heightCell, 13, 13)];
                [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar2.png"]];
                [self addSubview:imageStar];;
            }
        }else{
            for (int i = temp; i < 5; i++) {
                UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*17, self.heightCell, 13, 13)];
                [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar2.png"]];
                [self addSubview:imageStar];
            }
        }
    }
    self.heightCell += 15;

    _mainFrame = productNameLabel.frame;
    _mainFrame.origin.y = self.heightCell;
    _mainFrame.size.height = 210;
    _mainFrame.size.width -= 60;
    _mainFrame.origin.x += 30;
    
    _imagesProduct = [_product valueForKey:@"product_images"];
    if (_imagesProduct.count > 0) {
        scrollImageProduct = [[UIScrollView alloc]initWithFrame:_mainFrame];
        scrollImageProduct.showsHorizontalScrollIndicator = NO;
        scrollImageProduct.showsVerticalScrollIndicator = NO;
        scrollImageProduct.pagingEnabled = YES;
        scrollImageProduct.scrollEnabled = YES;
        scrollImageProduct.delegate = self;
        
        for (int i = 0; i < _imagesProduct.count; i++) {
            UIImageView *imageProduct = [[UIImageView alloc]initWithFrame:CGRectMake(_mainFrame.size.width*i, 0, _mainFrame.size.width, _mainFrame.size.height)];
            [imageProduct sd_setImageWithURL:[_imagesProduct objectAtIndex:i]];
            imageProduct.contentMode = UIViewContentModeScaleAspectFit;
            imageProduct.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
            [scrollImageProduct addSubview:imageProduct];
        }
        
        [scrollImageProduct setContentSize:CGSizeMake(_mainFrame.size.width*_imagesProduct.count, _mainFrame.size.height)];
        [self addSubview:scrollImageProduct];
        
        //    set pagecontrol
        float sizeItem = 11;
        float distanceItem = 7;
        
        if(viewPageControl == nil){
            viewPageControl = [[UIView alloc]initWithFrame:CGRectMake(_mainFrame.origin.x + _mainFrame.size.width/2 - _imagesProduct.count*(sizeItem+distanceItem)/2, _mainFrame.origin.y + _mainFrame.size.height + 10, _imagesProduct.count*(sizeItem+distanceItem), 11)];
        }
        for (int i = 0; i < _imagesProduct.count; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*(sizeItem + distanceItem), 0, sizeItem, sizeItem)];
            imageView.tag = i;
            [viewPageControl addSubview:imageView];
        }
        
        _currentIndex=-1;
        [self setImagePageControl:0];
        [self addSubview:viewPageControl];
    }
    
    
    
    
    self.heightCell = 320 + 20 * numberRows;
    int origionTitleX = 15;
    int origionValueX = 110;
    int simpleOrigionValueX = 110;
    
    int widthTitle = 100;
    int widthValue = 150;
    
    int heightLabel = 20;
    //  Liam Update RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        origionTitleX = 205;
        origionValueX = 55;
        simpleOrigionValueX = 55;
    }
    //  End RTL
    if ([_product productType] != ProductTypeBundle) {
        if([showPriceV2 valueForKey:@"product_regular_price"]){
            if([showPriceV2 valueForKey:@"special_price_label"]){
                regularLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                regularLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Regular Price")];
                regularLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                regularLabel.textColor = [UIColor darkGrayColor];
                [self addSubview:regularLabel];
                [regularPriceLabel setFrame:CGRectMake(simpleOrigionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:regularPriceLabel];
                //Set Strike Through for Regular Price
                CGFloat priceWidth = [regularPriceLabel.text sizeWithFont:regularPriceLabel.font].width;
                UIView *throughLine = [[UIView alloc] initWithFrame:CGRectMake(0, regularPriceLabel.frame.size.height/2, priceWidth, 0.5)];
                throughLine.backgroundColor = THEME01_PRICE_COLOR;
                CGRect frame = throughLine.frame;
                frame.origin.y = frame.size.height/2;
                frame.size.height = 1;
                [regularPriceLabel addSubview:throughLine];
                self.heightCell += heightLabelWithDistance;
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    regularLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Regular Price")];
                    [throughLine setFrame:CGRectMake(regularPriceLabel.frame.size.width - priceWidth,regularPriceLabel.frame.size.height/2, priceWidth, 1)];
                }
                //  End RTL
            }else{
                [regularPriceLabel setFrame:CGRectMake(origionTitleX, self.heightCell, widthValue, heightLabel)];
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    [regularPriceLabel setFrame:CGRectMake(origionTitleX - 50, self.heightCell, widthValue, heightLabel)];
                }
                //  End RTL
                [self addSubview:regularPriceLabel];
                self.heightCell += heightLabelWithDistance;
            }
        }
        if([showPriceV2 valueForKey:@"special_price_label"]){
            specialLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
            specialLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Special Price")];
            specialLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
            specialLabel.textColor = THEME01_SPECIAL_PRICE_COLOR;
            [self addSubview:specialLabel];
            if([showPriceV2 valueForKey:@"product_price"]){
                specialPriceLabel.textColor = THEME01_SPECIAL_PRICE_COLOR;
                [specialPriceLabel setFrame:CGRectMake(simpleOrigionValueX+5, self.heightCell, widthValue, heightLabel)];
                [self addSubview:specialPriceLabel];
            }
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                specialLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Special Price")];
            }
            //  End RTL
            self.heightCell += heightLabelWithDistance;
        }
        if([showPriceV2 valueForKey:@"excl_tax"]){
            exclLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
            exclLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                exclLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Excl. Tax")];
            }
            //  End RTL
            exclLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
            exclLabel.textColor = [UIColor darkGrayColor];
            [self addSubview:exclLabel];
            [exclPriceLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
            [self addSubview:exclPriceLabel];
            self.heightCell += heightLabelWithDistance;
        }
        if([showPriceV2 valueForKey:@"incl_tax"]){
            inclLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
            inclLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                inclLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Incl. Tax")];
            }
            //  End RTL
            inclLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
            inclLabel.textColor = [UIColor darkGrayColor];
            [self addSubview:inclLabel];
            [inclPriceLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
            [self addSubview:inclPriceLabel];
            self.heightCell += heightLabelWithDistance;
        }
        
        if([showPriceV2 valueForKey:@"excl_tax_special"]){
            exclLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
            exclLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                exclLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Excl. Tax")];
            }
            //  End RTL
            exclLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
            exclLabel.textColor = [UIColor darkGrayColor];
            [self addSubview:exclLabel];
            exclPriceLabel.textColor = THEME01_SPECIAL_PRICE_COLOR;
            [exclPriceLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
            [self addSubview:exclPriceLabel];
            self.heightCell += heightLabelWithDistance;
        }
        if([showPriceV2 valueForKey:@"incl_tax_special"]){
            inclLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
            inclLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                inclLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Incl. Tax")];
            }
            //  End RTL
            inclLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
            inclLabel.textColor = [UIColor darkGrayColor];
            [self addSubview:inclLabel];
            inclPriceLabel.textColor = THEME01_SPECIAL_PRICE_COLOR;
            [inclPriceLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
            [self addSubview:inclPriceLabel];
            self.heightCell += heightLabelWithDistance;
        }
    }else
    {
        if(![showPriceV2 valueForKey:@"minimal_price_label"]){
            if([showPriceV2 valueForKey:@"excl_tax_from"] && [showPriceV2 valueForKey:@"incl_tax_from"]){
                fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                fromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"From")];
                fromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                fromLabel.textColor = [UIColor blackColor];
                [self addSubview:fromLabel];
                self.heightCell += heightLabelWithDistance;
                
                exclFromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                exclFromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                exclFromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                exclFromLabel.textColor = [UIColor darkGrayColor];
                [exclPriceFromLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:exclFromLabel];
                [self addSubview:exclPriceFromLabel];
                self.heightCell += heightLabelWithDistance;
                
                inclFromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                inclFromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
                inclFromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                inclFromLabel.textColor = [UIColor darkGrayColor];
                [inclPriceFromLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:inclFromLabel];
                [self addSubview:inclPriceFromLabel];
                self.heightCell += heightLabelWithDistance;
                
                toLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                toLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"To")];
                toLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                [self addSubview:toLabel];
                self.heightCell += heightLabelWithDistance;
                
                exclToLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                exclToLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                exclToLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                exclToLabel.textColor = [UIColor darkGrayColor];
                [exclPriceToLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:exclToLabel];
                [self addSubview:exclPriceToLabel];
                self.heightCell += heightLabelWithDistance;
                
                inclToLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                inclToLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
                inclToLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                inclToLabel.textColor = [UIColor darkGrayColor];
                [inclPriceToLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:inclToLabel];
                [self addSubview:inclPriceToLabel];
                self.heightCell += heightLabelWithDistance;
                
                configLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                configLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Configured")];
                configLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                configLabel.textColor = [UIColor blackColor];
                [self addSubview:configLabel];
                self.heightCell += heightLabelWithDistance;
                
                exclConfigLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                exclConfigLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                exclConfigLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                exclConfigLabel.textColor = [UIColor darkGrayColor];
                [exclPriceConfigLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:exclConfigLabel];
                [self addSubview:exclPriceConfigLabel];
                self.heightCell += heightLabelWithDistance;
                
                inclConfigLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                inclConfigLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
                inclConfigLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                inclConfigLabel.textColor = [UIColor darkGrayColor];
                [inclPriceConfigLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:inclConfigLabel];
                [self addSubview:inclPriceConfigLabel];
                self.heightCell += heightLabelWithDistance;
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    fromLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"From")];
                    exclFromLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Excl. Tax")];
                    inclFromLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Incl. Tax")];
                    toLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"To")];
                    exclToLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Excl. Tax")];
                    inclToLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Incl. Tax")];
                    configLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Configured")];
                    exclConfigLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Excl. Tax")];
                    inclConfigLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Incl. Tax")];
                }
                //  End RTL
            }else{
                if([self.showPriceV2 valueForKey:@"price_tax_from_label"])
                {
                    self.fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                    self.fromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"From")];
                    //  Liam Update RTL
                    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                        self.fromLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"From")];
                    }
                    //  End RTL
                    self.fromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME_FONT_NAME] size:THEME_FONT_SIZE_REGULAR];
                    self.fromLabel.textColor = [UIColor blackColor];
                    [self.priceFromLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                    [self addSubview:self.fromLabel];
                    [self addSubview:self.priceFromLabel];
                    self.heightCell += heightLabelWithDistance;
                }
                
                if([self.showPriceV2 valueForKey:@"price_tax_to_label"])
                {
                    self.toLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                    self.toLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"To")];
                    //  Liam Update RTL
                    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                        self.toLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"To")];
                    }
                    //  End RTL
                    self.toLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME_FONT_NAME] size:THEME_FONT_SIZE_REGULAR];
                    self.toLabel.textColor = [UIColor blackColor];
                    [self.priceToLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                    [self addSubview:self.toLabel];
                    [self addSubview:self.priceToLabel];
                    self.heightCell += heightLabelWithDistance;
                }
                
                self.configLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                self.configLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Configured")];
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    self.configLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Configured")];
                }
                //  End RTL
                self.configLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME_FONT_NAME] size:THEME_FONT_SIZE_REGULAR];
                self.configLabel.textColor = [UIColor blackColor];
                [self.priceConfigLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:self.configLabel];
                [self addSubview:self.priceConfigLabel];
                self.heightCell += heightLabelWithDistance;
                if([self.showPriceV2 valueForKey:@"excl_tax"]){
                    [self cusSetExclPriceConfig:[NSString stringWithFormat:@"%.2f", [[self.showPriceV2 valueForKey:@"excl_tax"] floatValue]]];
                    self.exclConfigLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                    self.exclConfigLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                    //  Liam Update RTL
                    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                        self.exclConfigLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Excl. Tax")];
                    }
                    //  End RTL
                    self.exclConfigLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE_REGULAR];
                    self.exclConfigLabel.textColor = [UIColor darkGrayColor];
                    [self.exclPriceConfigLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                    [self addSubview:self.exclConfigLabel];
                    [self addSubview:self.exclPriceConfigLabel];
                    self.heightCell += heightLabelWithDistance;
                }
                if([self.showPriceV2 valueForKey:@"incl_tax"]){
                    [self cusSetInclPriceConfig:[NSString stringWithFormat:@"%.2f", [[self.showPriceV2 valueForKey:@"incl_tax"] floatValue]]];
                    self.inclConfigLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                    self.inclConfigLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
                    //  Liam Update RTL
                    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                        self.inclConfigLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Incl. Tax")];
                    }
                    //  End RTL
                    self.inclConfigLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE_REGULAR];
                    self.inclConfigLabel.textColor = [UIColor darkGrayColor];
                    [self.inclPriceConfigLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                    [self addSubview:self.inclConfigLabel];
                    [self addSubview:self.inclPriceConfigLabel];
                    self.heightCell += heightLabelWithDistance;
                }
            }
        }else
        {
            if([showPriceV2 valueForKey:@"excl_tax_minimal"] && [showPriceV2 valueForKey:@"incl_tax_minimal"]){
                fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                fromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"As Low As")];
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    fromLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"As Low As")];
                }
                //  End RTL
                fromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                fromLabel.textColor = [UIColor blackColor];
                [self addSubview:fromLabel];
                self.heightCell += heightLabelWithDistance;
                
                exclFromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                exclFromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    exclFromLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Excl. Tax")];
                }
                //  End RTL
                exclFromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                exclFromLabel.textColor = [UIColor darkGrayColor];
                [exclPriceFromLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:exclFromLabel];
                [self addSubview:exclPriceFromLabel];
                self.heightCell += heightLabelWithDistance;
                
                inclFromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                inclFromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    inclFromLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Incl. Tax")];
                }
                //  End RTL
                inclFromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                inclFromLabel.textColor = [UIColor darkGrayColor];
                [inclPriceFromLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:inclFromLabel];
                [self addSubview:inclPriceFromLabel];
                self.heightCell += heightLabelWithDistance;
                
                configLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                configLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Configured")];
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    configLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Configured")];
                }
                //  End RTL
                configLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                configLabel.textColor = [UIColor blackColor];
                [self addSubview:configLabel];
                self.heightCell += heightLabelWithDistance;
                
                exclConfigLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                exclConfigLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    exclConfigLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Excl. Tax")];
                }
                //  End RTL
                exclConfigLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                exclConfigLabel.textColor = [UIColor darkGrayColor];
                [exclPriceConfigLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:exclConfigLabel];
                [self addSubview:exclPriceConfigLabel];
                self.heightCell += heightLabelWithDistance;
                
                inclConfigLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                inclConfigLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    inclConfigLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
                }
                //  End RTL
                inclConfigLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                inclConfigLabel.textColor = [UIColor darkGrayColor];
                [inclPriceConfigLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:inclConfigLabel];
                [self addSubview:inclPriceConfigLabel];
                self.heightCell += heightLabelWithDistance;
            }else
            {
                fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                fromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"As Low As")];
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    fromLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"As Low As")];
                }
                //  End RTL
                fromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                fromLabel.textColor = [UIColor blackColor];
                [priceFromLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:fromLabel];
                [self addSubview:priceFromLabel];
                self.heightCell += heightLabelWithDistance;
                
                configLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                configLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Configured")];
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    configLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Configured")];
                }
                //  End RTL
                configLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                toLabel.textColor = [UIColor blackColor];
                [priceConfigLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:configLabel];
                [self addSubview:priceConfigLabel];
            }
        }
    }
    
    //  Liam Update RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)view;
                [label setTextAlignment:NSTextAlignmentRight];
            }
        }
        productNameLabel.textAlignment = NSTextAlignmentCenter;
    }
    //  End RTL
}

#pragma mark ScrollView Delegate + PageControl
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = _mainFrame.size.width;
    int page = floor((scrollImageProduct.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if(page != _currentIndex)
    {
        [self setImagePageControl:page];
        _currentIndex=page;
    }
}

- (void)setImagePageControl:(int)index
{
    if(_currentIndex!=index)
    {
    for (UIView *subview in viewPageControl.subviews) {
        if ([subview isKindOfClass:[UIImageView class]])
        {
            _currentIndex = index;
            UIImageView *imageView = (UIImageView*)subview;
            
            if (imageView.tag == (index)) {
                [imageView setImage:[[UIImage imageNamed:@"theme1_pagecontrolchoice"] imageWithColor:THEME01_SUB_PART_COLOR]];
            }
            else
            {
                [imageView setImage:[[UIImage imageNamed:@"theme1_pagecontrolnochoice"] imageWithColor:THEME01_SUB_PART_COLOR]];
            }
        }
    }
    }
}

- (void) didSelectedProductImage: (id)sender
{
    [self.delegate didSelectProductImage:[_product valueForKey:@"product_images"]];
}

@end
