//
//  SCCollectionViewCellPad_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//
#import <SimicartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/SimiFormatter.h>
#import "SCCollectionViewCellPad_Theme01.h"

@interface SCCollectionViewCellPad_Theme01()

@end


@implementation SCCollectionViewCellPad_Theme01

@synthesize productRate, productModel, priceDict;
@synthesize imageProduct = _imageProduct, lblExcl = _lblExcl, lblExclPrice = _lblExclPrice, lblIncl = _lblIncl, lblInclPrice = _lblInclPrice, lblNameProduct = _lblNameProduct, lblStock = _lblStock;
@synthesize imageBackgroundNameFirst = _imageBackgroundNameFirst, imageBackgroundNameSecond = _imageBackgroundNameSecond, imageBackGroundPrice = _imageBackGroundPrice, imageBackgroundProduct = _imageBackgroundProduct, imageShowProductLabel = _imageShowProductLabel;
@synthesize stringExclPrice = _stringExclPrice, stringInclPrice = _stringInclPrice, stringNameProduct = _stringNameProduct, stringPriceRegular= _stringPriceRegular, stringPriceSpecial = _stringPriceSpecial;
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
    CGRect frameTemp = self.bounds;
    frameTemp.origin.y += 50;
    frameTemp.size.height -= 50;
    [self.imageShowProductLabel setFrame:frameTemp];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidDrawProductImageView" object:self.imageShowProductLabel userInfo:@{@"imageView": self.imageShowProductLabel, @"product": self.productModel}];
    
    [self.imageBackgroundNameFirst setFrame:CGRectMake(12, 10, 4, 20)];
    [self.imageBackgroundNameSecond setFrame:CGRectMake(16, 10, 150, 20)];
    CGRect frame = _imageBackgroundNameSecond.frame;
    frame.origin.x += 5;
    frame.size.width = 160;
    [self.lblNameProduct setFrame:frame];
    CGFloat priceWidth = [self.lblNameProduct.text sizeWithFont:self.lblNameProduct.font].width;
    frame = self.imageBackgroundNameSecond.frame;
    if (priceWidth > 160) {
        frame.size.width = 170;
    }else
    {
        frame.size.width = priceWidth + 10;
    }
    [self.imageBackgroundNameSecond setFrame:frame];
    [self.imageBackGroundPrice setFrame:CGRectMake(0, 162, 212, 50)];
    [self.lblStock setFrame:CGRectMake(142, 167, 67, 20)];
    //  Liam Update RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [self.lblStock setFrame:CGRectMake(5, 167, 67, 20)];
    }
    //  End RTL
    if (self.lblExclPrice) {
        self.lblExcl.tag = lblTag;
        self.lblIncl.tag = lblTag;
        self.lblExclPrice.tag = lblTag;
        self.lblInclPrice.tag = lblTag;
        
        [self.lblExcl setFrame:CGRectMake(10, 172, 55, 15)];
        [self.lblIncl setFrame:CGRectMake(10, 189, 55, 15)];
        [self.lblExclPrice setFrame:CGRectMake(65, 172, 150, 15)];
        [self.lblInclPrice setFrame:CGRectMake(65, 189, 150, 15)];
        [self addSubview:self.lblExcl];
        [self addSubview:self.lblExclPrice];
        [self addSubview:self.lblIncl];
        [self addSubview:self.lblInclPrice];
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.lblExcl setFrame:CGRectMake(155, 172, 55, 15)];
            [self.lblIncl setFrame:CGRectMake(155, 189, 55, 15)];
            [self.lblExclPrice setFrame:CGRectMake(75, 172, 100, 15)];
            [self.lblInclPrice setFrame:CGRectMake(75, 189, 100, 15)];
            [self.lblExcl setTextAlignment:NSTextAlignmentRight];
            [self.lblIncl setTextAlignment:NSTextAlignmentRight];
        }
        //  End RTL
    }else if(self.lblIncl)
    {
        self.lblExcl.tag = lblTag;
        self.lblIncl.tag = lblTag;
        
        [self.lblExcl setFrame:CGRectMake(10, 172, 150, 15)];
        [self.lblIncl setFrame:CGRectMake(10, 189, 150, 15)];
        CGFloat priceWidth = [self.lblExcl.text sizeWithFont:self.lblExcl.font].width;
        UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, self.lblExcl.center.y, priceWidth, 1)];
        viewLine.backgroundColor = [UIColor blackColor];
        viewLine.tag = viewTag;

        [self addSubview:self.lblExcl];
        [self addSubview:self.lblIncl];
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.lblExcl setFrame:CGRectMake(75, 172, 130, 15)];
            [self.lblIncl setFrame:CGRectMake(75, 189, 130, 15)];
            [self.lblExcl setTextAlignment:NSTextAlignmentRight];
            [self.lblIncl setTextAlignment:NSTextAlignmentRight];
            [viewLine setFrame:CGRectMake(205 - priceWidth, self.lblExcl.center.y, priceWidth, 1)];
        }
        //  End RTL
        [self addSubview:viewLine];
    }else if(self.lblExcl)
    {
        self.lblExcl.tag = lblTag;
        [self.lblExcl setFrame:CGRectMake(10, 172, 150, 15)];
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.lblExcl setFrame:CGRectMake(75, 172, 120, 15)];
        }
        //  End RTL
        [self addSubview:self.lblExcl];
    }
    
}

- (void)cusSetProductRate:(float)pr{
    if ((pr <= 5) &&(pr > 0)) {
        self.productRate = pr;
    }else{
        self.productRate = 0;
    }
    
    int originXstar = 142;
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        originXstar = 5;
    }
    int temp = (int)self.productRate;
    
    if (self.productRate == 0) {
        for (int i = 0; i < 5; i++) {
            UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*12, 192, 12, 12)];
            [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar2"]];
            [self addSubview:imageStar];
        }
    }else{
        for (int i = 0; i < temp; i++) {
            UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*12, 192, 12, 12)];
            [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar1"]];
            [self addSubview:imageStar];
        }
        if (self.productRate - temp > 0) {
            UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + temp*12, 192, 12, 12)];
            [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar0"]];
            [self addSubview:imageStar];
            
            for (int i = temp + 1; i < 5; i++) {
                UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*12, 192, 12, 12)];
                [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar2"]];
                [self addSubview:imageStar];;
            }
        }else{
            for (int i = temp; i < 5; i++) {
                UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*12, 192, 12, 12)];
                [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar2"]];
                [self addSubview:imageStar];
            }
        }
    }
}
@end
