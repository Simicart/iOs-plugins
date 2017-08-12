//
//  SCGiftCardPriceView.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/11/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCGiftCardPriceView.h"

@implementation SCGiftCardPriceView
- (void)setProductModel:(SimiProductModel *)product andWidthView: (float)width
{
    self.productModel = product;
    self.widthView = width;
    if ([[self.productModel valueForKey:@"app_prices"] isKindOfClass:[NSDictionary class]]) {
        self.appPrice = [self.productModel valueForKey:@"app_prices"];
    }else
        self.appPrice  = [NSDictionary new];
    float heightContent = 0;
    float heightLabel = 20;
    float widthTitle = width/2;
    float widthPrice = width/2;
    if ([SimiGlobalVar sharedInstance].isReverseLanguage) {
        widthTitle = width*3/5;
        widthPrice = width*2/5;
    }
    float titleX = 0;
    float priceX = widthTitle;
    
    priceBoldTitleTag = 99;
    priceTitleTag = 999;
    priceTag = 9999;
    priceSpecialTag = 1111;
    
#pragma mark Bundle
    [self.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    /**
     Have Minimal Price
     */
    if([[self.appPrice valueForKey:@"minimal_price"]intValue] == 1) {
        /**
         Show exclude tax Price
         */
        if([[self.appPrice valueForKey:@"show_ex_in_price"]intValue] == 1) {
            if ([self.appPrice valueForKey:@"price_label"]) {
                SimiLabel *priceTitleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, width, heightLabel)];
                priceTitleLabel.tag = priceBoldTitleTag;
                [priceTitleLabel setText:[NSString stringWithFormat:@"%@",SCLocalizedString([self.appPrice valueForKey:@"price_label"])]];
                [self addSubview:priceTitleLabel];
                heightContent += heightLabel;
            }
            
            if ([self.appPrice valueForKey:@"price_excluding_tax"]) {
                SimiLabel *priceExcludingTaxTilteLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleX, heightContent, widthTitle, heightLabel)];
                priceExcludingTaxTilteLabel.tag = priceTitleTag;
                [priceExcludingTaxTilteLabel setText:[NSString stringWithFormat:@"%@:",SCLocalizedString([[self.appPrice valueForKey:@"price_excluding_tax"] valueForKey:@"label"])]];
                [self addSubview:priceExcludingTaxTilteLabel];
                
                SimiLabel *priceExcludingTaxValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(priceX, heightContent, widthPrice, heightLabel)];
                priceExcludingTaxValueLabel.tag = priceTag;
                [priceExcludingTaxValueLabel setText:[[SimiFormatter sharedInstance] priceWithPrice: [NSString stringWithFormat:@"%@",[[self.appPrice valueForKey:@"price_excluding_tax"] valueForKey:@"price"]]]];
                [self addSubview:priceExcludingTaxValueLabel];
                heightContent += heightLabel;
            }
            
            if ([[self.appPrice valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrice valueForKey:@"weee"]) {
                SimiLabel *weeePriceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, width, heightLabel)];
                weeePriceLabel.tag = priceTag;
                NSError *err = nil;
                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]
                                                              initWithData: [[NSString stringWithFormat:@"%@",[self.appPrice valueForKey:@"weee"]] dataUsingEncoding:NSUTF8StringEncoding]
                                                              options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                              documentAttributes: nil
                                                              error: &err];
                [weeePriceLabel setAttributedText:attributeString];
                [self addSubview:weeePriceLabel];
                heightContent += heightLabel;
            }
            
            if ([self.appPrice valueForKey:@"price_including_tax"]) {
                
                SimiLabel *priceIncludingTaxTilteLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleX, heightContent, widthTitle, heightLabel)];
                priceIncludingTaxTilteLabel.tag = priceTitleTag;
                [priceIncludingTaxTilteLabel setText:[NSString stringWithFormat:@"%@:",SCLocalizedString([[self.appPrice valueForKey:@"price_including_tax"] valueForKey:@"label"])]];
                [self addSubview:priceIncludingTaxTilteLabel];
                
                SimiLabel *priceIncludingTaxValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(priceX, heightContent, widthPrice, heightLabel)];
                priceIncludingTaxValueLabel.tag = priceTag;
                [priceIncludingTaxValueLabel setText:[[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[[self.appPrice valueForKey:@"price_including_tax"] valueForKey:@"price"]]]];
                [self addSubview:priceIncludingTaxValueLabel];
                heightContent += heightLabel;
            }
        }else
        /**
         Don't show exclude Price
         */
        {
            if ([self.appPrice valueForKey:@"price_label"] && [self.appPrice valueForKey:@"price"]) {
                SimiLabel *priceTilteLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleX, heightContent, widthTitle, heightLabel)];
                priceTilteLabel.tag = priceTitleTag;
                [priceTilteLabel setText:[NSString stringWithFormat:@"%@:",SCLocalizedString([self.appPrice valueForKey:@"price_label"])]];
                [self addSubview:priceTilteLabel];
                
                SimiLabel *priceValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(priceX, heightContent, widthPrice, heightLabel)];
                priceValueLabel.tag = priceTag;
                [priceValueLabel setText:[[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[self.appPrice valueForKey:@"price"]]]];
                [self addSubview:priceValueLabel];
                heightContent += heightLabel;
            }
            
            if ([[self.appPrice valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrice valueForKey:@"weee"]) {
                SimiLabel *weeePriceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, width, heightLabel)];
                weeePriceLabel.tag = priceTag;
                NSError *err = nil;
                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]
                                                              initWithData: [[NSString stringWithFormat:@"%@",[self.appPrice valueForKey:@"weee"]] dataUsingEncoding:NSUTF8StringEncoding]
                                                              options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                              documentAttributes: nil
                                                              error: &err];
                [weeePriceLabel setAttributedText:attributeString];
                [self addSubview:weeePriceLabel];
                heightContent += heightLabel;
            }
            
            if ([self.appPrice valueForKey:@"price_in"] && ![[self.appPrice valueForKey:@"price_in"] isEqualToString:@""]) {
                SimiLabel *priceInLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, width, heightLabel)];
                priceInLabel.tag = priceTag;
                [priceInLabel setText:[[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[self.appPrice valueForKey:@"price_in"]]]];
                [self addSubview:priceInLabel];
                heightContent += heightLabel;
            }
        }
    }else
    /**
     Don't Have Minimal Price
     */
    {
        /**
         Show From To Tax Price
         */
        if ([[self.appPrice valueForKey:@"show_from_to_tax_price"]intValue] == 1) {
            /**
             Show Exclude in Price
             */
            if ([[self.appPrice valueForKey:@"show_ex_in_price"]intValue] == 1) {
                if ([self.appPrice valueForKey:@"product_from_label"]) {
                    SimiLabel *productFromTitleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, width, heightLabel)];
                    productFromTitleLabel.tag = priceBoldTitleTag;
                    [productFromTitleLabel setText:[NSString stringWithFormat:@"%@:",SCLocalizedString([self.appPrice valueForKey:@"product_from_label"])]];
                    [self addSubview:productFromTitleLabel];
                    heightContent += heightLabel;
                }
                
                if ([self.appPrice valueForKey:@"from_price_excluding_tax"]) {
                    SimiLabel *fromPriceExcludingTaxTilteLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleX, heightContent, widthTitle, heightLabel)];
                    fromPriceExcludingTaxTilteLabel.tag = priceTitleTag;
                    [fromPriceExcludingTaxTilteLabel setText:[NSString stringWithFormat:@"%@:",SCLocalizedString([[self.appPrice valueForKey:@"from_price_excluding_tax"] valueForKey:@"label"])]];
                    [self addSubview:fromPriceExcludingTaxTilteLabel];
                    
                    SimiLabel *fromPriceExcludingTaxValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(priceX, heightContent, widthPrice, heightLabel)];
                    fromPriceExcludingTaxValueLabel.tag = priceTag;
                    [fromPriceExcludingTaxValueLabel setText:[[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[[self.appPrice valueForKey:@"from_price_excluding_tax"] valueForKey:@"price"]]]];
                    [self addSubview:fromPriceExcludingTaxValueLabel];
                    heightContent += heightLabel;
                }
                
                if ([self.appPrice valueForKey:@"from_price_including_tax"]) {
                    SimiLabel *fromPriceIncludingTaxTilteLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleX, heightContent, widthTitle, heightLabel)];
                    fromPriceIncludingTaxTilteLabel.tag = priceTitleTag;
                    [fromPriceIncludingTaxTilteLabel setText:[NSString stringWithFormat:@"%@:",SCLocalizedString([[self.appPrice valueForKey:@"from_price_including_tax"] valueForKey:@"label"])]];
                    [self addSubview:fromPriceIncludingTaxTilteLabel];
                    
                    SimiLabel *fromPriceIncludingTaxValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(priceX, heightContent, widthPrice, heightLabel)];
                    fromPriceIncludingTaxValueLabel.tag = priceTag;
                    [fromPriceIncludingTaxValueLabel setText:[[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[[self.appPrice valueForKey:@"from_price_including_tax"] valueForKey:@"price"]]]];
                    [self addSubview:fromPriceIncludingTaxValueLabel];
                    heightContent += heightLabel;
                }
                
                if ([[self.appPrice valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrice valueForKey:@"weee"]) {
                    SimiLabel *weeePriceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, width, heightLabel)];
                    weeePriceLabel.tag = priceTag;
                    NSError *err = nil;
                    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]
                                                                  initWithData: [[NSString stringWithFormat:@"%@",[self.appPrice valueForKey:@"weee"]] dataUsingEncoding:NSUTF8StringEncoding]
                                                                  options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                                  documentAttributes: nil
                                                                  error: &err];
                    [weeePriceLabel setAttributedText:attributeString];
                    [self addSubview:weeePriceLabel];
                    heightContent += heightLabel;
                }
                
                if ([self.appPrice valueForKey:@"product_to_label"]) {
                    SimiLabel *productToTitleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, width, heightLabel)];
                    productToTitleLabel.tag = priceBoldTitleTag;
                    [productToTitleLabel setText:[NSString stringWithFormat:@"%@:",SCLocalizedString([self.appPrice valueForKey:@"product_to_label"])]];
                    [self addSubview:productToTitleLabel];
                    heightContent += heightLabel;
                }
                if ([self.appPrice valueForKey:@"to_price_excluding_tax"]) {
                    SimiLabel *toPriceExcludingTaxTilteLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleX, heightContent, widthTitle, heightLabel)];
                    toPriceExcludingTaxTilteLabel.tag = priceTitleTag;
                    [toPriceExcludingTaxTilteLabel setText:[NSString stringWithFormat:@"%@:",[[self.appPrice valueForKey:@"to_price_excluding_tax"] valueForKey:@"label"]]];
                    [self addSubview:toPriceExcludingTaxTilteLabel];
                    
                    SimiLabel *toPriceExcludingTaxValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(priceX, heightContent, widthPrice, heightLabel)];
                    toPriceExcludingTaxValueLabel.tag = priceTag;
                    [toPriceExcludingTaxValueLabel setText:[[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[[self.appPrice valueForKey:@"to_price_excluding_tax"] valueForKey:@"price"]]]];
                    [self addSubview:toPriceExcludingTaxValueLabel];
                    heightContent += heightLabel;
                }
                if ([self.appPrice valueForKey:@"to_price_including_tax"]) {
                    SimiLabel *toPriceIncludingTaxTilteLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleX, heightContent, widthTitle, heightLabel)];
                    toPriceIncludingTaxTilteLabel.tag = priceTitleTag;
                    [toPriceIncludingTaxTilteLabel setText:[NSString stringWithFormat:@"%@:",SCLocalizedString([[self.appPrice valueForKey:@"to_price_including_tax"] valueForKey:@"label"])]];
                    [self addSubview:toPriceIncludingTaxTilteLabel];
                    
                    SimiLabel *toPriceIncludingTaxValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(priceX, heightContent, widthPrice, heightLabel)];
                    toPriceIncludingTaxValueLabel.tag = priceTag;
                    [toPriceIncludingTaxValueLabel setText:[[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[[self.appPrice valueForKey:@"to_price_including_tax"] valueForKey:@"price"]]]];
                    [self addSubview:toPriceIncludingTaxValueLabel];
                    heightContent += heightLabel;
                }
            }
            else
            /**
             Don't Show Exclude in Price
             */
            {
                if ([self.appPrice valueForKey:@"product_from_label"] && [self.appPrice valueForKey:@"from_price"]) {
                    SimiLabel *productFromTilteLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleX, heightContent, widthTitle, heightLabel)];
                    productFromTilteLabel.tag = priceTitleTag;
                    [productFromTilteLabel setText:[NSString stringWithFormat:@"%@:",SCLocalizedString([self.appPrice valueForKey:@"product_from_label"])]];
                    [self addSubview:productFromTilteLabel];
                    
                    SimiLabel *productFromValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(priceX, heightContent, widthPrice, heightLabel)];
                    productFromValueLabel.tag = priceTag;
                    [productFromValueLabel setText:[[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[self.appPrice valueForKey:@"from_price"]]]];
                    [self addSubview:productFromValueLabel];
                    heightContent += heightLabel;
                }
                
                if ([self.appPrice valueForKey:@"product_to_label"] && [self.appPrice valueForKey:@"to_price"]) {
                    SimiLabel *productToTilteLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleX, heightContent, widthTitle, heightLabel)];
                    productToTilteLabel.tag = priceTitleTag;
                    [productToTilteLabel setText:[NSString stringWithFormat:@"%@:",SCLocalizedString([self.appPrice valueForKey:@"product_to_label"])]];
                    [self addSubview:productToTilteLabel];
                    
                    SimiLabel *productToValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(priceX, heightContent, widthPrice, heightLabel)];
                    productToValueLabel.tag = priceTag;
                    [productToValueLabel setText:[[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[self.appPrice valueForKey:@"to_price"]]]];
                    [self addSubview:productToValueLabel];
                    heightContent += heightLabel;
                }
                
                if ([[self.appPrice valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrice valueForKey:@"weee"]) {
                    SimiLabel *weeePriceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, width, heightLabel)];
                    weeePriceLabel.tag = priceTag;
                    NSError *err = nil;
                    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]
                                                                  initWithData: [[NSString stringWithFormat:@"%@",[self.appPrice valueForKey:@"weee"]] dataUsingEncoding:NSUTF8StringEncoding]
                                                                  options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                                  documentAttributes: nil
                                                                  error: &err];
                    [weeePriceLabel setAttributedText:attributeString];
                    [self addSubview:weeePriceLabel];
                    heightContent += heightLabel;
                }
            }
        }else
        /**
         Don't Show From To Tax Price
         */
        {
            /**
             Show Exclud In Price
             */
            if ([[self.appPrice valueForKey:@"show_ex_in_price"]intValue] == 1) {
                if ([self.appPrice valueForKey:@"product_from_label"] && [self.appPrice valueForKey:@"from_price"]) {
                    SimiLabel *productFromTilteLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleX, heightContent, widthTitle, heightLabel)];
                    productFromTilteLabel.tag = priceTitleTag;
                    [productFromTilteLabel setText:[NSString stringWithFormat:@"%@:",SCLocalizedString([self.appPrice valueForKey:@"product_from_label"])]];
                    [self addSubview:productFromTilteLabel];
                    
                    SimiLabel *productFromValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(priceX, heightContent, widthPrice, heightLabel)];
                    productFromValueLabel.tag = priceTag;
                    [productFromValueLabel setText:[[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[self.appPrice valueForKey:@"from_price"]]]];
                    [self addSubview:productFromValueLabel];
                    heightContent += heightLabel;
                }
                
                if ([[self.appPrice valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrice valueForKey:@"weee"]) {
                    SimiLabel *weeePriceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, width, heightLabel)];
                    weeePriceLabel.tag = priceTag;
                    NSError *err = nil;
                    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]
                                                                  initWithData: [[NSString stringWithFormat:@"%@",[self.appPrice valueForKey:@"weee"]] dataUsingEncoding:NSUTF8StringEncoding]
                                                                  options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                                  documentAttributes: nil
                                                                  error: &err];
                    [weeePriceLabel setAttributedText:attributeString];
                    [self addSubview:weeePriceLabel];
                    heightContent += heightLabel;
                }
                
                if ([self.appPrice valueForKey:@"product_to_label"] && [self.appPrice valueForKey:@"to_price"]) {
                    SimiLabel *productToTilteLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleX, heightContent, widthTitle, heightLabel)];
                    productToTilteLabel.tag = priceTitleTag;
                    [productToTilteLabel setText:[NSString stringWithFormat:@"%@:",SCLocalizedString([self.appPrice valueForKey:@"product_to_label"])]];
                    [self addSubview:productToTilteLabel];
                    
                    SimiLabel *productToValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(priceX, heightContent, widthPrice, heightLabel)];
                    productToValueLabel.tag = priceTag;
                    [productToValueLabel setText:[[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[self.appPrice valueForKey:@"to_price"]]]];
                    [self addSubview:productToValueLabel];
                    heightContent += heightLabel;
                }
            }else
            /**
             Don't Show Exclude In Price
             */
            {
                if ([self.appPrice valueForKey:@"price"]) {
                    SimiLabel *priceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, width, heightLabel)];
                    priceLabel.tag = priceTag;
                    [priceLabel setText:[[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[self.appPrice valueForKey:@"price"]]]];
                    [self addSubview:priceLabel];
                    heightContent += heightLabel;
                }
                
                if ([[self.appPrice valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrice valueForKey:@"weee"]) {
                    SimiLabel *weeePriceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, heightContent, width, heightLabel)];
                    weeePriceLabel.tag = priceTag;
                    NSError *err = nil;
                    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]
                                                                  initWithData: [[NSString stringWithFormat:@"%@",[self.appPrice valueForKey:@"weee"]] dataUsingEncoding:NSUTF8StringEncoding]
                                                                  options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                                  documentAttributes: nil
                                                                  error: &err];
                    [weeePriceLabel setAttributedText:attributeString];
                    [self addSubview:weeePriceLabel];
                    heightContent += heightLabel;
                }
            }
        }
    }
}
@end
