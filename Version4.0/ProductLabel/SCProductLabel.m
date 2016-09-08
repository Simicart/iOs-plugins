//
//  SCProductLabel.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/10/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCProductLabel.h"
#import <SimiCartBundle/SimiProductModel.h>
#import <SimiCartBundle/UIButton+WebCache.h>

#define PRODUCT_LABEL_IDENTIFIER @"SIMI_PRODUCT_LABEL"

@implementation SCProductLabel

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidDrawProductImageView" object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti{
    SimiProductModel *product = [noti.userInfo valueForKey:@"product"];
    UIImageView *imageView = [noti.userInfo valueForKey:@"imageView"];
    NSDictionary* productLabel = [product objectForKey:@"product_label"];
//    if (productLabels != nil) {
//        for (int i = 0; i < productLabels.count; i++) {
//            NSDictionary *productLabel = [productLabels objectAtIndex:i];
    if(productLabel){
        CGRect frame = imageView.frame;
        frame.size.width = frame.size.width/3 < frame.size.height/3 ? frame.size.width/3 : frame.size.height/3;
        frame.size.height = frame.size.width;
        
        UIButton *labelView = [UIButton buttonWithType:UIButtonTypeCustom];
        labelView.frame = frame;
        labelView.simiObjectIdentifier = PRODUCT_LABEL_IDENTIFIER;
        labelView.contentMode = UIViewContentModeScaleAspectFit;
        NSURL *url = [NSURL URLWithString:[productLabel valueForKey:@"image"]];
        [labelView sd_setBackgroundImageWithURL:url forState:UIControlStateNormal];
        [labelView setTitle:[productLabel valueForKey:@"text"] forState:UIControlStateNormal];
        [labelView.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 6]];
        [labelView.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [labelView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        labelView.userInteractionEnabled = NO;
        labelView.backgroundColor = [UIColor clearColor];
        labelView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        
        CGPoint center;
        
        switch ([[productLabel valueForKey:@"position"] integerValue]) {
            //Left
            case LabelPositionLeftTop:{
                center = CGPointMake(imageView.frame.size.width/6, imageView.frame.size.height/6);
            }
                break;
            case LabelPositionLeftMiddle:{
                center = CGPointMake(imageView.frame.size.width/6, imageView.frame.size.height/2);
            }
                break;
            case LabelPositionLeftBottom:{
                center = CGPointMake(imageView.frame.size.width/6, 5*imageView.frame.size.height/6);
            }
                break;
                
            //Center
            case LabelPositionCenterTop:{
                center = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/6);
            }
                break;
            case LabelPositionCenterMiddle:{
                center = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2);
            }
                break;
            case LabelPositionCenterBottom:{
                center = CGPointMake(imageView.frame.size.width/2, 5*imageView.frame.size.height/6);
            }
                break;
                
            //Right
            case LabelPositionRightTop:{
                center = CGPointMake(5*imageView.frame.size.width/6, imageView.frame.size.height/6);
            }
                break;
            case LabelPositionRightMiddle:{
                center = CGPointMake(5*imageView.frame.size.width/6, imageView.frame.size.height/2);
            }
                break;
            case LabelPositionRightBottom:{
                center = CGPointMake(5*imageView.frame.size.width/6, 5*imageView.frame.size.height/6);
            }
                break;
            
            default:
                break;
        }
        
        labelView.center = center;
        
        [imageView addSubview:labelView];
//        }
    }else{
        for (UIView *view in imageView.subviews) {
            if ([view.simiObjectIdentifier isEqual:PRODUCT_LABEL_IDENTIFIER]) {
                [view removeFromSuperview];
            }
        }
    }
    
//    [self removeObserverForNotification:noti];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DidDrawProductImageView" object:nil];
}

@end