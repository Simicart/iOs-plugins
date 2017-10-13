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
#import <SimiCartBundle/SCProductSecondDesignViewController.h>
#import "YTPlayerView.h"
#import <SimiCartBundle/SimiTable.h>

static NSString *PRODUCT_ROW_YOUTUBE = @"PRODUCT_ROW_YOUTUBE";
@implementation YoutubeWorker
{
    SimiProductModel *product;
    SCProductMoreViewController *productMoreViewController;
    NSMutableArray *youtubeArray;
    NSMutableArray *youtubeVideoArray;
    MoreActionView* moreActionView;
    float itemWidth;
    float itemHeight;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(initTab:) name:@"SCProductMoreViewController_InitTab" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterInitViewMore:) name:@"SCProductMoreViewController-AfterInitViewMore" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initViewMoreAction:) name:@"SCProductMoreViewController_InitViewMoreAction" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productMoreViewControllerViewWillDisappear:) name:@"SCProductMoreViewControllerViewWillDisappear" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(initProductCellsAfter:) name:[NSString stringWithFormat:@"%@%@",SCProductSecondDesignViewController_RootEventName,SimiTableViewController_SubKey_InitCells_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedProductCellAfter:) name:[NSString stringWithFormat:@"%@%@",SCProductSecondDesignViewController_RootEventName,SimiTableViewController_SubKey_InitializedCell_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productMoreViewControllerViewWillDisappear:) name:@"SCProductSecondDesignViewControllerWillDisappear" object:nil];
    }
    return self;
}

- (void)initProductCellsAfter:(NSNotification*)noti
{
    SCProductSecondDesignViewController *productViewController = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
    NSLog(@"PRODUCT :%@",productViewController.product);
    if ([productViewController.product valueForKey:@"product_video"]) {
        product = productViewController.product;
        youtubeArray = (NSMutableArray*)[product valueForKey:@"product_video"];
        if(youtubeArray.count > 0){
            SimiTable *cells = noti.object;
            SimiSection *videoSection = [[SimiSection alloc]initWithIdentifier:product_video_section];
            videoSection.headerTitle = SCLocalizedString(@"Video");
            SimiRow *videoRow = [[SimiRow alloc]initWithIdentifier:product_video_row height:220];
            [videoSection addRow:videoRow];
            [cells addObject:videoSection];
        }
    }
}

- (void)initializedProductCellAfter:(NSNotification*)noti
{
    NSIndexPath *indexPath = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    SimiTable *cells = noti.object;
    SimiRow *row = [[cells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    itemWidth = 220;
    itemHeight = row.height - 10;
    SCProductSecondDesignViewController *productVC = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
    if ([row.identifier isEqualToString:product_video_row]) {
        UITableViewCell *cell = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.cell];
        NSInteger videoTag = 9999;
        if (![cell viewWithTag:videoTag]) {
            UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
            [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
            flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
            flowLayout.minimumLineSpacing = 20;
            float widthCollecttion = SCREEN_WIDTH;
            if (PADDEVICE) {
                widthCollecttion = SCREEN_WIDTH/2;
            }
            UICollectionView *videoCollectionView =[[UICollectionView alloc] initWithFrame:CGRectMake(0, 10, widthCollecttion, itemHeight) collectionViewLayout:flowLayout];
            [videoCollectionView setContentInset:UIEdgeInsetsMake(0, 20, 0, 0)];
            videoCollectionView.dataSource = self;
            videoCollectionView.delegate = self;
            [videoCollectionView setBackgroundColor:[UIColor clearColor]];
            videoCollectionView.showsHorizontalScrollIndicator = NO;
            videoCollectionView.tag = videoTag;
            [cell addSubview: videoCollectionView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        productVC.isDiscontinue = YES;
        row.tableCell = cell;
    }
}

#pragma mark  CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [youtubeArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *youtubeUnit = [youtubeArray objectAtIndex:indexPath.row];
    NSString *identifier = [youtubeUnit valueForKey:@"video_key"];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:identifier];
    UICollectionViewCell *videoViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    float videoTag = 1234;
    if (youtubeVideoArray == nil) {
        youtubeVideoArray = [NSMutableArray new];
    }
    if (![videoViewCell viewWithTag:videoTag]) {
        YTPlayerView *video = [[YTPlayerView alloc]initWithFrame:CGRectMake(0, 0, itemWidth, itemHeight - 30)];
        [video loadWithVideoId:[youtubeUnit valueForKey:@"video_key"]];
        [youtubeVideoArray addObject:video];
        [videoViewCell addSubview:video];
        
        UILabel *labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, itemHeight - 30, itemWidth, 30)];
        [labelTitle setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:14]];
        [labelTitle setText:[youtubeUnit valueForKey:@"video_title"]];
        labelTitle.tag = videoTag;
        [videoViewCell addSubview:labelTitle];
    }
    return videoViewCell;
}

- (void)initTab:(NSNotification*)noti
{
    productMoreViewController = noti.object;
    if ([productMoreViewController.productModel valueForKey:@"product_video"]) {
        product = productMoreViewController.productModel;
        youtubeArray = (NSMutableArray*)[product valueForKey:@"product_video"];
        if(youtubeArray.count > 0){
            CGRect frame = productMoreViewController.contentScrollView.bounds;
            UITableView* tableVideo = [[UITableView alloc]initWithFrame:frame style:UITableViewStylePlain];
            tableVideo.delegate = self;
            tableVideo.dataSource = self;
            [productMoreViewController.horizontalTitleList addObject:SCLocalizedString(@"Video")];
            [productMoreViewController.contentViewArray addObject:tableVideo];
        }
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
    int index = 0;
    for (int i = 0; i < productMoreViewController.horizontalTitleList.count; i++) {
        NSString *tempString = [productMoreViewController.horizontalTitleList objectAtIndex:i];
        if ([tempString isEqualToString:SCLocalizedString(@"Video")]) {
            index = i;
            break;
        }
    }
    [productMoreViewController.horizontalSelectionList setSelectedButtonIndex:index animated:YES];
    [productMoreViewController.contentScrollView setContentOffset:CGPointMake(index*CGRectGetWidth(productMoreViewController.contentScrollView.frame), 0) animated:YES];
    [productMoreViewController didTouchMoreAction];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *youtubeUnit = [youtubeArray objectAtIndex:indexPath.row];
    NSString *stringIdentifier = [youtubeUnit valueForKey:@"video_key"];
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
        [video loadWithVideoId:[youtubeUnit valueForKey:@"video_key"]];
        [youtubeVideoArray addObject:video];
        [cell addSubview:video];
        
        UILabel *labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, cellWidth - 20, 20)];
        [labelTitle setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:18]];
        [labelTitle setText:[youtubeUnit valueForKey:@"video_title"]];
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
    if (PADDEVICE) {
        for (int i = 0; i < youtubeVideoArray.count; i++) {
            YTPlayerView *video = [youtubeVideoArray objectAtIndex:i];
            [video stopVideo];
        }
    }
}
@end
