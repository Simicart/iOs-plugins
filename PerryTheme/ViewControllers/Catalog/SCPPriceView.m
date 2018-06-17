//
//  SCPPriceView.m
//  SimiCartPluginFW
//
//  Created by Liam on 5/2/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPPriceView.h"
#import "SCPGlobalVars.h"

@implementation SCPPriceView
- (void)showPriceWithProduct:(SimiProductModel *)product widthView:(float)width fontSize:(float)value{
    fontSize = value;
    heightContent = 0;
    self.productModel = product;
    self.widthView = width;
    if (self.productModel.appPrices) {
        self.appPrice = self.productModel.appPrices;
    }else
        self.appPrice  = [NSDictionary new];
    if (self.productModel.appTierPrices) {
        self.tierPrices = [[NSMutableArray alloc]initWithArray:self.productModel.appTierPrices];
    }
    [self configInterfaceWithPriceWidth:width];
    [self.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    if ([NSStringFromClass([self class]) isEqualToString:@"SCPriceView"]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:SCPriceView_BeginShowPriceNoOptions object:self userInfo:@{KEYEVENT.PRICEVIEW.product:product}];
        if (self.isDiscontinue) {
            self.isDiscontinue = NO;
            return;
        }
    }
    [self processShowPriceWithNoOptions];
    [self updatePriceViewFrame];
}

- (void)showPriceInLineWithConfiguableProduct{
    NSString *regularPrice = @"";
    NSString *specialPrice = @"";
    if ([[self.appPrice valueForKey:@"has_special_price"]intValue] == 1) {
        if ([self.appPrice valueForKey:@"price_label"] && [self.appPrice valueForKey:@"regular_price"]) {
            regularPrice = [NSString stringWithFormat:@"%@",[self.appPrice valueForKey:@"regular_price"]];
        }
        if ([[self.appPrice valueForKey:@"show_ex_in_price"]intValue] == 1) {
            if ([self.appPrice valueForKey:@"price_including_tax"]) {
                specialPrice = [NSString stringWithFormat:@"%@",[[self.appPrice valueForKey:@"price_including_tax"] valueForKey:@"price"]];
            }else if ([self.appPrice valueForKey:@"price_excluding_tax"]) {
                specialPrice = [NSString stringWithFormat:@"%@",[[self.appPrice valueForKey:@"price_excluding_tax"] valueForKey:@"price"]];
            }
        }else{
            if ([self.appPrice valueForKey:@"price"]) {
                specialPrice = [NSString stringWithFormat:@"%@",[self.appPrice valueForKey:@"price"]];
            }
        }
    }else
    {
        if ([[self.appPrice valueForKey:@"show_ex_in_price"]intValue] == 1){
            if ([self.appPrice valueForKey:@"price_including_tax"]) {
                regularPrice = [NSString stringWithFormat:@"%@",[[self.appPrice valueForKey:@"price_including_tax"] valueForKey:@"price"]];
            }else if ([self.appPrice valueForKey:@"price_excluding_tax"]) {
                regularPrice = [NSString stringWithFormat:@"%@",[[self.appPrice valueForKey:@"price_excluding_tax"] valueForKey:@"price"]];
            }
        }else{
            if ([self.appPrice valueForKey:@"price"]) {
                regularPrice = [NSString stringWithFormat:@"%@",[self.appPrice valueForKey:@"price"]];
            }
        }
    }
    UIFont *boldFont = [UIFont fontWithName:SCP_FONT_SEMIBOLD size:fontSize];
    UIFont *lightFont = [UIFont fontWithName:SCP_FONT_REGULAR size:fontSize - 2];
    if (![specialPrice isEqualToString:@""]) {
        specialPrice = [[SimiFormatter sharedInstance] priceWithPrice:specialPrice];
    }
    regularPrice = [[SimiFormatter sharedInstance] priceWithPrice:regularPrice];
    if (![specialPrice isEqualToString:@""]) {
        float specialPriceWidth = [specialPrice sizeWithAttributes:@{NSFontAttributeName:boldFont}].width;
        float regularPriceWidth = [regularPrice sizeWithAttributes:@{NSFontAttributeName:lightFont}].width;
        SimiLabel *specialPriceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, specialPriceWidth, heightLabel) andFont:boldFont];
        [specialPriceLabel setTextColor:COLOR_WITH_HEX(@"#2d2d2d")];
        [specialPriceLabel setText:specialPrice];
        [self addSubview:specialPriceLabel];
        
        SimiLabel *regularPriceLabel = [SimiLabel new];
        [regularPriceLabel setFont:lightFont];
        [regularPriceLabel setText:regularPrice];
        [regularPriceLabel setTextColor:COLOR_WITH_HEX(@"#757575")];
        [self addSubview:regularPriceLabel];
        if ((specialPriceWidth + regularPriceWidth + SCP_GLOBALVARS.interitemSpacing) > self.widthView) {
            heightContent += heightLabel;
            [regularPriceLabel setFrame:CGRectMake(0, heightContent, regularPriceWidth, heightLabel)];
        }else{
            [regularPriceLabel setFrame:CGRectMake(specialPriceWidth + SCP_GLOBALVARS.interitemSpacing, heightContent, regularPriceWidth, heightLabel)];
        }
        heightContent += heightLabel;
        UIImageView *throughLineView = [[UIImageView alloc]initWithFrame:CGRectMake(0, heightLabel/2, regularPriceWidth, 1)];
        [throughLineView setBackgroundColor:COLOR_WITH_HEX(@"#757575")];
        [regularPriceLabel addSubview:throughLineView];
    }else{
        float regularPriceWidth = [regularPrice sizeWithAttributes:@{NSFontAttributeName:boldFont}].width;
        SimiLabel *regularPriceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, regularPriceWidth, heightLabel) andFont:boldFont];
        [regularPriceLabel setTextColor:COLOR_WITH_HEX(@"#2d2d2d")];
        [regularPriceLabel setText:regularPrice];
        [self addSubview:regularPriceLabel];
        heightContent += heightLabel;
    }
}

