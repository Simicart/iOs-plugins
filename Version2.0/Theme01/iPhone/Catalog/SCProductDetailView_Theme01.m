//
//  SCProductDetailView_Theme01.m
//  SimiCart
//
//  Created by Tan on 7/4/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SCProductDetailView_Theme01.h"
#import <SimiCartBundle/NSString+HTML.h>
#import <SimiCartBundle/SimiFormatter.h>
#import <SimiCartBundle/UILabelDynamicSize.h>
#import <SimiCartBundle/SCWebViewController.h>
#include <SimiCartBundle/SCAppDelegate.h>

@implementation SCProductDetailView_Theme01

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
@synthesize heightCell = _heightCell, tierPrices, tierLabel, tierPrice, otherInfo, otherInfos, stockStatus, stockStatusLabel, shortDescription, shortDescriptionLabel;
@synthesize clickOtherInfos;

@synthesize product = _product;

#pragma mark Set Interface
- (void)setInterfaceCell
{
    _heightCell = 5;
    int origionTitleX = 15;
    int origionValueX = 165;
    
    int widthTitle = 150;
    int widthValue = 150;
    int widthText = 300;
    
    int heightLabel = 20;
    int heightLabelWithDistance = 20;
    //  Liam Update RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        origionTitleX = 155;
        origionValueX = 5;
        widthText = 290;
    }
    //  End RTL
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        widthText = 410;
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            origionTitleX = 260;
            origionValueX = 110;
        }
        //  End RTL
    }
    
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *lblView = (UILabel*)subview;
                [lblView removeFromSuperview];
        }
    }
    
    _scrollView = [UIScrollView new];

    if(stockStatus){
        stockStatusLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, _heightCell, widthText, heightLabel)];
        if([stockStatus boolValue]){
            stockStatusLabel.text = SCLocalizedString(@"In Stock");
        }else{
            stockStatusLabel.text = SCLocalizedString(@"Out Stock");
        }
        stockStatusLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
        stockStatusLabel.textColor = [UIColor darkGrayColor];
        [self.scrollView addSubview:stockStatusLabel];
        _heightCell += heightLabelWithDistance + 3;
    }
    
    if ([_product productType] != ProductTypeBundle) {
        if([showPriceV2 valueForKey:@"product_regular_price"]){
            if([showPriceV2 valueForKey:@"special_price_label"]){
                regularLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
                regularLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Regular Price")];
                regularLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                regularLabel.textColor = [UIColor darkGrayColor];
                [self.scrollView addSubview:regularLabel];
                [regularPriceLabel setFrame:CGRectMake(origionValueX, _heightCell, widthValue, heightLabel)];
                [self.scrollView addSubview:regularPriceLabel];
                //Set Strike Through for Regular Price
                //Gin edit
                CGFloat priceWidth = [regularPriceLabel.text sizeWithAttributes:@{NSFontAttributeName:[regularPriceLabel font]}].width;
                UIView *throughLine = [[UIView alloc] initWithFrame:CGRectMake(0, regularPriceLabel.frame.size.height/2, priceWidth, 1)];
                //end
                throughLine.backgroundColor = THEME01_PRICE_COLOR;
                CGRect frame = throughLine.frame;
                frame.origin.y = frame.size.height/2;
                frame.size.height = 1;
                [regularPriceLabel addSubview:throughLine];
                _heightCell += heightLabelWithDistance;
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    [throughLine setFrame:CGRectMake(regularPriceLabel.frame.size.width - priceWidth,regularPriceLabel.frame.size.height/2, priceWidth, 1)];
                }
                //  End RTL
            }else{
                [regularPriceLabel setFrame:CGRectMake(origionTitleX, _heightCell, widthValue, heightLabel)];
                [self.scrollView addSubview:regularPriceLabel];
                _heightCell += heightLabelWithDistance;
            }
        }
        if([showPriceV2 valueForKey:@"special_price_label"]){
            specialLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
            specialLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Special Price")];
            specialLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
            specialLabel.textColor = THEME01_PRICE_COLOR;
            [self.scrollView addSubview:specialLabel];
            if([showPriceV2 valueForKey:@"product_price"]){
                [specialPriceLabel setFrame:CGRectMake(origionValueX, _heightCell, widthValue, heightLabel)];
                [self.scrollView addSubview:specialPriceLabel];
            }
            _heightCell += heightLabelWithDistance;
        }
        if([showPriceV2 valueForKey:@"excl_tax"]){
            exclLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
            exclLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
            exclLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
            exclLabel.textColor = [UIColor darkGrayColor];
            [self.scrollView addSubview:exclLabel];
            [exclPriceLabel setFrame:CGRectMake(origionValueX, _heightCell, widthValue, heightLabel)];
            [self.scrollView addSubview:exclPriceLabel];
            _heightCell += heightLabelWithDistance;
        }
        if([showPriceV2 valueForKey:@"incl_tax"]){
            inclLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
            inclLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
            inclLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
            inclLabel.textColor = [UIColor darkGrayColor];
            [self.scrollView addSubview:inclLabel];
            [inclPriceLabel setFrame:CGRectMake(origionValueX, _heightCell, widthValue, heightLabel)];
            [self.scrollView addSubview:inclPriceLabel];
            _heightCell += heightLabelWithDistance;
        }
        
        if([showPriceV2 valueForKey:@"excl_tax_special"]){
            exclLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
            exclLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
            exclLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
            exclLabel.textColor = [UIColor darkGrayColor];
            [self.scrollView addSubview:exclLabel];
            [exclPriceLabel setFrame:CGRectMake(origionValueX, _heightCell, widthValue, heightLabel)];
            [self.scrollView addSubview:exclPriceLabel];
            _heightCell += heightLabelWithDistance;
        }
        if([showPriceV2 valueForKey:@"incl_tax_special"]){
            inclLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
            inclLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
            inclLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
            inclLabel.textColor = [UIColor darkGrayColor];
            [self.scrollView addSubview:inclLabel];
            [inclPriceLabel setFrame:CGRectMake(origionValueX, _heightCell, widthValue, heightLabel)];
            [self.scrollView addSubview:inclPriceLabel];
            _heightCell += heightLabelWithDistance;
        }
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            regularLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Regular Price")];
            specialLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Special Price")];
            exclLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Excl. Tax")];
            inclLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Incl. Tax")];
        }
        //  End RTL
    }else{
        if(![showPriceV2 valueForKey:@"minimal_price_label"]){
            if([showPriceV2 valueForKey:@"excl_tax_from"] && [showPriceV2 valueForKey:@"incl_tax_from"]){
                fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
                fromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"From")];
                fromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                fromLabel.textColor = [UIColor blackColor];
                [self.scrollView addSubview:fromLabel];
                _heightCell += heightLabelWithDistance;
                
                exclFromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
                exclFromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                exclFromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                exclFromLabel.textColor = [UIColor darkGrayColor];
                [exclPriceFromLabel setFrame:CGRectMake(origionValueX, _heightCell, widthValue, heightLabel)];
                [self.scrollView addSubview:exclFromLabel];
                [self.scrollView addSubview:exclPriceFromLabel];
                _heightCell += heightLabelWithDistance;
                
                inclFromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
                inclFromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
                inclFromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                inclFromLabel.textColor = [UIColor darkGrayColor];
                [inclPriceFromLabel setFrame:CGRectMake(origionValueX, _heightCell, widthValue, heightLabel)];
                [self.scrollView addSubview:inclFromLabel];
                [self.scrollView addSubview:inclPriceFromLabel];
                _heightCell += heightLabelWithDistance;
                
                toLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
                toLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"To")];
                toLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                [self.scrollView addSubview:toLabel];
                _heightCell += heightLabelWithDistance;
                
                exclToLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
                exclToLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                exclToLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                exclToLabel.textColor = [UIColor darkGrayColor];
                [exclPriceToLabel setFrame:CGRectMake(origionValueX, _heightCell, widthValue, heightLabel)];
                [self.scrollView addSubview:exclToLabel];
                [self.scrollView addSubview:exclPriceToLabel];
                _heightCell += heightLabelWithDistance;
                
                inclToLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
                inclToLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
                inclToLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                inclToLabel.textColor = [UIColor darkGrayColor];
                [inclPriceToLabel setFrame:CGRectMake(origionValueX, _heightCell, widthTitle, heightLabel)];
                [self.scrollView addSubview:inclToLabel];
                [self.scrollView addSubview:inclPriceToLabel];
                _heightCell += heightLabelWithDistance;
                
                configLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
                configLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Configured")];
                configLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                configLabel.textColor = [UIColor blackColor];
                [self.scrollView addSubview:configLabel];
                _heightCell += heightLabelWithDistance;
                
                exclConfigLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
                exclConfigLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                exclConfigLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                exclConfigLabel.textColor = [UIColor darkGrayColor];
                [exclPriceConfigLabel setFrame:CGRectMake(origionValueX, _heightCell, widthValue, heightLabel)];
                [self.scrollView addSubview:exclConfigLabel];
                [self.scrollView addSubview:exclPriceConfigLabel];
                _heightCell += heightLabelWithDistance;
                
                inclConfigLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
                inclConfigLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                inclConfigLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                inclConfigLabel.textColor = [UIColor darkGrayColor];
                [inclPriceConfigLabel setFrame:CGRectMake(origionValueX, _heightCell, widthValue, heightLabel)];
                [self.scrollView addSubview:inclConfigLabel];
                [self.scrollView addSubview:inclPriceConfigLabel];
                _heightCell += heightLabelWithDistance;
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
                    self.toLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME_FONT_NAME] size:THEME_FONT_SIZE_REGULAR];
                    self.toLabel.textColor = [UIColor blackColor];
                    [self.priceToLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                    [self addSubview:self.toLabel];
                    [self addSubview:self.priceToLabel];
                    self.heightCell += heightLabelWithDistance;
                }
                
                self.configLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                self.configLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Configured")];
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
                    self.inclConfigLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE_REGULAR];
                    self.inclConfigLabel.textColor = [UIColor darkGrayColor];
                    [self.inclPriceConfigLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                    [self addSubview:self.inclConfigLabel];
                    [self addSubview:self.inclPriceConfigLabel];
                    self.heightCell += heightLabelWithDistance;
                }
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    fromLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"From")];
                    toLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"To")];
                    configLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Configured")];
                    exclConfigLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Excl. Tax")];
                    inclConfigLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Incl. Tax")];
                }
                //  End RTL
            }
        }else{
            if([showPriceV2 valueForKey:@"excl_tax_minimal"] && [showPriceV2 valueForKey:@"incl_tax_minimal"]){
                fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
                fromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"As Low As")];
                fromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                fromLabel.textColor = [UIColor blackColor];
                [self.scrollView addSubview:fromLabel];
                _heightCell += heightLabelWithDistance;
                
                exclFromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
                exclFromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                exclFromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                exclFromLabel.textColor = [UIColor darkGrayColor];
                [exclPriceFromLabel setFrame:CGRectMake(origionValueX, _heightCell, widthValue, heightLabel)];
                [self.scrollView addSubview:exclFromLabel];
                [self.scrollView addSubview:exclPriceFromLabel];
                _heightCell += heightLabelWithDistance;
                
                inclFromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
                inclFromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
                inclFromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                inclFromLabel.textColor = [UIColor darkGrayColor];
                [inclPriceFromLabel setFrame:CGRectMake(origionValueX, _heightCell, widthValue, heightLabel)];
                [self.scrollView addSubview:inclFromLabel];
                [self.scrollView addSubview:inclPriceFromLabel];
                _heightCell += heightLabelWithDistance;
                
                configLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
                configLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Configured")];
                configLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                configLabel.textColor = [UIColor blackColor];
                [self.scrollView addSubview:configLabel];
                _heightCell += heightLabelWithDistance;
                
                exclConfigLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
                exclConfigLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                exclConfigLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                exclConfigLabel.textColor = THEME01_PRICE_COLOR;
                [exclPriceConfigLabel setFrame:CGRectMake(origionValueX, _heightCell, widthValue, heightLabel)];
                [self.scrollView addSubview:exclConfigLabel];
                [self.scrollView addSubview:exclPriceConfigLabel];
                _heightCell += heightLabelWithDistance;
                
                inclConfigLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
                inclConfigLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                inclConfigLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                inclConfigLabel.textColor = THEME01_PRICE_COLOR;
                [inclPriceConfigLabel setFrame:CGRectMake(origionValueX, _heightCell, widthValue, heightLabel)];
                [self.scrollView addSubview:inclConfigLabel];
                [self.scrollView addSubview:inclPriceConfigLabel];
                _heightCell += heightLabelWithDistance;
            }else{
                fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
                fromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"As Low As")];
                fromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                fromLabel.textColor = [UIColor blackColor];
                [priceFromLabel setFrame:CGRectMake(origionValueX + 20, _heightCell, widthValue, heightLabel)];
                [self.scrollView addSubview:fromLabel];
                [self.scrollView addSubview:priceFromLabel];
                _heightCell += heightLabelWithDistance;
                
                configLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, _heightCell, widthTitle, heightLabel)];
                configLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Configured")];
                configLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                toLabel.textColor = [UIColor blackColor];
                [priceConfigLabel setFrame:CGRectMake(origionValueX, _heightCell, widthValue, heightLabel)];
                [self.scrollView addSubview:toLabel];
                [self.scrollView addSubview:priceToLabel];
                _heightCell += heightLabelWithDistance;
            }
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                fromLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"As Low As")];
                exclFromLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Excl. Tax")];
                inclFromLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Incl. Tax")];
                configLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Configured")];
                exclConfigLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Excl. Tax")];
                inclConfigLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Incl. Tax")];
            }
            //  End RTL
        }
    }
    
    if(tierPrices.count){
        tierLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, _heightCell, widthText, heightLabel)];
        tierLabel.text = tierPrice;
        tierLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
        tierLabel.textColor = [UIColor blueColor];
        if(isDetailInfo){
            tierLabel.numberOfLines = tierPrices.count * 2;
            _heightCell += heightLabelWithDistance * tierPrices.count * 2;
        }else{
            tierLabel.numberOfLines = 2;
            _heightCell += heightLabelWithDistance *  2;
        }
        [tierLabel sizeToFit];
        [self.scrollView addSubview:tierLabel];
    }
    
    if(otherInfos.count && isDetailInfo){
        clickOtherInfos = [[NSMutableDictionary alloc]init];
        for(int i = 0; i< otherInfos.count; i++){
            if(![[[otherInfos objectAtIndex:i] valueForKey:@"click"] isEqualToString:@"1"]){
                NSString *otherValue = [[otherInfos objectAtIndex:i] valueForKey:@"value"];
                UILabel *otherInfoTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, _heightCell, widthText, heightLabel)];
                if(![otherValue isKindOfClass:[NSNull class]] && otherValue != nil){
                    otherInfoTextLabel.text = [otherValue stringByConvertingHTMLToPlainText];
                    otherInfoTextLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                    otherInfoTextLabel.textColor = [UIColor blueColor];
                    otherInfoTextLabel.numberOfLines = otherInfos.count * 2;
                    _heightCell += heightLabelWithDistance * 2;
                    [otherInfoTextLabel sizeToFit];
                    [self.scrollView addSubview:otherInfoTextLabel];
                }
            }
        }
    }
    
    if(shortDescription){
        shortDescriptionLabel = [[UILabel alloc]init];
        shortDescriptionLabel.text = shortDescription;
        shortDescriptionLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
        shortDescriptionLabel.textColor = [UIColor blackColor];
        [self.scrollView addSubview:shortDescriptionLabel];
        
        CGSize maximumLabelSize = CGSizeMake(290, FLT_MAX);
        
        CGSize expectedLabelSize = [shortDescription sizeWithFont:shortDescriptionLabel.font constrainedToSize:maximumLabelSize lineBreakMode:shortDescriptionLabel.lineBreakMode];
        [shortDescriptionLabel setFrame:CGRectMake(15, _heightCell+3, widthText, expectedLabelSize.height)];
        _heightCell += expectedLabelSize.height + 10;
    }
    
    if(otherInfos.count && isDetailInfo){
        clickOtherInfos = [[NSMutableDictionary alloc]init];
        for(int i = 0; i< otherInfos.count; i++){
            if([[[otherInfos objectAtIndex:i] valueForKey:@"click"] isEqualToString:@"1"]){
                NSString *otherValue = [[otherInfos objectAtIndex:i] valueForKey:@"value"];
                NSString *otherContent = [[otherInfos objectAtIndex:i] valueForKey:@"content"];
                UIButton *otherInfoButton = [[UIButton alloc]init];
                if(![otherValue isKindOfClass:[NSNull class]] && otherValue != nil){
                    [otherInfoButton setTitle:[[otherValue stringByConvertingHTMLToPlainText] uppercaseString] forState:UIControlStateNormal];
                    [otherInfoButton setTitleColor:[UIColor colorWithRed:255.f/255 green:157.f/255 blue:10.f/255 alpha:1.0] forState:UIControlStateNormal];
                    otherInfoButton.titleLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
                    otherInfoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    CGFloat priceWidth = [otherInfoButton.titleLabel.text sizeWithFont:otherInfoButton.titleLabel.font].width;
                    [otherInfoButton setFrame:CGRectMake(origionTitleX, _heightCell, priceWidth, heightLabel)];
                    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(origionTitleX + priceWidth + 3, _heightCell+otherInfoButton.frame.size.height/4, 9, 9)];
                    [imgView setImage:[UIImage imageNamed:@"ic_extend_ship"]];
                    [otherInfoButton addTarget:self action:@selector(viewOtherInfomation:) forControlEvents:UIControlEventTouchUpInside];
                    [self.scrollView addSubview:otherInfoButton];
                    [self.scrollView addSubview:imgView];
                    
                    _heightCell += heightLabelWithDistance *3/2;
                    if(otherContent != nil){
                        [clickOtherInfos setObject:otherContent forKey:otherInfoButton.titleLabel.text];
                    }
                }
            }
        }
    }
    if ([SimiGlobalVar sharedInstance].isReverseLanguage) {        
        for (UIView *view in self.scrollView.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel*)view;
                [label setTextAlignment:NSTextAlignmentRight];
            }
        }
    }
    [self addSubview:_scrollView];
}

- (void) viewOtherInfomation:(UIButton *)sender
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    SCWebViewController *webViewController = [[SCWebViewController alloc] init];
    webViewController.content = [clickOtherInfos valueForKey:sender.titleLabel.text];
    [(UINavigationController *)currentVC pushViewController:webViewController animated:YES];

}
@end
