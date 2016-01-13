//
//  ZThemeCollectionViewCell.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/7/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeCollectionViewCell.h"

@implementation ZThemeCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark
#pragma mark setProduct
- (void)cusSetProductModel:(SimiProductModel *)productModel_{
    NSString *viewIdentifier = @"ZThemeCollectionCell_SubView";
    if (self.isChangeLayOut) {
        [self setInterfaceCell];
    }
    if (![self.productModel isEqual:productModel_]) {
        self.productModel = productModel_;
        /*
        for (UIView *view in self.subviews) {
            if ([(NSString*)view.simiObjectIdentifier isEqualToString:viewIdentifier]) {
                [view removeFromSuperview];
            }
        }
        */
        self.imageProduct = [UIImageView new];
        self.imageProduct.simiObjectIdentifier = viewIdentifier;
        [self.imageProduct sd_setImageWithURL:[NSURL URLWithString:[self.productModel valueForKey:@"product_image"]]placeholderImage:[UIImage imageNamed:@"logo"]];
        self.imageProduct.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageProduct];
        
        self.lblNameProduct = [UILabel new];
        self.lblNameProduct.simiObjectIdentifier = viewIdentifier;
        [self.lblNameProduct setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:zThemeSizeFontPrice]];
        [self.lblNameProduct setTextColor:[UIColor blackColor]];
        [self.lblNameProduct setText:[[self.productModel valueForKey:@"product_name"] uppercaseString]];
        [self.lblNameProduct setTextAlignment:NSTextAlignmentCenter];
        [self.lblNameProduct setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.lblNameProduct];
        
        self.imageFog = [UIImageView new];
        [self.imageFog setBackgroundColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#949898"]];
        [self.imageFog setAlpha:0.1];
        [self addSubview:self.imageFog];
        
        
        [self setPrice];
        [self setInterfaceCell];
    }
}

- (void)setPrice
{
    if ([self.productModel valueForKey:@"show_price_v2"]) {
        self.priceDict = [self.productModel valueForKey:@"show_price_v2"];
        if ([self.priceDict valueForKey:@"excl_tax"] && [self.priceDict valueForKey:@"incl_tax"]) {
            [self cusSetStringExclPrice:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:@"excl_tax"]]];
            [self cusSetStringInclPrice:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:@"incl_tax"]]];
        }else if ([self.priceDict valueForKey:@"excl_tax_special"] && [self.priceDict valueForKey:@"incl_tax_special"]) {
            [self cusSetStringExclPrice:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:@"excl_tax_special"]]];
            [self cusSetStringInclPrice:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:@"incl_tax_special"]]];
        }else if ([self.priceDict valueForKey:@"excl_tax_minimal"]) {
            [self cusSetStringExclPrice:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:@"excl_tax_minimal"]]];
            if([self.priceDict valueForKey:@"incl_tax_minimal"]){
                [self cusSetStringInclPrice: [NSString stringWithFormat:@"%@",[self.priceDict valueForKey:@"incl_tax_minimal"]]];
            }
        }else if (![self.priceDict valueForKey:@"excl_tax_minimal"] && [self.priceDict valueForKey:@"incl_tax_minimal"]) {
            [self cusSetStringExclPrice: [NSString stringWithFormat:@"%@",[self.priceDict valueForKey:@"incl_tax_minimal"]]];
        }else if ([self.priceDict valueForKey:@"excl_tax_from"]&& [self.priceDict valueForKey:@"excl_tax_to"]) {
            [self cusSetStringExclPrice:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:@"excl_tax_from"]]];
            [self cusSetStringInclPrice:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:@"excl_tax_to"]]];
        }else if ([self.priceDict valueForKey:@"incl_tax_from"] &&[self.priceDict valueForKey:@"incl_tax_to"]) {
            [self cusSetStringExclPrice:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:@"incl_tax_from"]]];
            [self cusSetStringInclPrice:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:@"incl_tax_to"]]];
        }else if([self.priceDict valueForKey:@"minimal_price"] && ![self.priceDict valueForKey:@"product_price"] && ![self.priceDict valueForKey:@"product_regular_price"]){
            [self cusSetStringPriceRegular:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:@"minimal_price"]]];
        }else{
            [self cusSetStringPriceRegular: [NSString stringWithFormat:@"%@",[self.priceDict valueForKey:@"product_regular_price"]]];
            if([self.priceDict valueForKey:@"product_price"])
            {
                [self cusSetStringPriceSpecial:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:@"product_price"]]];
            }
        }
    }
}

