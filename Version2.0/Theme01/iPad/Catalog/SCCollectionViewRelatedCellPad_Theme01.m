//
//  SCCollectionViewRelatedCellPad_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//
#import <SimicartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/SimiFormatter.h>

#import "SCCollectionViewRelatedCellPad_Theme01.h"

@interface SCCollectionViewRelatedCellPad_Theme01()
@end


@implementation SCCollectionViewRelatedCellPad_Theme01
@synthesize productRate, productModel, priceDict;
@synthesize imageProduct = _imageProduct, lblExcl = _lblExcl, lblExclPrice = _lblExclPrice, lblIncl = _lblIncl, lblInclPrice = _lblInclPrice, lblNameProduct = _lblNameProduct, lblStock = _lblStock;
@synthesize imageBackgroundNameFirst = _imageBackgroundNameFirst, imageBackgroundNameSecond = _imageBackgroundNameSecond, imageBackGroundPrice = _imageBackGroundPrice, imageBackgroundProduct = _imageBackgroundProduct, imageShowProductLabel = _imageShowProductLabel;
@synthesize stringExclPrice = _stringExclPrice, stringInclPrice = _stringInclPrice, stringNameProduct = _stringNameProduct, stringPriceRegular= _stringPriceRegular, stringPriceSpecial = _stringPriceSpecial;
#pragma mark
#pragma mark setProduct
- (void)setInterfaceCell
{
    int lblTag = 1000;
    int viewTag = 1010;
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
    [self.imageProduct setFrame:self.bounds];
    [self.imageBackgroundProduct setFrame:self.bounds];
    CGRect frameTemp = self.bounds;
    frameTemp.origin.y += 50;
    frameTemp.size.height -= 50;
    [self.imageShowProductLabel setFrame:frameTemp];
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
    [self.imageBackGroundPrice setFrame:CGRectMake(0, 150, 200, 50)];
    [self.lblStock setFrame:CGRectMake(133, 163, 67, 20)];
    
    if (self.lblExclPrice && ![self.lblExclPrice.text isEqualToString:strNA]) {
        self.lblExcl.tag = lblTag;
        self.lblIncl.tag = lblTag;
        self.lblExclPrice.tag = lblTag;
        self.lblInclPrice.tag = lblTag;
        
        [self.lblExcl setFrame:CGRectMake(10, 160, 55, 15)];
        [self.lblIncl setFrame:CGRectMake(10, 177, 55, 15)];
        [self.lblExclPrice setFrame:CGRectMake(65, 160, 90, 15)];
        [self.lblInclPrice setFrame:CGRectMake(65, 177, 90, 15)];
        [self addSubview:self.lblExcl];
        [self addSubview:self.lblExclPrice];
        [self addSubview:self.lblIncl];
        [self addSubview:self.lblInclPrice];
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.lblExcl setFrame:CGRectMake(100, 160, 55, 15)];
            [self.lblIncl setFrame:CGRectMake(100, 177, 55, 15)];
            [self.lblExclPrice setFrame:CGRectMake(10, 160, 90, 15)];
            [self.lblInclPrice setFrame:CGRectMake(10, 177, 90, 15)];
        }
        //  End RTL
    }else if(self.lblIncl && ![self.lblIncl.text isEqualToString:strNA])
    {
        self.lblExcl.tag = lblTag;
        self.lblIncl.tag = lblTag;
        
        [self.lblExcl setFrame:CGRectMake(10, 160, 70, 15)];
        [self.lblIncl setFrame:CGRectMake(10, 177, 70, 15)];
        
        CGFloat priceWidth = [self.lblExcl.text sizeWithFont:self.lblExcl.font].width;
        UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, self.lblExcl.center.y, priceWidth, 1)];
        viewLine.backgroundColor = [UIColor blackColor];
        viewLine.tag = viewTag;

        [self addSubview:self.lblExcl];
        [self addSubview:self.lblIncl];
        [self addSubview:viewLine];
    }else if(self.lblExcl && ![self.lblExcl.text isEqualToString:strNA])
    {
        self.lblExcl.tag = lblTag;
        [self.lblExcl setFrame:CGRectMake(10, 160, 70, 15)];
        [self addSubview:self.lblExcl];
    }
    
}

- (void)cusSetProductRate:(float)pr
{
    productRate = pr;
}
@end
