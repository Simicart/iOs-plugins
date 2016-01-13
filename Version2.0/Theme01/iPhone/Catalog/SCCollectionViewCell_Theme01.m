//
//  SCCollectionViewCell_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//
#import <SimicartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/SimiFormatter.h>
#import "SCCollectionViewCell_Theme01.h"

@interface SCCollectionViewCell_Theme01()
@end


@implementation SCCollectionViewCell_Theme01

@synthesize productModel, productRate, isRelated, priceDict;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil{
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:nibNameOrNil owner:self options:nil];
    self = [nibObjects objectAtIndex:0];
    return self;
}

#pragma mark
#pragma mark setProduct
- (void)cusSetProductModel:(SimiProductModel *)productModel_{
    int viewTag = 2000;
    if (![self.productModel isEqual:productModel_]) {
        self.productModel = productModel_;
        for (UIView *view in self.subviews) {
            if (view.tag == viewTag) {
                [view removeFromSuperview];
            }
        }
        self.imageProduct = [UIImageView new];
        self.imageProduct.tag = viewTag;
        [self.imageProduct sd_setImageWithURL:[self.productModel valueForKey:scTheme01_03_product_image]];
        self.imageProduct.contentMode = UIViewContentModeScaleAspectFit;
        self.imageProduct.layer.borderWidth = 1.0;
        self.imageProduct.layer.borderColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:215.0/255.0 alpha:0.7].CGColor;
        [self addSubview:self.imageProduct];
        
        self.imageBackgroundProduct = [UIImageView new];
        self.imageBackgroundProduct.tag = viewTag;
        [self.imageBackgroundProduct setImage:[UIImage imageNamed:@"theme01_product_backgroundgradien_ipad"]];
        self.imageBackgroundProduct.alpha = 0.2;
        [self addSubview:self.imageBackgroundProduct];
        
        self.imageShowProductLabel = [UIImageView new];
        self.imageShowProductLabel.tag = viewTag;
        [self.imageShowProductLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.imageShowProductLabel];
        
        self.imageBackgroundNameFirst = [UIImageView new];
        self.imageBackgroundNameFirst.tag = viewTag;
        [self.imageBackgroundNameFirst setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:125.0/255.0 blue:0/255.0 alpha:1]];
        [self addSubview:self.imageBackgroundNameFirst];
        
        self.imageBackgroundNameSecond = [UIImageView new];
        self.imageBackgroundNameSecond.tag = viewTag;
        [self.imageBackgroundNameSecond setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        [self addSubview:self.imageBackgroundNameSecond];
        
        self.lblNameProduct = [UILabel new];
        self.lblNameProduct.tag = viewTag;
        [self.lblNameProduct setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:sizeFontPrice + 3]];
        [self.lblNameProduct setTextColor:[UIColor whiteColor]];
        [self.lblNameProduct setText:[[self.productModel valueForKey:scTheme01_03_product_name] uppercaseString]];
        [self.lblNameProduct setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.lblNameProduct];
        
        
        self.imageBackGroundPrice = [UIImageView new];
        self.imageBackGroundPrice.tag = viewTag;
        [self.imageBackGroundPrice setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5]];
        [self addSubview:self.imageBackGroundPrice];
        
        
        self.lblStock = [UILabel new];
        self.lblStock.tag = viewTag;
        self.stringStock = [self.productModel valueForKey:scTheme01_03_stock_status];
        if([self.stringStock boolValue]){
            [self.lblStock setText: SCLocalizedString(@"In Stock")];
        }else{
            [self.lblStock setText: SCLocalizedString(@"Out Stock")];
        }
        [self.lblStock setTextColor:[UIColor blackColor]];
        [self.lblStock setFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:sizeFontPrice + 2]];
        [self addSubview:self.lblStock];
        
        [self setPrice];
        [self setInterfaceCell];
        
        if ([self.productModel valueForKey:scTheme01_03_product_rate]) {
            [self cusSetProductRate:[[self.productModel valueForKey:scTheme01_03_product_rate]floatValue]];
        }
    }
}