- (void)setInterfaceCell
{
    NSString *labelIdentifier = @"ZThemeCollectionCell_SubLabel";
    NSString *otherViewIdentifier = @"ZThemeCollectionCell_OtherSubView";
    NSString *strNA = @"NotAvaiable";
    if (self.isShowOnlyImage) {
        for (UIView *subview in self.subviews) {
            if(![subview isKindOfClass:[UIImageView class]])
            {
                [subview setHidden:YES];
            }
        }
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.imageProduct setFrame:CGRectMake(0, 0, 71.25, 89)];
                             [self.imageFog setFrame:self.imageProduct.frame];
                         }
                         completion:^(BOOL finished) {
                         }];
        return;
    }else
    {
        for (UIView *subview in self.subviews) {
            [subview setHidden:NO];
        }
    }
    /*
    for (UIView *subview in self.subviews) {
        if([subview isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel*)subview;
            if ([(NSString*)label.simiObjectIdentifier isEqualToString:labelIdentifier]) {
                [label removeFromSuperview];
                label.text = strNA;
            }
        }else if ([(NSString*)subview.simiObjectIdentifier isEqualToString:otherViewIdentifier])
        {
            [subview removeFromSuperview];
        }
    }
    */
    
     [self.imageProduct setFrame:CGRectMake(0, 0, 149.5, 187.5)];
     [self.imageFog setFrame:self.imageProduct.frame];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidDrawProductImageView" object:self.imageProduct userInfo:@{@"imageView": self.imageProduct, @"product": self.productModel}];

    [self.lblNameProduct setFrame:CGRectMake(0, 187.5, 149.5, 20)];
    
    if (self.lblExclPrice && self.lblInclPrice) {
        self.lblIncl.simiObjectIdentifier = labelIdentifier;
        self.lblExclPrice.simiObjectIdentifier = labelIdentifier;
        self.lblInclPrice.simiObjectIdentifier = labelIdentifier;
        
        [self.lblIncl setTextAlignment:NSTextAlignmentLeft];
        [self.lblExclPrice setTextAlignment:NSTextAlignmentLeft];
        [self.lblInclPrice setTextAlignment:NSTextAlignmentLeft];
        
        [self.lblIncl setFrame:CGRectMake(50, 207.5, 50, 20)];
        [self.lblExclPrice setFrame:CGRectMake(0, 207.5, 50, 20)];
        [self.lblInclPrice setFrame:CGRectMake(90, 207.5, 50, 20)];
        
        [self addSubview:self.lblExclPrice];
        [self addSubview:self.lblIncl];
        [self addSubview:self.lblInclPrice];
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.lblExclPrice setFrame:CGRectMake(90, 207.5, 50, 20)];
            [self.lblInclPrice setFrame:CGRectMake(0, 207.5, 50, 20)];
            [self.lblExclPrice setTextAlignment:NSTextAlignmentRight];
            [self.lblInclPrice setTextAlignment:NSTextAlignmentRight];
            [self.lblIncl setTextAlignment:NSTextAlignmentRight];
        }
        //  End RTL
        return;
    }else if(self.lblExclPrice)
    {
        self.lblExclPrice.simiObjectIdentifier = labelIdentifier;
        [self.lblExclPrice setFrame:CGRectMake(0, 207.5, 150, 20)];
        [self.lblExclPrice setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.lblExclPrice];

        return;
    }else if(self.lblIncl && self.lblExcl)
    {
        self.lblExcl.simiObjectIdentifier = labelIdentifier;
        self.lblIncl.simiObjectIdentifier = labelIdentifier;
        
        [self.lblExcl setFrame:CGRectMake(0, 207.5, 70, 20)];
        [self.lblIncl setFrame:CGRectMake(80, 207.5, 70, 20)];
        [self.lblExcl setTextAlignment:NSTextAlignmentCenter];
        [self.lblIncl setTextAlignment:NSTextAlignmentCenter];
        CGFloat priceWidth = [self.lblExcl.text sizeWithAttributes:@{NSFontAttributeName:[self.lblExcl font]}].width;
        self.viewLine = [[UIView alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.lblExcl.frame) - priceWidth)/2, self.lblExcl.center.y, priceWidth, 1)];
        self.viewLine.backgroundColor = [UIColor blackColor];
        self.viewLine.simiObjectIdentifier = otherViewIdentifier;
        
        [self addSubview:self.lblExcl];
        [self addSubview:self.lblIncl];
        [self addSubview:self.viewLine];
        return;
    }else if(self.lblExcl && ![self.lblExcl.text isEqualToString:strNA])
    {
        self.lblExcl.simiObjectIdentifier = labelIdentifier;
        [self.lblExcl setFrame:CGRectMake(0, 207.5, 150, 20)];
        [self.lblExcl setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.lblExcl];
        return;
    }
}

