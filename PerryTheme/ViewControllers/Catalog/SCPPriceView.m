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
    UIFont *boldFont = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:fontSize];
    UIFont *lightFont = [UIFont fontWithName:THEME_FONT_NAME size:fontSize - 1];
    if (![specialPrice isEqualToString:@""]) {
        specialPrice = [[SimiFormatter sharedInstance] priceWithPrice:specialPrice];
    }
    regularPrice = [[SimiFormatter sharedInstance] priceWithPrice:regularPrice];
    if (![specialPrice isEqualToString:@""]) {
        float specialPriceWidth = [specialPrice sizeWithAttributes:@{NSFontAttributeName:boldFont}].width;
        float regularPriceWidth = [regularPrice sizeWithAttributes:@{NSFontAttributeName:lightFont}].width;
        SimiLabel *specialPriceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, specialPriceWidth, heightLabel) andFont:boldFont];
        [specialPriceLabel setText:specialPrice];
        [self addSubview:specialPriceLabel];
        
        SimiLabel *regularPriceLabel = [SimiLabel new];
        [regularPriceLabel setFont:lightFont];
        [regularPriceLabel setText:regularPrice];
        [self addSubview:regularPriceLabel];
        if ((specialPriceWidth + regularPriceWidth + SCP_GLOBALVARS.interitemSpacing) > self.widthView) {
            heightContent += heightLabel;
            regularPriceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, regularPriceWidth, heightLabel)];
        }else{
            regularPriceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(specialPriceWidth + SCP_GLOBALVARS.interitemSpacing, heightContent, regularPriceWidth, heightLabel)];
        }
        heightContent += heightLabel;
    }else{
        float regularPriceWidth = [regularPrice sizeWithAttributes:@{NSFontAttributeName:boldFont}].width;
        SimiLabel *regularPriceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, regularPriceWidth, heightLabel) andFont:boldFont];
        [regularPriceLabel setText:regularPrice];
        [self addSubview:regularPriceLabel];
        heightContent += heightLabel;
    }
}
@end
