//
//  SCProductInfoViewPad_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/28/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCProductInfoViewPad_Theme01.h"
#import <SimiCartBundle/UILabelDynamicSize.h>
@implementation SCProductInfoViewPad_Theme01

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
@synthesize heightCell, stockStatus, stockStatusLabel;
@synthesize product = _product;

- (void)setInterfaceCell
{
    self.heightCell = 0;
    int heightLabelWithDistance = 25;
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
    int origionTitleX = 15;
    int origionValueX = 145;
    int widthTitle = 130;
    int widthValue = 150;
    int heightLabel = 20;
    
    //  Liam Update RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        origionTitleX = 280;
        origionValueX = 135;
    }
    //  End RTL
    if(stockStatus){
        stockStatusLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
        if([stockStatus boolValue]){
            stockStatusLabel.text = SCLocalizedString(@"In Stock");
        }else{
            stockStatusLabel.text = SCLocalizedString(@"Out Stock");
        }
        stockStatusLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_BOLD] size:20];
        stockStatusLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:stockStatusLabel];
        self.heightCell += heightLabelWithDistance;
    }
    
    if ([_product productType] != ProductTypeBundle) {
        if([showPriceV2 valueForKey:@"product_regular_price"]){
            if([showPriceV2 valueForKey:@"special_price_label"]){
                regularLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                regularLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Regular Price")];
                regularLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
                regularLabel.textColor = [UIColor darkGrayColor];
                [self addSubview:regularLabel];
                [regularPriceLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:regularPriceLabel];
//                Set Strike Through for Regular Price
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
                    [throughLine setFrame:CGRectMake(regularPriceLabel.frame.size.width - priceWidth,regularPriceLabel.frame.size.height/2, priceWidth, 1)];
                }
                //  End RTL
            }else{
                [regularPriceLabel setFrame:CGRectMake(origionTitleX, self.heightCell, widthValue, heightLabel)];
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    [regularPriceLabel setFrame:CGRectMake(origionTitleX - 20, self.heightCell, widthValue, heightLabel)];
                }
                //  End RTL
                [self addSubview:regularPriceLabel];
                self.heightCell += heightLabelWithDistance;
            }
        }
        if([showPriceV2 valueForKey:@"special_price_label"]){
            specialLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
            specialLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Special Price")];
            specialLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
            specialLabel.textColor = THEME01_SPECIAL_PRICE_COLOR;
            [self addSubview:specialLabel];
            if([showPriceV2 valueForKey:@"product_price"]){
                specialPriceLabel.textColor = THEME01_SPECIAL_PRICE_COLOR;
                [specialPriceLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:specialPriceLabel];
            }
            self.heightCell += heightLabelWithDistance;
        }
        if([showPriceV2 valueForKey:@"excl_tax"]){
            exclLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
            exclLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
            exclLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
            exclLabel.textColor = [UIColor darkGrayColor];
            [self addSubview:exclLabel];
            [exclPriceLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
            [self addSubview:exclPriceLabel];
            self.heightCell += heightLabelWithDistance;
        }
        if([showPriceV2 valueForKey:@"incl_tax"]){
            inclLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
            inclLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
            inclLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
            inclLabel.textColor = [UIColor darkGrayColor];
            [self addSubview:inclLabel];
            [inclPriceLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
            [self addSubview:inclPriceLabel];
            self.heightCell += heightLabelWithDistance;
        }
        
        if([showPriceV2 valueForKey:@"excl_tax_special"]){
            exclLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
            exclLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
            exclLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
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
            inclLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
            inclLabel.textColor = [UIColor darkGrayColor];
            [self addSubview:inclLabel];
            inclPriceLabel.textColor = THEME01_SPECIAL_PRICE_COLOR;
            [inclPriceLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
            [self addSubview:inclPriceLabel];
            self.heightCell += heightLabelWithDistance;
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
                fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                fromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"From")];
                fromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
                fromLabel.textColor = [UIColor blackColor];
                [self addSubview:fromLabel];
                self.heightCell += heightLabelWithDistance;
                
                exclFromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                exclFromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                exclFromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
                exclFromLabel.textColor = [UIColor darkGrayColor];
                [exclPriceFromLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:exclFromLabel];
                [self addSubview:exclPriceFromLabel];
                self.heightCell += heightLabelWithDistance;
                
                inclFromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                inclFromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
                inclFromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
                inclFromLabel.textColor = [UIColor darkGrayColor];
                [inclPriceFromLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:inclFromLabel];
                [self addSubview:inclPriceFromLabel];
                self.heightCell += heightLabelWithDistance;
                
                toLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                toLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"To")];
                toLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
                [self addSubview:toLabel];
                self.heightCell += heightLabelWithDistance;
                
                exclToLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                exclToLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                exclToLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
                exclToLabel.textColor = [UIColor darkGrayColor];
                [exclPriceToLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:exclToLabel];
                [self addSubview:exclPriceToLabel];
                self.heightCell += heightLabelWithDistance;
                
                inclToLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                inclToLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
                inclToLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
                inclToLabel.textColor = [UIColor darkGrayColor];
                [inclPriceToLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:inclToLabel];
                [self addSubview:inclPriceToLabel];
                self.heightCell += heightLabelWithDistance;
                
                configLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                configLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Configured")];
                configLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
                configLabel.textColor = [UIColor blackColor];
                [self addSubview:configLabel];
                self.heightCell += heightLabelWithDistance;
                
                exclConfigLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                exclConfigLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                exclConfigLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
                exclConfigLabel.textColor = [UIColor darkGrayColor];
                [exclPriceConfigLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:exclConfigLabel];
                [self addSubview:exclPriceConfigLabel];
                self.heightCell += heightLabelWithDistance;
                
                inclConfigLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                inclConfigLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
                inclConfigLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
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
                fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                fromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"As Low As")];
                fromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
                fromLabel.textColor = [UIColor blackColor];
                [self addSubview:fromLabel];
                self.heightCell += heightLabelWithDistance;
                
                exclFromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                exclFromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                exclFromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
                exclFromLabel.textColor = [UIColor darkGrayColor];
                [exclPriceFromLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:exclFromLabel];
                [self addSubview:exclPriceFromLabel];
                self.heightCell += heightLabelWithDistance;
                
                inclFromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                inclFromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
                inclFromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
                inclFromLabel.textColor = [UIColor darkGrayColor];
                [inclPriceFromLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:inclFromLabel];
                [self addSubview:inclPriceFromLabel];
                self.heightCell += heightLabelWithDistance;
                
                configLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                configLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Configured")];
                configLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
                configLabel.textColor = [UIColor blackColor];
                [self addSubview:configLabel];
                self.heightCell += heightLabelWithDistance;
                
                exclConfigLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                exclConfigLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                exclConfigLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
                exclConfigLabel.textColor = [UIColor darkGrayColor];
                [exclPriceConfigLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:exclConfigLabel];
                [self addSubview:exclPriceConfigLabel];
                self.heightCell += heightLabelWithDistance;
                
                inclConfigLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                inclConfigLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                inclConfigLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
                inclConfigLabel.textColor = [UIColor darkGrayColor];
                [inclPriceConfigLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:inclConfigLabel];
                [self addSubview:inclPriceConfigLabel];
                self.heightCell += heightLabelWithDistance;
            }else{
                fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                fromLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"As Low As")];
                fromLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
                fromLabel.textColor = [UIColor blackColor];
                [priceFromLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                [self addSubview:fromLabel];
                [self addSubview:priceFromLabel];
                self.heightCell += heightLabelWithDistance;
                
                configLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                configLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Configured")];
                configLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
                toLabel.textColor = [UIColor blackColor];
                [priceConfigLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                self.heightCell += heightLabelWithDistance;
                [self addSubview:configLabel];
                [self addSubview:priceConfigLabel];
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
    self.heightofInfoView = self.heightCell;
    //  Liam Update RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)view;
                [label setTextAlignment:NSTextAlignmentRight];
            }
        }
    }
    //  End RTL
}
@end