- (void)setPrice
{
    if ([self.productModel valueForKey:scTheme01_03_show_price_v2]) {
       self.priceDict = [self.productModel valueForKey:scTheme01_03_show_price_v2];
        if ([self.priceDict valueForKey:scTheme01_03_sp2_excl_tax] && [self.priceDict valueForKey:scTheme01_03_sp2_incl_tax]) {
            [self cusSetStringExclPrice:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:scTheme01_03_sp2_excl_tax]]];
            [self cusSetStringInclPrice:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:scTheme01_03_sp2_incl_tax]]];
        }else if ([self.priceDict valueForKey:scTheme01_03_sp2_excl_tax_special] && [self.priceDict valueForKey:scTheme01_03_sp2_incl_tax_special]) {
            [self cusSetStringExclPrice:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:scTheme01_03_sp2_excl_tax_special]]];
            [self cusSetStringInclPrice:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:scTheme01_03_sp2_incl_tax_special]]];
        }else if ([self.priceDict valueForKey:scTheme01_03_sp2_excl_tax_minimal]) {
            [self cusSetStringExclPrice:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:scTheme01_03_sp2_excl_tax_minimal]]];
            if([self.priceDict valueForKey:scTheme01_03_sp2_incl_tax_minimal]){
                [self cusSetStringInclPrice: [NSString stringWithFormat:@"%@",[self.priceDict valueForKey:scTheme01_03_sp2_incl_tax_minimal]]];
            }
        }else if (![self.priceDict valueForKey:scTheme01_03_sp2_excl_tax_minimal] && [self.priceDict valueForKey:scTheme01_03_sp2_incl_tax_minimal]) {
            [self cusSetStringExclPrice: [NSString stringWithFormat:@"%@",[self.priceDict valueForKey:scTheme01_03_sp2_incl_tax_minimal]]];
        }else if ([self.priceDict valueForKey:scTheme01_03_sp2_excl_tax_from]&& [self.priceDict valueForKey:scTheme01_03_sp2_excl_tax_to]) {
            [self cusSetStringExclPrice:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:scTheme01_03_sp2_excl_tax_from]]];
            [self cusSetStringInclPrice:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:scTheme01_03_sp2_excl_tax_to]]];
        }else if ([self.priceDict valueForKey:scTheme01_03_sp2_incl_tax_from] &&[self.priceDict valueForKey:scTheme01_03_sp2_incl_tax_to]) {
            [self cusSetStringExclPrice:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:scTheme01_03_sp2_incl_tax_from]]];
            [self cusSetStringInclPrice:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:scTheme01_03_sp2_incl_tax_to]]];
        }else if([self.priceDict valueForKey:scTheme01_03_sp2_minimal_price] && ![self.priceDict valueForKey:scTheme01_03_sp2_product_price] && ![self.priceDict valueForKey:scTheme01_03_sp2_product_regular_price]){
            [self cusSetStringPriceRegular:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:scTheme01_03_sp2_minimal_price]]];
        }else{
            [self cusSetStringPriceRegular: [NSString stringWithFormat:@"%@",[self.priceDict valueForKey:scTheme01_03_sp2_product_regular_price]]];
            if([self.priceDict valueForKey:scTheme01_03_sp2_product_price])
            {
                [self cusSetStringPriceSpecial:[NSString stringWithFormat:@"%@",[self.priceDict valueForKey:scTheme01_03_sp2_product_price]]];
            }
        }
    }
}

