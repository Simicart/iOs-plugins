//
//  SCPPadProductViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 6/17/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPPadProductViewController.h"

@interface SCPPadProductViewController ()

@end

@implementation SCPPadProductViewController
- (void)viewDidAppearBefore:(BOOL)animated{
    tableWidth = SCALEVALUE(510);
    if (self.contentTableView == nil) {
        CGRect frame = self.view.bounds;
        frame.origin.x = SCALEVALUE(514);
        frame.size.width -= SCALEVALUE(514);
        self.contentTableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStyleGrouped];
        if (@available(iOS 11.0, *)) {
            self.contentTableView.estimatedRowHeight = 0;
            self.contentTableView.estimatedSectionHeaderHeight = 0;
            self.contentTableView.estimatedSectionFooterHeight = 0;
        }
        self.contentTableView.delegate = self;
        self.contentTableView.dataSource = self;
        [self.view addSubview:self.contentTableView];
        [self.contentTableView setContentInset:UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0)];
        self.contentTableView.backgroundColor = COLOR_WITH_HEX(@"#ededed");
        self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.contentTableView setHidden:YES];
        [self getProductDetail];
        [self startLoadingData];
    }
}
- (void)didGetProduct:(NSNotification*)noti{
    [super didGetProduct:noti];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS){
        [self createScrollImage];
    }
}

- (void)createScrollImage{
    float imageWidth = tableWidth - paddingEdge*3;
    float imageHeight = CGRectGetHeight(self.view.frame) - 2*paddingEdge;
    imagesScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(paddingEdge, paddingEdge, imageWidth, imageHeight)];
    imagesScrollView.pagingEnabled = YES;
    imagesScrollView.showsVerticalScrollIndicator = NO;
    imagesScrollView.delegate = self;
    [self.view addSubview:imagesScrollView];
    if ([[self.product.appPrices valueForKey:@"has_special_price"]intValue] == 1) {
        UIImageView *saleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(paddingEdge + imageWidth - 54, 10, 44, 44)];
        saleImageView.image = [UIImage imageNamed:@"scp_ic_sale"];
        [self.view addSubview:saleImageView];
    }
    if (self.product.images) {
        productImages = [[NSMutableArray alloc]initWithArray:self.product.images];
    }
    for (int i = 0; i < productImages.count; i++) {
        FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc]initWithFrame:CGRectMake(0, i*imageHeight, imageWidth, imageHeight)];
        NSDictionary *imageDict = [productImages objectAtIndex:i];
        if([imageDict valueForKey:@"url"])
            [imageView sd_setImageWithURL:[imageDict valueForKey:@"url"] placeholderImage:[UIImage imageNamed:@"logo"] options:SDWebImageRetryFailed];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imagesScrollView addSubview:imageView];
    }
    
    if (productImages.count == 0) {
        [imagesScrollView setContentSize:CGSizeMake(imageWidth, imageHeight)];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:imagesScrollView.bounds];
        [imageView setImage:[UIImage imageNamed:@"logo"]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imagesScrollView addSubview:imageView];
    }else
        [imagesScrollView setContentSize:CGSizeMake(imageWidth, imageHeight *productImages.count)];
    UITapGestureRecognizer *imageTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToProductImage:)];
    [imagesScrollView addGestureRecognizer:imageTapGesture];
    
    imagesPageControll = [[UIPageControl alloc]initWithFrame:CGRectMake(paddingEdge, paddingEdge, 15, imageHeight)];
    imagesPageControll.autoresizingMask = UIViewAutoresizingNone;
    if (productImages.count > 0)
        imagesPageControll.numberOfPages = productImages.count;
    else
        imagesPageControll.numberOfPages = 1;
    imagesPageControll.currentPageIndicatorTintColor = [UIColor blackColor];
    imagesPageControll.pageIndicatorTintColor = [UIColor lightGrayColor];
    imagesPageControll.transform = CGAffineTransformMakeRotation(M_PI / 2);
    [self.view addSubview:imagesPageControll];
}

@end