- (void)cusSetStringExclPrice:(NSString *)stringExclPrice_
{
    
    if (![stringExclPrice_ isEqualToString:@""]) {
        self.lblExcl = [[UILabel alloc]init];
        [self.lblExcl setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:zThemeSizeFontPrice]];
        [self.lblExcl setTextColor:[UIColor darkGrayColor]];
        if(self.productModel.productType == ProductTypeBundle){
            if([self.priceDict valueForKey:@"excl_tax_from"] && [self.priceDict valueForKey:@"incl_tax_to"]){
                [self.lblExcl setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"Excl.Tax")]];
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    [self.lblExcl setText:[NSString stringWithFormat:@":%@", SCLocalizedString(@"Excl.Tax")]];
                }
                //  End RTL
            }else{
                [self.lblExcl setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"From")]];
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    [self.lblExcl setText:[NSString stringWithFormat:@":%@", SCLocalizedString(@"From")]];
                }
                //  End RTL
            }
        }else{
            [self.lblExcl setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"Excl.Tax")]];
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [self.lblExcl setText:[NSString stringWithFormat:@":%@", SCLocalizedString(@"Excl.Tax")]];
            }
            //  End RTL
        }
        self.lblExclPrice = [[UILabel alloc]init];
        [self.lblExclPrice setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:zThemeSizeFontPrice]];
        self.lblExclPrice.textColor = ZTHEME_PRICE_COLOR;
        self.stringExclPrice = stringExclPrice_;
        self.lblExclPrice.text = [[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:[self.stringExclPrice floatValue]]];
    }
}

- (void)cusSetStringInclPrice:(NSString *)stringInclPrice_
{
    if (![stringInclPrice_ isEqualToString:@""]) {
        self.lblIncl = [[UILabel alloc]init];
        [self.lblIncl setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:zThemeSizeFontPrice]];
        [self.lblIncl setTextColor:[UIColor darkGrayColor]];
        if(self.productModel.productType == ProductTypeBundle){
            if([self.priceDict valueForKey:@"excl_tax_from"] && [self.priceDict valueForKey:@"incl_tax_to"]){
                [self.lblIncl setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"Incl.Tax")]];
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    [self.lblIncl setText:[NSString stringWithFormat:@":%@", SCLocalizedString(@"Incl.Tax")]];
                }
                //  End RTL
            }else{
                [self.lblIncl setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"To")]];
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    [self.lblIncl setText:[NSString stringWithFormat:@":%@", SCLocalizedString(@"To")]];
                }
                //  End RTL
            }
        }else{
            [self.lblIncl setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"Incl.Tax")]];
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [self.lblIncl setText:[NSString stringWithFormat:@":%@", SCLocalizedString(@"Incl.Tax")]];
            }
            //  End RTL
        }
        self.lblInclPrice = [[UILabel alloc]init];
        [self.lblInclPrice setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:zThemeSizeFontPrice]];
        self.lblInclPrice.textColor = ZTHEME_PRICE_COLOR;
        self.stringInclPrice = stringInclPrice_;
        self.lblInclPrice.text = [[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:[self.stringInclPrice floatValue]]];
    }
}

- (void)cusSetStringPriceRegular:(NSString *)stringPriceRegular_
{
    if (![stringPriceRegular_ isEqualToString:@""]) {
        self.lblExcl = [[UILabel alloc]init];
        [self.lblExcl setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:zThemeSizeFontPrice]];
        self.lblExcl.textColor = ZTHEME_PRICE_COLOR;
        self.stringPriceRegular = stringPriceRegular_;
        self.lblExcl.text = [[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:[self.stringPriceRegular floatValue]]];
    }
}

- (void)cusSetStringPriceSpecial:(NSString *)stringPriceSpecial_
{
    if (![stringPriceSpecial_ isEqualToString:@""]) {
        self.lblIncl = [[UILabel alloc]init];
        [self.lblIncl setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:zThemeSizeFontPrice]];
        self.lblIncl.textColor = ZTHEME_PRICE_COLOR;
        self.stringPriceSpecial = stringPriceSpecial_;
        self.lblIncl.text = [[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:[self.stringPriceSpecial floatValue]]];
    }
}
@end
