//
//  YoutubeWorker.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "YoutubeWorker.h"
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/SimiProductModel.h>
#import <SimiCartBundle/SCProductMoreViewController.h>
#import "YTPlayerView.h"
static NSString *PRODUCT_ROW_YOUTUBE = @"PRODUCT_ROW_YOUTUBE";
@implementation YoutubeWorker
{
    NSMutableArray *cells;
    SCProductMoreViewController *productMoreViewController;
    SCVideoModelCollection* videoCollection;
    NSMutableArray* videoArray;
    UITableView* tableVideo;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productMoreViewControllerInitTab:) name:@"SCProductMoreViewController_InitTab" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productMoreViewControllerViewWillDisappear:) name:@"SCProductMoreViewControllerViewWillDisappear" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productMoreViewControllerViewDidAppear:)name:@"SCProductMoreViewController-viewDidAppear" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetVideosForProduct:) name:DidGetVideosForProduct object:nil];
    }
    return self;
}

//Init video tab
-(void) productMoreViewControllerInitTab: (NSNotification*) noti{
    productMoreViewController = noti.object;
    tableVideo = [[UITableView alloc]initWithFrame:productMoreViewController.pageScrollView.bounds style:UITableViewStylePlain];
    tableVideo.delegate = self;
    tableVideo.dataSource = self;
    [productMoreViewController.pageScrollView addTab:SCLocalizedString(@"Video") View:tableVideo Info:nil];
}

-(void) productMoreViewControllerViewDidAppear: (NSNotification*) noti{
    productMoreViewController = noti.object;
    videoCollection = [SCVideoModelCollection new];
    [videoCollection getVideosForProductWithID:[productMoreViewController.productModel objectForKey:@"entity_id"]];
}

-(void) didGetVideosForProduct: (NSNotification*) noti{
    if(videoCollection.count > 0){
        float sizeButton = 50;
        if(!_buttonSimiVideo ){
            _buttonSimiVideo = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, sizeButton, sizeButton)];
            [_buttonSimiVideo setImage:[UIImage imageNamed:@"ic_simivideo"] forState:UIControlStateNormal];
            [_buttonSimiVideo setImageEdgeInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
            [_buttonSimiVideo.layer setCornerRadius:sizeButton/2.0f];
            [_buttonSimiVideo.layer setShadowOffset:CGSizeMake(1, 1)];
            [_buttonSimiVideo.layer setShadowRadius:2];
            _buttonSimiVideo.layer.shadowOpacity = 0.5;
            [_buttonSimiVideo setBackgroundColor:[UIColor whiteColor]];
            [_buttonSimiVideo addTarget:self action:@selector(didTouchSimiVideo:) forControlEvents:UIControlEventTouchUpInside];
        }

        productMoreViewController.viewMoreAction.numberIcon += 1;
        [productMoreViewController.viewMoreAction.arrayIcon addObject:_buttonSimiVideo];
        float paddingIcon = 20;
        productMoreViewController.viewMoreAction.heightMoreView = (paddingIcon + sizeButton) * (productMoreViewController.viewMoreAction.arrayIcon.count) + paddingIcon;
        for(UIView* view in productMoreViewController.viewMoreAction.subviews){
            [view removeFromSuperview];
        }
        [productMoreViewController setInterFaceViewMore];
        if(productMoreViewController.viewMoreAction.isShowViewMoreAction){
            CGRect frame = productMoreViewController.viewMoreAction.frame;
            frame.size.height = productMoreViewController.viewMoreAction.heightMoreView;
            frame.origin.y -= paddingIcon + sizeButton;
            [productMoreViewController.viewMoreAction setFrame:frame];
        }
        [tableVideo reloadData];
    }
}

- (void)didTouchSimiVideo:(id)sender
{
    [productMoreViewController.pageScrollView setSelectedIndex:[productMoreViewController.pageScrollView getTabCount] - 1];
    [productMoreViewController.pageScrollView scrollToIndex: productMoreViewController.pageScrollView.viewScrollTop];
    [productMoreViewController didTouchMoreAction];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *youtubeUnit = [videoCollection objectAtIndex:indexPath.row];
    NSString *stringIdentifier = [youtubeUnit valueForKey:@"video_key"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:stringIdentifier];
    float cellWidth = SCREEN_WIDTH;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cellWidth = SCREEN_WIDTH *2/3;
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringIdentifier];
        YTPlayerView *video = [[YTPlayerView alloc]initWithFrame:CGRectMake(0, 40, cellWidth, 260)];
        [video loadWithVideoId:[youtubeUnit valueForKey:@"video_key"]];
        [cell addSubview:video];
        
        if(!videoArray){
            videoArray = [[NSMutableArray alloc] initWithCapacity:0];
        }
        [videoArray addObject:video];
        UILabel *labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, cellWidth - 20, 20)];
        [labelTitle setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:18]];
        [labelTitle setText:[youtubeUnit valueForKey:@"video_title"]];
        [cell addSubview:labelTitle];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return videoCollection.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
}

// To make full width tableView Separating Lines
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)productMoreViewControllerViewWillDisappear:(NSNotification*)noti
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {        
        for (int i = 0; i < videoArray.count; i++) {
            YTPlayerView *video = [videoArray objectAtIndex:i];
            [video stopVideo];
        }
    }
}
@end