- (void)setInterfaceCell
{
    int lblTag = 1000;
    int viewTag = 1010;
    /*
    NSString *strNA = @"NotAvaiable";
    for (UIView *subview in self.subviews) {
        if([subview isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel*)subview;
            if (label.tag == lblTag) {
                [label removeFromSuperview];
                label.text = strNA;
            }
        }else if (subview.tag == viewTag)
        {
            [subview removeFromSuperview];
        }
    }
    */
    
    [self.imageProduct setFrame:self.bounds];
    [self.imageBackgroundProduct setFrame:self.bounds];
    CGRect frame = self.bounds;
    frame.origin.y += 40;
    frame.size.height -=40;
    [self.imageShowProductLabel setFrame:frame];
    

    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidDrawProductImageView" object:self.imageShowProductLabel userInfo:@{@"imageView": self.imageShowProductLabel, @"product": self.productModel}];
    
    

    [self.imageBackgroundNameFirst setFrame:CGRectMake(12, 10, 4, 20)];
    [self.imageBackgroundNameSecond setFrame:CGRectMake(16, 10, 150, 20)];
    frame = self.imageBackgroundNameSecond.frame;
    frame.origin.x += 5;
    frame.size.width = 130;
    [self.lblNameProduct setFrame:frame];
    CGFloat priceWidth = [self.lblNameProduct.text sizeWithFont:self.lblNameProduct.font].width;
    frame = self.imageBackgroundNameSecond.frame;
    if (priceWidth > 119) {
        frame.size.width = 135;
    }else
    {
        frame.size.width = priceWidth + 10;
    }
    [self.imageBackgroundNameSecond setFrame:frame];
    [self.imageBackGroundPrice setFrame:CGRectMake(0, 116, 156, 50)];
    [self.lblStock setFrame:CGRectMake(100, 120, 56, 15)];
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [self.lblStock setFrame:CGRectMake(5, 120, 56, 15)];
    }
    if(isRelated){
        frame = self.imageBackgroundProduct.frame;
        UIButton *selectRelatedProduct = [[UIButton alloc]initWithFrame:frame];
        [selectRelatedProduct addTarget:self action:@selector(didSelectRelatedProduct:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:selectRelatedProduct];
    }
    
    if (self.lblExclPrice) {
        self.lblExcl.tag = lblTag;
        self.lblIncl.tag = lblTag;
        self.lblExclPrice.tag = lblTag;
        self.lblInclPrice.tag = lblTag;
        
        [self.lblExcl setFrame:CGRectMake(5, 120, 70, 15)];
        [self.lblIncl setFrame:CGRectMake(5, 135, 70, 15)];
        [self.lblExclPrice setFrame:CGRectMake(44, 120, 70, 15)];
        [self.lblInclPrice setFrame:CGRectMake(44, 135, 70, 15)];
        [self addSubview:self.lblExcl];
        [self addSubview:self.lblExclPrice];
        [self addSubview:self.lblIncl];
        [self addSubview:self.lblInclPrice];
        
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.lblExclPrice setFrame:CGRectMake(65, 120, 70, 15)];
            [self.lblInclPrice setFrame:CGRectMake(65, 135, 70, 15)];
            [self.lblExcl setFrame:CGRectMake(100, 120, 55, 15)];
            [self.lblIncl setFrame:CGRectMake(100, 135, 55, 15)];
            [self.lblExcl setTextAlignment:NSTextAlignmentRight];
            [self.lblIncl setTextAlignment:NSTextAlignmentRight];
        }
        //  End RTL
    }else if(self.lblIncl)
    {
        self.lblExcl.tag = lblTag;
        self.lblIncl.tag = lblTag;
        
        [self.lblExcl setFrame:CGRectMake(5, 120, 70, 15)];
        [self.lblIncl setFrame:CGRectMake(5, 135, 70, 15)];
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.lblExcl setFrame:CGRectMake(65, 120, 70, 15)];
            [self.lblIncl setFrame:CGRectMake(65, 135, 70, 15)];
            [self.lblExcl setTextAlignment:NSTextAlignmentRight];
            [self.lblIncl setTextAlignment:NSTextAlignmentRight];
        }
        //  End RTL
        CGFloat priceWidth = [self.lblExcl.text sizeWithFont:self.lblExcl.font].width;
        UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, self.lblExcl.center.y, priceWidth, 1)];
        viewLine.backgroundColor = [UIColor blackColor];
        viewLine.tag = viewTag;
        
        [self addSubview:self.lblExcl];
        [self addSubview:self.lblIncl];
        [self addSubview:viewLine];
    }else if(self.lblExcl)
    {
        self.lblExcl.tag = lblTag;
        [self.lblExcl setFrame:CGRectMake(5, 120, 70, 15)];
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.lblExcl setFrame:CGRectMake(65, 120, 70, 15)];
            [self.lblExcl setTextAlignment:NSTextAlignmentRight];
        }
        //  End RTL
        [self addSubview:self.lblExcl];
    }
}

- (void)cusSetStringExclPrice:(NSString *)stringExclPrice_
{
    self.lblExcl = [[UILabel alloc]init];
    [self.lblExcl setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:sizeFontPrice]];
    [self.lblExcl setTextColor:[UIColor darkGrayColor]];
    if(self.productModel.productType == ProductTypeBundle){
        if([self.priceDict valueForKey:@"excl_tax_from"] && [self.priceDict valueForKey:@"incl_tax_to"]){
            //  Liam Update RTL
            [self.lblExcl setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"Excl.Tax")]];
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [self.lblExcl setText:[NSString stringWithFormat:@":%@", SCLocalizedString(@"Excl.Tax")]];
            }
        }else{
            [self.lblExcl setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"From")]];
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [self.lblExcl setText:[NSString stringWithFormat:@":%@", SCLocalizedString(@"From")]];
            }
        }
    }else{
        [self.lblExcl setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"Excl.Tax")]];
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.lblExcl setText:[NSString stringWithFormat:@":%@", SCLocalizedString(@"Excl.Tax")]];
        }
    }
    //  End RTL
    self.lblExclPrice = [[UILabel alloc]init];
    [self.lblExclPrice setFont:[UIFont fontWithName:THEME01_FONT_NAME_BOLD size:sizeFontPrice]];
    [self.lblExclPrice setTextColor:[UIColor blackColor]];
    
    if (![stringExclPrice_ isEqualToString:@""]) {
        self.stringExclPrice = stringExclPrice_;
        self.lblExclPrice.text = [[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:[self.stringExclPrice floatValue]]];
    }
}