- (void)updateFontForPriceView{
    for(UIView *view in self.subviews){
        if ([view isKindOfClass:[SimiLabel class]]) {
            float titleFontSize = FONT_SIZE_LARGE;
            float priceFontSize = FONT_SIZE_MEDIUM;
            if (self.optionController != nil) {
                titleFontSize = FONT_SIZE_LARGE;
                priceFontSize = FONT_SIZE_LARGE;
            }
            SimiLabel *label = (SimiLabel*)view;
            label.adjustsFontSizeToFitWidth = YES;
            if (label.tag == priceBoldTitleTag) {
                [label setFont:[UIFont fontWithName:SCP_FONT_SEMIBOLD size:titleFontSize]];
                [label setTextColor:COLOR_WITH_HEX(@"#2d2d2d")];
            }else if(label.tag == priceTitleTag)
            {
                [label setFont:[UIFont fontWithName:SCP_FONT_REGULAR size:priceFontSize]];
                [label setTextColor:COLOR_WITH_HEX(@"#2d2d2d")];
            }else if(label.tag == priceTag)
            {
                [label setFont:[UIFont fontWithName:SCP_FONT_REGULAR size:priceFontSize]];
                [label setTextColor:COLOR_WITH_HEX(@"#2d2d2d")];
            }else if (label.tag == priceSpecialTag)
            {
                [label setFont:[UIFont fontWithName:SCP_FONT_REGULAR size:priceFontSize]];
                [label setTextColor:COLOR_WITH_HEX(@"#2d2d2d")];
            }
        }
    }
}


