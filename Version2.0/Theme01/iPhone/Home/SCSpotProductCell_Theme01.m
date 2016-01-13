//
//  SCSpotProductCell_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/18/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/UIImage+SimiCustom.h>

#import "SCSpotProductCell_Theme01.h"

@implementation SCSpotProductCell_Theme01


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setViewSpot];
    }
    return self;
}

- (void)setViewSpot
{
    _slideShow = [[SCTheme01SlideShow alloc]initWithFrame:self.bounds];
    [_slideShow setImagesContentMode:UIViewContentModeScaleAspectFill];
    [_slideShow setDelay:3];
    [_slideShow setTransitionDuration:0.5];
    [_slideShow setTransitionType:SCTheme01SlideShowTransitionSlideUpDown];
    [self addSubview:_slideShow];
    
    imgViewBackGround = [[UIImageView alloc]initWithFrame:self.bounds];
    [imgViewBackGround setImage:[UIImage imageNamed:@"theme1_images_transpa_view_now.png"]];
    imgViewBackGround.alpha = 0.5;
    [self addSubview:imgViewBackGround];
    
    lblSpotName = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, self.frame.size.width - 20, 60)];
    lblSpotName.numberOfLines = 2;
    [lblSpotName setTextColor:[UIColor whiteColor]];
    lblSpotName.textAlignment = NSTextAlignmentLeft;
    [lblSpotName setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:22]];
    [self addSubview:lblSpotName];
    
    lblViewMore = [[UILabel alloc]initWithFrame:CGRectMake(10, 70, self.frame.size.width,15)];
    [lblViewMore setTextColor:[UIColor whiteColor]];
    lblViewMore.textAlignment = NSTextAlignmentLeft;
    [lblViewMore setFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:12]];
    lblViewMore.text = SCLocalizedString(@"View more");
    [self addSubview:lblViewMore];
    
    imgViewMore = [[UIImageView alloc]initWithFrame:CGRectMake(65, 77, 7, 5)];
    [imgViewMore setImage:[[UIImage imageNamed:@"theme1_viewmore.png"] imageWithColor:[UIColor whiteColor]]];
    [self addSubview:imgViewMore];
    
    btnSpot = [[UIButton alloc]initWithFrame:self.bounds];
    [btnSpot addTarget:self action:@selector(didSelectSpotProduct) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnSpot];
}

- (void)cusSetSpotModel:(SimiModel *)spotModel
{
    self.spotModel = spotModel;
    [lblSpotName setText:[self.spotModel valueForKey:@"spot_name"]];
    NSMutableArray * array = [self.spotModel valueForKey:@"images"];
    if (array.count > 0) {
        for (int i = 0; i < array.count; i++) {
            [self.slideShow addImagePath:[array objectAtIndex:i]];
        }
    }
}

- (void)didSelectSpotProduct
{
    [self.delegate didSelectedSpotProductWithSpotProductModel:_spotModel];
}

@end
