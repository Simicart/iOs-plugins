//
//  SCOptionGroupViewCell.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/26/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCOptionGroupViewCellPad_Theme01.h"
#import "SimiGlobalVar+Theme01.h"
#import <SimiCartBundle/SimiFormatter.h>

@interface SCOptionGroupViewCellPad_Theme01()

@property (nonatomic, strong) UILabel *lblOptionName;
@property (nonatomic, strong) UILabel *lblRegular;
@property (nonatomic, strong) UILabel *lblRegularPrice;
@property (nonatomic, strong) UILabel *lblSpecial;
@property (nonatomic, strong) UILabel *lblSpecialPrice;
@property (nonatomic, strong) UILabel *lblExclSpecial;
@property (nonatomic, strong) UILabel *lblExclSpecialPrice;
@property (nonatomic, strong) UILabel *lblInclSpecial;
@property (nonatomic, strong) UILabel *lblInclSpecialPrice;

@property (nonatomic, strong) NSString *stringRegularPrice;
@property (nonatomic, strong) NSString *stringSpecialPrice;
@property (nonatomic, strong) NSString *stringExclSpecialPrice;
@property (nonatomic, strong) NSString *stringInclSpecialPrice;
@property (nonatomic, strong) NSDictionary *optionDict;
@property (nonatomic, strong) NSDictionary *dictPrice;
@end

@implementation SCOptionGroupViewCellPad_Theme01

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPriceOption:(NSDictionary*)optionDictionary
{
    _optionDict = [optionDictionary mutableCopy];
    _dictPrice = (NSDictionary*)[_optionDict valueForKey:@"show_price_v2"];
    if ([_dictPrice valueForKey:@"product_regular_price"] != nil && [_dictPrice valueForKey:@"special_price_label"] == nil) {
        //                Only regular price
        self.stringRegularPrice = [NSString stringWithFormat:@"%@",[_dictPrice valueForKey:@"product_regular_price"]];
        
    }else if([_dictPrice valueForKey:@"product_price"])
    {
        //                Regular&Special price no tax
        self.stringRegularPrice = [NSString stringWithFormat:@"%@",[_dictPrice valueForKey:@"product_regular_price"]];
        self.stringSpecialPrice = [NSString stringWithFormat:@"%@",[_dictPrice valueForKey:@"product_price"]];
        
    }else if([_dictPrice valueForKey:@"excl_tax_special"])
    {
        //                Regular&Special with tax
        self.stringExclSpecialPrice = [NSString stringWithFormat:@"%@",[_dictPrice valueForKey:@"excl_tax_special"]];
        self.stringRegularPrice = [NSString stringWithFormat:@"%@",[_dictPrice valueForKey:@"product_regular_price"]];
        self.stringInclSpecialPrice = [NSString stringWithFormat:@"%@",[_dictPrice valueForKey:@"incl_tax_special"]];
        
    }else if([_dictPrice valueForKey:@"excl_tax"])
    {
        //                Regular with Tax
        self.stringExclSpecialPrice = [NSString stringWithFormat:@"%@",[_dictPrice valueForKey:@"excl_tax"]];
        self.stringInclSpecialPrice = [NSString stringWithFormat:@"%@",[_dictPrice valueForKey:@"incl_tax"]];
    }
    
    int widthTitle = 80;
    int widthValue = 100;
    int originY = 5;
    int originX1 = 10;
    int originX2 = widthTitle;
    int heightLabel = 20;
    int heightLabelWidthDistance = 25;
    
    int boldTag = 1010;
    int thinTag = 1020;
    int redTag = 1030;
#pragma mark Product No Bundle
    _lblSpecial.tag = boldTag;
    _lblRegularPrice.tag = redTag;
    _lblSpecialPrice.tag = redTag;
    _lblExclSpecial.tag = thinTag;
    _lblInclSpecial.tag = thinTag;
    _lblExclSpecialPrice.tag = redTag;
    _lblInclSpecialPrice.tag = redTag;
    if ([_dictPrice valueForKey:@"product_regular_price"] != nil && [_dictPrice valueForKey:@"special_price_label"] == nil) {
        //              Only regular price
        if (_lblRegularPrice) {
            [_lblRegularPrice setFrame:CGRectMake(originX1, originY, widthValue, heightLabel)];
            originY += heightLabelWidthDistance;
            [self addSubview:_lblRegularPrice];
        }
    }else if([_dictPrice valueForKey:@"product_price"])
    {
        //              Regular&Special price no tax
        if(_lblRegularPrice)
        {
            [_lblRegularPrice setFrame:CGRectMake(originX1, originY, widthValue, heightLabel)];
            originY += heightLabelWidthDistance;
            [self addSubview:_lblRegularPrice];
            
            UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(originX1, _lblRegularPrice.center.y, widthTitle/2, 1)];
            viewLine.backgroundColor = [UIColor redColor];
            [self addSubview:viewLine];
        }
        if (_lblSpecialPrice) {
            [_lblSpecial setFrame:CGRectMake(originX1, originY, widthTitle, heightLabel)];
            [_lblSpecialPrice setFrame:CGRectMake(originX2, originY, widthValue, heightLabel)];
            originY += heightLabelWidthDistance;
            [self addSubview:_lblSpecial];
            [self addSubview:_lblSpecialPrice];
        }
        
    }else if([_dictPrice valueForKey:@"excl_tax_special"])
    {
        //              Regular&Special with tax
        if(_lblRegularPrice)
        {
            [_lblRegularPrice setFrame:CGRectMake(originX1, originY, widthValue, heightLabel)];
            originY += heightLabelWidthDistance;
            [self addSubview:_lblRegularPrice];
            
            UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(originX1, _lblRegularPrice.center.y, widthTitle/2, 1)];
            viewLine.backgroundColor = [UIColor redColor];
            [self addSubview:viewLine];
        }
        if (_lblSpecial) {
            [_lblSpecial setFrame:CGRectMake(originX1, originY, widthTitle, heightLabel)];
            [self addSubview:_lblSpecial];
            originY +=heightLabelWidthDistance;
        }
        if (_lblExclSpecialPrice) {
            [_lblExclSpecial setFrame:CGRectMake(originX1, originY, widthTitle, heightLabel)];
            [_lblExclSpecialPrice setFrame:CGRectMake(originX2, originY, widthValue, heightLabel)];
            [self addSubview:_lblExclSpecial];
            [self addSubview:_lblExclSpecialPrice];
            originY +=heightLabelWidthDistance;
        }
        
        if (_lblInclSpecialPrice) {
            [_lblInclSpecial setFrame:CGRectMake(originX1, originY, widthTitle, heightLabel)];
            [_lblInclSpecialPrice setFrame:CGRectMake(originX2, originY, widthValue, heightLabel)];
            [self addSubview:_lblInclSpecial];
            [self addSubview:_lblInclSpecialPrice];
            originY +=heightLabelWidthDistance;
        }
    }else if([_dictPrice valueForKey:@"excl_tax"])
    {
        //                Regular with Tax
        if (_lblExclSpecialPrice) {
            [_lblExclSpecial setFrame:CGRectMake(originX1, originY, widthTitle, heightLabel)];
            [_lblExclSpecialPrice setFrame:CGRectMake(originX2, originY, widthValue, heightLabel)];
            [self addSubview:_lblExclSpecial];
            [self addSubview:_lblExclSpecialPrice];
            originY +=heightLabelWidthDistance;
        }
        if (_lblInclSpecialPrice) {
            [_lblInclSpecial setFrame:CGRectMake(originX1, originY, widthTitle, heightLabel)];
            [_lblInclSpecialPrice setFrame:CGRectMake(originX2, originY, widthValue, heightLabel)];
            [self addSubview:_lblInclSpecial];
            [self addSubview:_lblInclSpecialPrice];
            originY +=heightLabelWidthDistance;
        }
    }
    
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *lblView = (UILabel*)subview;
            if (lblView.tag == boldTag) {
                [lblView setFont:[UIFont fontWithName:THEME01_FONT_NAME_BOLD size:16]];
                lblView.textColor = [UIColor redColor];
            }else if(lblView.tag == thinTag)
            {
                [lblView setFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:16]];
                lblView.textColor = [UIColor darkGrayColor];
            }else if (lblView.tag == redTag)
            {
                [lblView setFont:[UIFont fontWithName:THEME_FONT_NAME size:16]];
                lblView.textColor = [UIColor redColor];
            }
        }
    }
}