- (void)priceInLineWithSimpleProductWithOptions{
    NSDictionary *customOptions = nil;
    if ([[self.productModel valueForKey:@"app_prices"] isKindOfClass:[NSDictionary class]]) {
        customOptions = [self.productModel objectForKey:@"app_prices"];
    }
    NSString *regularPrice = @"";
    NSString *specialPrice = @"";
    NSArray *customOptionAllKey = [self.optionController.selectedCustomOptions allKeys];
    float customOptionExclPrice = 0;
    float customOptionInclPrice = 0;
    float customOptionPrice = 0;
    for (int i = 0; i < customOptionAllKey.count; i++) {
        NSString *key = [customOptionAllKey objectAtIndex:i];
        NSDictionary *customValue = [self.optionController.selectedCustomOptions valueForKey:key];
        customOptionExclPrice += [[customValue valueForKey:@"exclPrice"]floatValue];
        customOptionInclPrice += [[customValue valueForKey:@"inclPrice"]floatValue];
        customOptionPrice += [[customValue valueForKey:@"price"]floatValue];
    }
    
    if ([[self.appPrice valueForKey:@"has_special_price"]intValue] == 1) {
        if ([self.appPrice valueForKey:@"price_label"] && [self.appPrice valueForKey:@"regular_price"]) {
            float regularPriceValue = [[self.appPrice valueForKey:@"regular_price"]floatValue];
            if ([[customOptions valueForKey:@"show_ex_in_price"]boolValue]) {
                regularPriceValue += customOptionInclPrice;
            }else
                regularPriceValue += customOptionPrice;
            regularPrice = [NSString stringWithFormat:@"%f",regularPriceValue];
        }
        if ([[self.appPrice valueForKey:@"show_ex_in_price"]intValue] == 1) {
            if ([self.appPrice valueForKey:@"price_including_tax"]) {
                float priceIncludingTaxValue = [[[self.appPrice valueForKey:@"price_including_tax"] valueForKey:@"price"]floatValue] + customOptionInclPrice;
                specialPrice = [NSString stringWithFormat:@"%f",priceIncludingTaxValue];
            }else if ([self.appPrice valueForKey:@"price_excluding_tax"]) {
                float priceExcludingTaxValue = [[[self.appPrice valueForKey:@"price_excluding_tax"] valueForKey:@"price"]floatValue] + customOptionExclPrice;
                specialPrice = [[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%f", priceExcludingTaxValue]];
            }
        }else{
            if ([self.appPrice valueForKey:@"price"]) {
                float priceValue = [[self.appPrice valueForKey:@"price"]floatValue] + customOptionPrice;
                specialPrice = [NSString stringWithFormat:@"%f",priceValue];
            }
        }
    }else
    {
        if ([[self.appPrice valueForKey:@"show_ex_in_price"]intValue] == 1)
        {
            if ([self.appPrice valueForKey:@"price_including_tax"]) {
                float priceIncludingTaxValue = [[[self.appPrice valueForKey:@"price_including_tax"] valueForKey:@"price"]floatValue] + customOptionInclPrice;
                regularPrice = [NSString stringWithFormat:@"%f",priceIncludingTaxValue];
            }else if ([self.appPrice valueForKey:@"price_excluding_tax"]) {
                float priceExcludingTaxValue = [[[self.appPrice valueForKey:@"price_excluding_tax"] valueForKey:@"price"]floatValue] + customOptionExclPrice;
                regularPrice = [NSString stringWithFormat:@"%f",priceExcludingTaxValue];
            }
        }else{
            if ([self.appPrice valueForKey:@"price"]) {
                float priceValue = [[self.appPrice valueForKey:@"price"]floatValue] + customOptionPrice;
                regularPrice = [NSString stringWithFormat:@"%f",priceValue];
            }
        }
    }
    
    UIFont *boldFont = [UIFont fontWithName:SCP_FONT_SEMIBOLD size:30];
    UIFont *lightFont = [UIFont fontWithName:SCP_FONT_REGULAR size:22];
    if (![specialPrice isEqualToString:@""]) {
        specialPrice = [[SimiFormatter sharedInstance] priceWithPrice:specialPrice];
    }
    regularPrice = [[SimiFormatter sharedInstance] priceWithPrice:regularPrice];
    if (![specialPrice isEqualToString:@""]) {
        float specialPriceWidth = [specialPrice sizeWithAttributes:@{NSFontAttributeName:boldFont}].width;
        float regularPriceWidth = [regularPrice sizeWithAttributes:@{NSFontAttributeName:lightFont}].width;
        SimiLabel *specialPriceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, widthPrice - 10, 28) andFont:boldFont];
        [specialPriceLabel setTextColor:COLOR_WITH_HEX(@"#F69435")];
        [specialPriceLabel setTextAlignment:NSTextAlignmentRight];
        [specialPriceLabel setText:specialPrice];
        [self addSubview:specialPriceLabel];
        
        SimiLabel *regularPriceLabel = [SimiLabel new];
        [regularPriceLabel setFont:lightFont];
        [regularPriceLabel setText:regularPrice];
        [regularPriceLabel setTextColor:COLOR_WITH_HEX(@"#757575")];
        [self addSubview:regularPriceLabel];
        if ((specialPriceWidth + regularPriceWidth + SCP_GLOBALVARS.interitemSpacing) > self.widthView) {
            heightContent += heightLabel;
            [regularPriceLabel setFrame:CGRectMake(0, heightContent, regularPriceWidth, 21)];
        }else{
            [regularPriceLabel setFrame:CGRectMake(widthPrice + 10, heightContent+7, regularPriceWidth, 21)];
        }
        heightContent += 28;
        UIImageView *throughLineView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10.5, regularPriceWidth, 1)];
        [throughLineView setBackgroundColor:COLOR_WITH_HEX(@"#757575")];
        [regularPriceLabel addSubview:throughLineView];
    }else{
        SimiLabel *regularPriceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, self.widthView, 28) andFont:boldFont];
        [regularPriceLabel setTextAlignment:NSTextAlignmentCenter];
        [regularPriceLabel setTextColor:COLOR_WITH_HEX(@"#F69435")];
        [regularPriceLabel setText:regularPrice];
        [self addSubview:regularPriceLabel];
        heightContent += 28;
    }
    [self showPriceWithLowPrice];
}

