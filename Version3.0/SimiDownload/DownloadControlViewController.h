//
//  DownloadControlViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 9/10/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController.h>
#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/LazyPageScrollView.h>
#import "DownloadItemsAvailableViewController.h"
#import "DownloadItemsDownloadedViewController.h"
#import "DownloadItemsDownloadingViewController.h"
#import "ReaderViewController.h"
@interface DownloadControlViewController : SimiViewController<LazyPageScrollViewDelegate, DownloadItemsAvailableViewControllerDelegate, DownloadItemsDownloadedViewControllerDelegate, ReaderViewControllerDelegate>
@property (nonatomic, strong) LazyPageScrollView *pageScrollView;
@property (nonatomic, strong) DownloadItemsAvailableViewController *downloadAvailable;
@property (nonatomic, strong) DownloadItemsDownloadedViewController *downloadedViewController;
@property (nonatomic, strong) DownloadItemsDownloadingViewController *downloadingViewController;
@end
