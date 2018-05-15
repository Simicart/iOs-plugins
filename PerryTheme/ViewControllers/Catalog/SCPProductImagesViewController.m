//
//  SCCustomizeProductImagesViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 5/11/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPProductImagesViewController.h"
#import "SCPGlobalVars.h"

@interface SCPProductImagesViewController ()

@end

@implementation SCPProductImagesViewController

- (void)viewWillAppearBefore:(BOOL)animated
{
    imagesScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0 , 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    imagesScrollView.pagingEnabled = YES;
    imagesScrollView.showsHorizontalScrollIndicator = NO;
    imagesScrollView.delegate = self;
    [self.view addSubview:imagesScrollView];
    
    for (int i = 0; i < self.productImages.count; i++) {
        UIScrollView* imageZoomScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(i*SCREEN_WIDTH, 0,SCREEN_WIDTH, SCREEN_HEIGHT)];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:imageZoomScrollView.bounds];
        NSString *url = [self.productImages objectAtIndex:i];
        [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"logo"] options:SDWebImageRetryFailed];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imageView setBackgroundColor:[UIColor whiteColor]];
        [imagesScrollView addSubview:imageView];
        [imageZoomScrollView addSubview:imageView];
        [imagesScrollView addSubview:imageZoomScrollView];
        imageZoomScrollView.delegate = self;
        imageZoomScrollView.minimumZoomScale=1.0f;
        imageZoomScrollView.maximumZoomScale=3.0f;
        imageZoomScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    [imagesScrollView setContentSize:CGSizeMake(SCREEN_WIDTH *self.productImages.count, SCREEN_HEIGHT)];
    
    imagesPageControll = [[UIPageControl alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 15, SCREEN_WIDTH, 15)];
    imagesPageControll.autoresizingMask = UIViewAutoresizingNone;
    imagesPageControll.numberOfPages = self.productImages.count;
    imagesPageControll.currentPageIndicatorTintColor = COLOR_WITH_HEX(@"#838383");
    imagesPageControll.tintColor = COLOR_WITH_HEX(@"#838383");
    [self.view addSubview:imagesPageControll];
    
    [imagesScrollView setContentOffset:CGPointMake(self.currentIndexImage*SCREEN_WIDTH, 0)];
    [imagesPageControll setCurrentPage:self.currentIndexImage];
    
    UIButton *closeButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0, 60, 60)];
    [closeButton setImage:[[UIImage imageNamed:@"ic_delete"]imageWithColor:SCP_ICON_COLOR] forState:UIControlStateNormal];
    [closeButton setImageEdgeInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    [closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
}

@end