- (void)priceInLineWithConfigurableProductWithOptions{
    NSDictionary *customOptions = nil;
    if ([[self.productModel valueForKey:@"app_prices"] isKindOfClass:[NSDictionary class]]) {
        customOptions = [self.productModel objectForKey:@"app_prices"];
    }
    
    NSArray *customOptionAllKey = [self.optionController.selectedCustomOptions allKeys];
    float customOptionExclPrice = 0;
    float customOptionInclPrice = 0;
    float customOptionPrice = 0;
    for (int i = 0; i < customOptionAllKey.count; i++) {
        NSString *key = [customOptionAllKey objectAtIndex:i];
        NSDictionary *customValue = [self.optionController.selectedCustomOptions valueForKey:key];
        customOptionExclPrice += [[customValue valueForKey:@"exclPrice"]floatValue];
        customOptionInclPrice += [[customValue valueForKey:@"inclPrice"]floatValue];
        customOptionPrice += [[customValue valueForKey:@"price"]floatValue];
    }
    
    NSDictionary *configOptions = nil;
    if ([[[[self.productModel valueForKey:@"app_options"]valueForKey:@"configurable_options"]valueForKey:@"taxConfig"] isKindOfClass:[NSDictionary class]]) {
        configOptions = [[[self.productModel valueForKey:@"app_options"]valueForKey:@"configurable_options"]valueForKey:@"taxConfig"];
    }
    NSArray *configOptionAllKey = [self.optionController.selectedConfigureOptions allKeys];
    float configOptionExclPrice = 0;
    float configOptionInclPrice = 0;
    BOOL isMagentoTwo = GLOBALVAR.isMagento2;
    
    if (!isMagentoTwo) {
        for (int i = 0; i < configOptionAllKey.count; i++) {
            NSString *key = [configOptionAllKey objectAtIndex:i];
            NSDictionary *configValue = [self.optionController.selectedConfigureOptions valueForKey:key];
            configOptionExclPrice += [[configValue valueForKey:@"exclPrice"]floatValue];
            configOptionInclPrice += [[configValue valueForKey:@"inclPrice"]floatValue];
        }
    }
    NSString *regularPrice = @"";
    NSString *specialPrice = @"";
    
    if ([[self.appPrice valueForKey:@"has_special_price"]intValue] == 1) {
        if ([self.appPrice valueForKey:@"price_label"] && [self.appPrice valueForKey:@"regular_price"]) {
            float regularPriceValue = [[self.appPrice valueForKey:@"regular_price"]floatValue];
            if (isMagentoTwo) {
                if (self.optionController.selectedConfigureOptions.count > 0) {
                    regularPriceValue = [[self.optionController.selectedConfigureOptions valueForKey:configurable_oldPrice]floatValue];
                }
            }
            if ([[configOptions valueForKey:@"showIncludeTax"]boolValue] || [[configOptions valueForKey:@"showBothPrices"]boolValue]) {
                regularPriceValue += configOptionInclPrice;
            }else
            {
                regularPriceValue += configOptionExclPrice;
            }
            if ([[customOptions valueForKey:@"show_ex_in_price"]boolValue]) {
                regularPriceValue += customOptionInclPrice;
            }else
                regularPriceValue += customOptionPrice;
            regularPrice = [NSString stringWithFormat:@"%f",regularPriceValue];
        }
        if ([[self.appPrice valueForKey:@"show_ex_in_price"]intValue] == 1) {
            if ([self.appPrice valueForKey:@"price_including_tax"]) {
                float priceIncludingTaxValue = [[[self.appPrice valueForKey:@"price_including_tax"] valueForKey:@"price"] floatValue] + customOptionInclPrice + configOptionInclPrice;
                if (isMagentoTwo) {
                    if (self.optionController.selectedConfigureOptions.count > 0) {
                        priceIncludingTaxValue = [[self.optionController.selectedConfigureOptions valueForKey:configurable_finalPrice] floatValue] + customOptionExclPrice;
                    }
                }
                specialPrice = [NSString stringWithFormat:@"%f",priceIncludingTaxValue];
            }else if ([self.appPrice valueForKey:@"price_excluding_tax"]) {
                float priceExcludingTaxValue = [[[self.appPrice valueForKey:@"price_excluding_tax"] valueForKey:@"price"]floatValue] + configOptionExclPrice + customOptionExclPrice;
                if (isMagentoTwo) {
                    if (self.optionController.selectedConfigureOptions.count > 0) {
                        priceExcludingTaxValue = [[self.optionController.selectedConfigureOptions valueForKey:configurable_basePrice]floatValue] + customOptionExclPrice;
                    }
                }
                specialPrice = [NSString stringWithFormat:@"%f",priceExcludingTaxValue];
            }
        }else{
            if ([self.appPrice valueForKey:@"price"]) {
                SimiLabel *priceValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(priceX, heightContent, widthPrice, heightLabel)];
                priceValueLabel.tag = priceSpecialTag;
                float priceValue = [[self.appPrice valueForKey:@"price"]floatValue];
                if (isMagentoTwo) {
                    if (self.optionController.selectedConfigureOptions.count > 0) {
                        priceValue = [[self.optionController.selectedConfigureOptions valueForKey:configurable_finalPrice]floatValue];
                    }
                }
                if ([[configOptions valueForKey:@"showIncludeTax"]boolValue] || [[configOptions valueForKey:@"showBothPrices"]boolValue]) {
                    priceValue += configOptionInclPrice + customOptionPrice;
                }else
                {
                    priceValue += configOptionExclPrice + customOptionPrice;
                }
                specialPrice = [NSString stringWithFormat:@"%f",priceValue];
            }
        }
    }else
    {
        if ([[self.appPrice valueForKey:@"show_ex_in_price"]intValue] == 1){
            if ([self.appPrice valueForKey:@"price_including_tax"]) {
                float priceIncludingTaxValue = [[[self.appPrice valueForKey:@"price_including_tax"] valueForKey:@"price"]floatValue] + configOptionInclPrice + customOptionInclPrice;
                if (isMagentoTwo) {
                    if (self.optionController.selectedConfigureOptions.count > 0) {
                        priceIncludingTaxValue = [[self.optionController.selectedConfigureOptions valueForKey:configurable_finalPrice]floatValue] + customOptionExclPrice;
                    }
                }
                regularPrice = [NSString stringWithFormat:@"%f",priceIncludingTaxValue];
            }else if ([self.appPrice valueForKey:@"price_excluding_tax"]) {
                float priceExcludingTaxValue = [[[self.appPrice valueForKey:@"price_excluding_tax"] valueForKey:@"price"]floatValue] + configOptionExclPrice + customOptionExclPrice;
                if (isMagentoTwo) {
                    if (self.optionController.selectedConfigureOptions.count > 0) {
                        priceExcludingTaxValue = [[self.optionController.selectedConfigureOptions valueForKey:configurable_basePrice]floatValue] +  + customOptionExclPrice;
                    }
                }
                regularPrice = [NSString stringWithFormat:@"%f",priceExcludingTaxValue];
            }
        }else{
            if ([self.appPrice valueForKey:@"price"]) {
                float priceValue = [[self.appPrice valueForKey:@"price"]floatValue];
                if (isMagentoTwo) {
                    if (self.optionController.selectedConfigureOptions.count > 0) {
                        priceValue = [[self.optionController.selectedConfigureOptions valueForKey:configurable_finalPrice]floatValue];
                    }
                }
                if ([[configOptions valueForKey:@"showIncludeTax"]boolValue] || [[configOptions valueForKey:@"showBothPrices"]boolValue]) {
                    priceValue += configOptionInclPrice + customOptionPrice;
                }else
                {
                    priceValue += configOptionExclPrice + customOptionPrice;
                }
                regularPrice = [NSString stringWithFormat:@"%f",priceValue];
            }
        }
    }
    
    UIFont *boldFont = [UIFont fontWithName:SCP_FONT_SEMIBOLD size:30];
    UIFont *lightFont = [UIFont fontWithName:SCP_FONT_REGULAR size:22];
    if (![specialPrice isEqualToString:@""]) {
        specialPrice = [[SimiFormatter sharedInstance] priceWithPrice:specialPrice];
    }
    regularPrice = [[SimiFormatter sharedInstance] priceWithPrice:regularPrice];
    if (![specialPrice isEqualToString:@""]) {
        float specialPriceWidth = [specialPrice sizeWithAttributes:@{NSFontAttributeName:boldFont}].width;
        float regularPriceWidth = [regularPrice sizeWithAttributes:@{NSFontAttributeName:lightFont}].width;
        SimiLabel *specialPriceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, widthPrice - 10, 28) andFont:boldFont];
        [specialPriceLabel setTextColor:COLOR_WITH_HEX(@"#F69435")];
        [specialPriceLabel setTextAlignment:NSTextAlignmentRight];
        [specialPriceLabel setText:specialPrice];
        [self addSubview:specialPriceLabel];
        
        SimiLabel *regularPriceLabel = [SimiLabel new];
        [regularPriceLabel setFont:lightFont];
        [regularPriceLabel setText:regularPrice];
        [regularPriceLabel setTextColor:COLOR_WITH_HEX(@"#757575")];
        [self addSubview:regularPriceLabel];
        if ((specialPriceWidth + regularPriceWidth + SCP_GLOBALVARS.interitemSpacing) > self.widthView) {
            heightContent += heightLabel;
            [regularPriceLabel setFrame:CGRectMake(0, heightContent, regularPriceWidth, heightLabel)];
        }else{
            [regularPriceLabel setFrame:CGRectMake(widthPrice + 10, heightContent+7, regularPriceWidth, 21)];
        }
        heightContent += 34;
        UIImageView *throughLineView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10.5, regularPriceWidth, 1)];
        [throughLineView setBackgroundColor:COLOR_WITH_HEX(@"#757575")];
        [regularPriceLabel addSubview:throughLineView];
    }else{
        SimiLabel *regularPriceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, self.widthView, 28) andFont:boldFont];
        [regularPriceLabel setTextAlignment:NSTextAlignmentCenter];
        [regularPriceLabel setTextColor:COLOR_WITH_HEX(@"#F69435")];
        [regularPriceLabel setText:regularPrice];
        [self addSubview:regularPriceLabel];
        heightContent += 28;
    }
    [self showPriceWithLowPrice];
}

@end
