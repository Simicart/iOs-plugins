//
//  DownloadWorker.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 9/9/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadControlViewController.h"
static NSString *LEFTMENU_ROW_DOWNLOAD = @"LEFTMENU_ROW_DOWNLOAD";
@interface DownloadWorker : NSObject
@property (nonatomic, strong) DownloadControlViewController *downloadControllViewController;
@end
