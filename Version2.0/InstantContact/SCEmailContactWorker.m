//
//  SCEmailContactWorker.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 10/15/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCEmailContactWorker.h"
#import "SCEmailContactViewController.h"
#import "SimiNavigationBarWorker.h"
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/SCMoreViewController.h>
#import <SimiCartBundle/SCAppDelegate.h>

@implementation SCEmailContactWorker
{
    SCMoreViewController *moreViewController;
    NSMutableArray * cells;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCMoreViewController-ViewDidLoad" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCMoreViewController_DidSelectCellAtIndexPath" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotification:)  name:@"SCMoreViewController_InitCellsAfter" object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotificationFromCorePad:) name:@"SCLeftMenu_DidSelectRow" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotificationFromCorePad:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotificationFromThemeOne:) name:@"SCListMenu_Theme01-InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotificationFromThemeOne:) name:@"SCListMenu_DidSelectRow" object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"SCMoreViewController_InitCellsAfter"]) {
        cells = noti.object;
        for (int i = 0; i < cells.count; i++) {
            SimiSection *section = [cells objectAtIndex:i];
            if ([section.identifier isEqualToString:MOREVIEW_SECTION_MORE]) {
                SimiRow *row = [[SimiRow alloc]initWithIdentifier:MOREVIEW_ROW_CONTACTUS height:40 sortOrder:50];
                row.image = [UIImage imageNamed:@""];
                row.title = SCLocalizedString(@"Contact Us");
                row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [section addObject:row];
                [section sortItems];
            }
        }
    }else if([noti.name isEqualToString:@"SCMoreViewController_DidSelectCellAtIndexPath"])
    {
        NSIndexPath *indexPath = [noti.userInfo valueForKey:@"indexPath"];
        SimiSection *section = [cells objectAtIndex:indexPath.section];
        SimiRow *row = [section objectAtIndex:indexPath.row];
        if ([row.identifier isEqualToString:MOREVIEW_ROW_CONTACTUS]) {
            moreViewController.isDiscontinue = YES;
            SCEmailContactViewController *emailViewController = [[SCEmailContactViewController alloc]init];
            [moreViewController.navigationController pushViewController:emailViewController animated:YES];
        }
    }else if([noti.name isEqualToString:@"SCMoreViewController-ViewDidLoad"])
    {
        [[NSNotificationCenter defaultCenter]removeObserverForNotification:noti];
        moreViewController = (SCMoreViewController *)noti.object;
    }
}

-(void)didReceiveNotificationFromCorePad:(NSNotification *)noti
{
    if([noti.name isEqualToString:@"SCLeftMenu_InitCellsAfter"])
    {
        cells = noti.object;
        for (int i = 0; i < cells.count; i++) {
            SimiSection *section = [cells objectAtIndex:i];
            if ([section.identifier isEqualToString:LEFTMENU_SECTION_MOREVIEW]) {
                SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_CONTACTUS height:40 sortOrder:50];
                row.image = [UIImage imageNamed:@""];
                row.title = SCLocalizedString(@"Contact Us");
                row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [section addObject:row];
                [section sortItems];
            }
        }
    }else if([noti.name isEqualToString:@"SCLeftMenu_DidSelectRow"])
    {
        UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
        SimiRow *row = [noti.userInfo valueForKey:@"simirow"];
        if ([row.identifier isEqualToString:LEFTMENU_ROW_CONTACTUS]) {
            SimiNavigationBarWorker *navi = noti.object;
            SCEmailContactViewController *emailViewController = [[SCEmailContactViewController alloc]init];
            navi.popController = nil;
            navi.popController = [[UIPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:emailViewController]];
            emailViewController.isInPopover = YES;
            emailViewController.popover = navi.popController;
            [navi.popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
            navi.isDiscontinue = YES;
        }
    }
}

-(void)didReceiveNotificationFromThemeOne:(NSNotification *)noti
{
    if([noti.name isEqualToString:@"SCListMenu_Theme01-InitCellsAfter"])
    {
        cells = (SimiTable *)noti.object;
        for (int i = 0; i < cells.count; i++) {
            SimiSection *section = [cells objectAtIndex:i];
            if ([section.identifier isEqualToString:@"THEME01_LISTMENU_SECTION_MORE"] || [section.identifier isEqualToString:@"ZTHEME_SECTION_MORE"]) {
                int emailContactSortOrder = 0;
                for (int j = 0; j < section.count; j++) {
                    SimiRow *row = [section objectAtIndex:j];
                    if ([row.identifier isEqualToString:@"THEME01_LISTMENU_ROW_SIGNIN"]) {
                        emailContactSortOrder = (int)row.sortOrder - 10;
                    }
                }
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    SimiRow *row = [[SimiRow alloc]initWithIdentifier:THEME01_LISTMENU_ROW_CONTACTUS height:45 sortOrder:emailContactSortOrder];
                    row.image = [UIImage imageNamed:@""];
                    row.title = SCLocalizedString(@"Contact Us");
                    [section addObject:row];
                }else
                {
                    SimiRow *row = [[SimiRow alloc]initWithIdentifier:THEME01_LISTMENU_ROW_CONTACTUS height:60 sortOrder:emailContactSortOrder];
                    row.image = [UIImage imageNamed:@""];
                    row.title = SCLocalizedString(@"Contact Us");
                    [section addObject:row];
                }
                [section sortItems];
            }
        }
    }else if([noti.name isEqualToString:@"SCListMenu_DidSelectRow"])
    {
        UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
        SimiRow *row = [noti.userInfo valueForKey:@"simirow"];
        if ([row.identifier isEqualToString:THEME01_LISTMENU_ROW_CONTACTUS]) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                NSObject *navi = noti.object;
                SCEmailContactViewController *emailViewController = [[SCEmailContactViewController alloc]init];
                [(UINavigationController*)currentVC pushViewController:emailViewController animated:YES];
                navi.isDiscontinue = YES;
            }else
            {
                NSObject *navi = noti.object;
                SCEmailContactViewController *emailViewController = [[SCEmailContactViewController alloc]init];
                _popController = nil;
                _popController = [[UIPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:emailViewController]];
                _popController.delegate= self;
                emailViewController.isInPopover = YES;
                emailViewController.popover = _popController;
                [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
                navi.isDiscontinue = YES;
            }
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
