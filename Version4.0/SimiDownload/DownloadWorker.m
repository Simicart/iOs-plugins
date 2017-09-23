//
//  DownloadWorker.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 9/9/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "DownloadWorker.h"
#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SCNavigationBarPad.h>
#import "DownloadControlViewController.h"
@implementation DownloadWorker
{
    SimiTable *cells;
    
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initCellsAfter:) name:SCLeftMenuInitCellsAfter object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectRow:) name:@"SCLeftMenu_DidSelectRow" object:nil];
    }
    return self;
}

- (void)initCellsAfter:(NSNotification*)noti
{
    if ([noti.name isEqualToString:SCLeftMenuInitCellsAfter]) {
        cells = (SimiTable *)noti.object;
        for (int i = 0; i < cells.count; i++) {
            SimiSection *section = [cells objectAtIndex:i];
            if ([section.identifier isEqualToString:LEFTMENU_SECTION_MAIN] && [[SimiGlobalVar sharedInstance]isLogin]) {
                int emailContactSortOrder = 0;
                for (int j = 0; j < section.count; j++) {
                    SimiRow *row = [section objectAtIndex:j];
                    if ([row.identifier isEqualToString:LEFTMENU_ROW_ORDERHISTORY]) {
                        emailContactSortOrder = (int)row.sortOrder + 10;
                    }
                }
                if (PHONEDEVICE) {
                    SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_DOWNLOAD height:45 sortOrder:emailContactSortOrder];
                    row.image = [UIImage imageNamed:@""];
                    row.title = SCLocalizedString(@"Manage DownLoad");
                    [section addObject:row];
                }else
                {
                    SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_DOWNLOAD height:60 sortOrder:emailContactSortOrder];
                    row.image = [UIImage imageNamed:@""];
                    row.title = SCLocalizedString(@"My Downloadable products");
                    [section addObject:row];
                }
                [section sortItems];
            }
        }
    }
}

- (void)didSelectRow:(NSNotification*)noti
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    SimiRow *row = [noti.userInfo valueForKey:@"simirow"];
    if ([noti.name isEqualToString:@"SCLeftMenu_DidSelectRow"]) {
        if ([row.identifier isEqualToString:LEFTMENU_ROW_DOWNLOAD]) {
            if (PHONEDEVICE) {
                NSObject *navi = noti.object;
                if (_downloadControllViewController == nil) {
                    _downloadControllViewController = [[DownloadControlViewController alloc]init];
                }
                [(UINavigationController*)currentVC pushViewController:_downloadControllViewController animated:YES];
                _downloadControllViewController.navigationItem.title = @"Manage Downloadable Products";
                navi.isDiscontinue = YES;
            }else
            {
                if (_downloadControllViewController == nil) {
                    _downloadControllViewController = [[DownloadControlViewController alloc]init];
                }
//                SCNavigationBarPad *navi = noti.object;
//                navi.popController = nil;
//                navi.popController = [[UIPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:_downloadControllViewController]];
//                _downloadControllViewController.isInPopover = YES;
//                _downloadControllViewController.popover = navi.popController;
//                [navi.popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
//                _downloadControllViewController.navigationItem.title = @"Manage Downloadable Products";
//                navi.isDiscontinue = YES;
            }
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end


