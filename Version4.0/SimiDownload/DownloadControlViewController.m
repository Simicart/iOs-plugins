//
//  DownloadControlViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 9/10/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "DownloadControlViewController.h"
#import "ReaderDocument.h"
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import <MediaPlayer/MPMoviePlayerController.h>
@interface DownloadControlViewController ()

@end

@implementation DownloadControlViewController
#pragma mark Init View
- (void)viewDidLoadBefore
{
    [super viewDidLoadBefore];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    [self initPageScrollView];
    [self initDownloadAvailable];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didPopulateOtherDownloadTasks:) name:@"DidPopulateOtherDownloadTasks" object:nil];
    [self initDownloading];
    [self initDownloaded];
    [self.view addSubview:_pageScrollView];
    [_pageScrollView generate];
    
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    
}

- (void)didPopulateOtherDownloadTasks:(NSNotification*)noti
{
    _downloadAvailable.downloadingArray = _downloadingViewController.downloadingArray;
    [_downloadAvailable setCells:nil];
}

- (void)initPageScrollView
{
    _pageScrollView = [[LazyPageScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT -  64)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_pageScrollView setFrame:CGRectMake(0, 0, SCREEN_WIDTH *2/3, SCREEN_HEIGHT *2/3)];
    }
    [_pageScrollView setDelegate:self];
    [_pageScrollView initTab:YES Gap:50 TabHeight:40 VerticalDistance:5 BkColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#eeeeee"]];
    [_pageScrollView enableTabBottomLine:YES LineHeight:3 LineColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#c3c3c3"] LineBottomGap:0 ExtraWidth:10];
    [_pageScrollView setTitleStyle:[UIFont fontWithName:THEME_FONT_NAME size:12] Color:[[SimiGlobalVar sharedInstance ] colorWithHexString:@"141414"] SelColor:THEME_COLOR];
    [_pageScrollView enableBreakLine:NO Width:1 TopMargin:0 BottomMargin:0 Color:[UIColor blackColor]];
    _pageScrollView.leftTopView = [[UIView alloc]initWithFrame:CGRectZero];
    _pageScrollView.rightTopView = [[UIView alloc]initWithFrame:CGRectZero];
    [_pageScrollView setBackgroundColor:[UIColor whiteColor]];
}

- (void)initDownloadAvailable
{
    _downloadAvailable = [DownloadItemsAvailableViewController new];
    _downloadAvailable.delegate = self;
    [self addChildViewController:_downloadAvailable];
    [_pageScrollView addTab:@"Download Available" View:_downloadAvailable.view Info:nil];
}

- (void)initDownloaded
{
    _downloadedViewController = [DownloadItemsDownloadedViewController new];
    _downloadedViewController.delegate = self;
    [self addChildViewController:_downloadedViewController];
    [_pageScrollView addTab:@"Downloaded" View:_downloadedViewController.view Info:nil];
}

- (void)initDownloading
{
    _downloadingViewController = [DownloadItemsDownloadingViewController new];
    [self addChildViewController:_downloadingViewController];
    [_pageScrollView addTab:@"Downloading" View:_downloadingViewController.view Info:nil];
}

#pragma mark Download Available Delegate
- (void)addDownloadTask:(NSString *)fileName fileURL:(NSString *)fileURL
{
    [_downloadingViewController addDownloadTask:fileName fileURL:fileURL];
}

#pragma mark Lazy Delegate
-(void)LazyPageScrollViewPageChange:(LazyPageScrollView *)pageScrollView Index:(NSInteger)index PreIndex:(NSInteger)preIndex
{
    switch (index) {
        case 0:
            _downloadAvailable.downloadingArray = _downloadingViewController.downloadingArray;
            [_downloadAvailable setCells:nil];
            break;
        case 2:
        {
            [_downloadedViewController reloadData];
            _downloadAvailable.downloadedFilesArray = _downloadedViewController.downloadedFilesArray;
        }
            break;
        default:
            break;
    }
}

#pragma mark Open file
- (void)openFileWithName:(NSString *)fileName
{
    NSString *fileExtension = [fileName pathExtension];
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"] stringByAppendingPathComponent:fileName];
    if ([fileExtension isEqualToString:@"pdf"]) {
        NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
        
        ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];
        
        if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
        {
            ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
            
            readerViewController.delegate = self; // Set the ReaderViewController delegate to self
            readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:readerViewController animated:YES completion:NULL];
        }
    }else
    {
        MPMoviePlayerViewController *myPlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:filePath]];
        [self presentMoviePlayerViewControllerAnimated:myPlayer];
        [myPlayer.moviePlayer play];
    }
}

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