- (void)setStringRegularPrice:(NSString *)stringRegularPrice_
{
    if (stringRegularPrice_ != nil) {
        _stringRegularPrice = stringRegularPrice_;
        _lblRegularPrice = [[UILabel alloc]init];
        _lblRegularPrice.text = [[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:[_stringRegularPrice floatValue]]];
    }
}

- (void)setStringSpecialPrice:(NSString *)stringSpecialPrice_
{
    if (stringSpecialPrice_ != nil) {
        _stringSpecialPrice = stringSpecialPrice_;
        _lblSpecialPrice = [[UILabel alloc]init];
        _lblSpecialPrice.text = [[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:[_stringSpecialPrice floatValue]]];
        
        _lblSpecial = [[UILabel alloc]init];
        _lblSpecial.text = SCLocalizedString(@"Special: ");
    }
}

- (void)setStringExclSpecialPrice:(NSString *)stringExclSpecialPrice_
{
    if (stringExclSpecialPrice_ != nil) {
        _stringExclSpecialPrice = stringExclSpecialPrice_;
        _lblExclSpecialPrice = [[UILabel alloc]init];
        _lblExclSpecialPrice.text = [[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:[_stringExclSpecialPrice floatValue]]];
        
        _lblSpecial = [[UILabel alloc]init];
        _lblSpecial.text = SCLocalizedString(@"Special:");
        
        _lblExclSpecial = [[UILabel alloc]init];
        _lblExclSpecial.text = @"Excl.Tax:";
    }
}

- (void)setStringInclSpecialPrice:(NSString *)stringInclSpecialPrice_
{
    if (stringInclSpecialPrice_ != nil) {
        _stringInclSpecialPrice = stringInclSpecialPrice_;
        _lblInclSpecialPrice = [[UILabel alloc]init];
        _lblInclSpecialPrice.text = [[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:[_stringInclSpecialPrice floatValue]]];
        
        _lblInclSpecial = [[UILabel alloc]init];
        _lblInclSpecial.text = @"Incl.Tax:";
    }
}

@end
