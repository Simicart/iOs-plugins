//
//  SCSpotProductCellPad_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/18/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/UIImage+SimiCustom.h>

#import "SCSpotProductCellPad_Theme01.h"

@implementation SCSpotProductCellPad_Theme01

@synthesize spotModel = _spotModel, slideShow = _slideShow;
- (void)setViewSpot
{
    _slideShow = [[SCTheme01SlideShow alloc]initWithFrame:self.bounds];
    _slideShow.layer.borderWidth = 1.0;
    _slideShow.layer.borderColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:215.0/255.0 alpha:0.5].CGColor;
    [_slideShow setImagesContentMode:UIViewContentModeScaleAspectFill];
    [_slideShow setDelay:3];
    [_slideShow setTransitionDuration:0.5];
    [_slideShow setTransitionType:SCTheme01SlideShowTransitionSlideUpDown];
    [self addSubview:_slideShow];
    
    imgViewBackGround = [[UIImageView alloc]initWithFrame:CGRectMake(65, 67, 200, 34)];
    [imgViewBackGround setBackgroundColor:[UIColor blackColor]];
    imgViewBackGround.alpha = 0.5;
    [self addSubview:imgViewBackGround];
    
    lblSpotName = [[UILabel alloc]initWithFrame:CGRectMake(65, 67, 200, 34)];
    lblSpotName.numberOfLines = 1;
    [lblSpotName setTextColor:[UIColor whiteColor]];
    lblSpotName.textAlignment = NSTextAlignmentCenter;
    [lblSpotName setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:20]];
    [self addSubview:lblSpotName];
    
    btnSpot = [[UIButton alloc]initWithFrame:self.bounds];
    [btnSpot addTarget:self action:@selector(didSelectSpotProduct) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnSpot];
}

- (void)didSelectSpotProduct
{
    [self.delegate didSelectedSpotProductWithSpotProductModel:_spotModel];
}

@end
