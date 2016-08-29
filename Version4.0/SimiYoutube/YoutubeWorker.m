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
    SimiProductModel *product;
    SCProductMoreViewController *productMoreViewController;
    NSMutableArray *youtubeArray;
    NSMutableArray *youtubeVideoArray;
    MoreActionView* moreActionView;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(initTab:) name:@"SCProductMoreViewController_InitTab" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterInitViewMore:) name:@"SCProductMoreViewController-AfterInitViewMore" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initViewMoreAction:) name:@"SCProductMoreViewController_InitViewMoreAction" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productMoreViewControllerViewWillDisappear:) name:@"SCProductMoreViewControllerViewWillDisappear" object:nil];
    }
    return self;
}

- (void)initTab:(NSNotification*)noti
{
    productMoreViewController = noti.object;
    if ([productMoreViewController.productModel valueForKey:@"youtube"]) {
        product = productMoreViewController.productModel;
        youtubeArray = (NSMutableArray*)[product valueForKey:@"youtube"];
        CGRect frame = productMoreViewController.pageScrollView.bounds;
        UITableView* tableVideo = [[UITableView alloc]initWithFrame:frame style:UITableViewStylePlain];
        tableVideo.delegate = self;
        tableVideo.dataSource = self;
        [productMoreViewController.pageScrollView addTab:SCLocalizedString(@"Video") View:tableVideo Info:nil];
    }
}

- (void)afterInitViewMore:(NSNotification*) noti
{
    
}

- (void)initViewMoreAction:(NSNotification*) noti
{
    if(youtubeArray.count > 0){
        float sizeButton = 50;
        moreActionView = noti.object;
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
        moreActionView.numberIcon += 1;
        [moreActionView.arrayIcon addObject:_buttonSimiVideo];
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
    NSDictionary *youtubeUnit = [youtubeArray objectAtIndex:indexPath.row];
    NSString *stringIdentifier = [youtubeUnit valueForKey:@"key"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:stringIdentifier];
    float cellWidth = SCREEN_WIDTH;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cellWidth = SCREEN_WIDTH *2/3;
    }
    if (youtubeVideoArray == nil) {
        youtubeVideoArray = [NSMutableArray new];
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringIdentifier];
        YTPlayerView *video = [[YTPlayerView alloc]initWithFrame:CGRectMake(0, 40, cellWidth, 260)];
        [video loadWithVideoId:[youtubeUnit valueForKey:@"key"]];
        [youtubeVideoArray addObject:video];
        [cell addSubview:video];
        
        UILabel *labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, cellWidth - 20, 20)];
        [labelTitle setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:18]];
        [labelTitle setText:[youtubeUnit valueForKey:@"title"]];
        [cell addSubview:labelTitle];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return youtubeArray.count;
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
        for (int i = 0; i < youtubeVideoArray.count; i++) {
            YTPlayerView *video = [youtubeVideoArray objectAtIndex:i];
            [video stopVideo];
        }
    }
}
@end