- (void)cusSetStringInclPrice:(NSString *)stringInclPrice_
{
    self.lblIncl = [[UILabel alloc]init];
    [self.lblIncl setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:sizeFontPrice]];
    [self.lblIncl setTextColor:[UIColor darkGrayColor]];
    if(self.productModel.productType == ProductTypeBundle){
        if([self.priceDict valueForKey:@"excl_tax_from"] && [self.priceDict valueForKey:@"incl_tax_to"]){
    //  Liam Update RTL
            [self.lblIncl setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"Incl.Tax")]];
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [self.lblIncl setText:[NSString stringWithFormat:@":%@", SCLocalizedString(@"Incl.Tax")]];
            }
        }else{
            [self.lblIncl setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"To")]];
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [self.lblIncl setText:[NSString stringWithFormat:@":%@", SCLocalizedString(@"To")]];
            }
        }
    }else{
        [self.lblIncl setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"Incl.Tax")]];
        if([[SimiGlobalVar sharedInstance]isReverseLanguage])
        {
            [self.lblIncl setText:[NSString stringWithFormat:@":%@", SCLocalizedString(@"Incl.Tax")]];
        }
    }
    //  End RTL
    self.lblInclPrice = [[UILabel alloc]init];
    [self.lblInclPrice setFont:[UIFont fontWithName:THEME01_FONT_NAME_BOLD size:sizeFontPrice]];
    [self.lblInclPrice setTextColor:[UIColor blackColor]];
    
    if (![stringInclPrice_ isEqualToString:@""]) {
        self.stringInclPrice = stringInclPrice_;
        self.lblInclPrice.text = [[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:[self.stringInclPrice floatValue]]];
    }
}

- (void)cusSetStringPriceRegular:(NSString *)stringPriceRegular_
{
    self.lblExcl = [[UILabel alloc]init];
    [self.lblExcl setFont:[UIFont fontWithName:THEME01_FONT_NAME_BOLD size:sizeFontPrice]];
    [self.lblExcl setTextColor:[UIColor blackColor]];
    if (![stringPriceRegular_ isEqualToString:@""]) {
        self.stringPriceRegular = stringPriceRegular_;
        self.lblExcl.text = [[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:[self.stringPriceRegular floatValue]]];
    }
}

- (void)cusSetStringPriceSpecial:(NSString *)stringPriceSpecial_
{
    self.lblIncl = [[UILabel alloc]init];
    [self.lblIncl setFont:[UIFont fontWithName:THEME01_FONT_NAME_BOLD size:sizeFontPrice]];
    [self.lblIncl setTextColor:[UIColor blackColor]];
    if (![stringPriceSpecial_ isEqualToString:@""]) {
        self.stringPriceSpecial = stringPriceSpecial_;
        self.lblIncl.text = [[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:[self.stringPriceSpecial floatValue]]];
    }
}

- (void)cusSetProductRate:(float)pr{
    if ((pr <= 5) &&(pr > 0)) {
        self.productRate = pr;
    }else{
        self.productRate = 0;
    }
    
    int originXstar = 100;
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        originXstar = 5;
    }
    int temp = (int)self.productRate;
    
    if (self.productRate == 0) {
        for (int i = 0; i < 5; i++) {
            UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*10, 137, 10, 10)];
            [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar2"]];
            [self addSubview:imageStar];
        }
    }else{
        for (int i = 0; i < temp; i++) {
            UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*10, 137, 10, 10)];
            [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar1"]];
            [self addSubview:imageStar];
        }
        if (self.productRate - temp > 0) {
            UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + temp*10, 137, 10, 10)];
            [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar0"]];
            [self addSubview:imageStar];
            
            for (int i = temp + 1; i < 5; i++) {
                UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*10, 137, 10, 10)];
                [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar2"]];
                [self addSubview:imageStar];;
            }
        }else{
            for (int i = temp; i < 5; i++) {
                UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*10, 137, 10, 10)];
                [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar2"]];
                [self addSubview:imageStar];
            }
        }
    }
}

- (void) didSelectRelatedProduct: (id) sender
{
    [self.delegate didSelectRelatedProduct:[self.productModel valueForKey:scTheme01_03_product_id]];
}

@end
