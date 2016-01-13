//
//  SimiStoreLocatorWorker.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/25/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//
#import "SimiStoreLocatorWorker.h"
#import <SimiCartBundle/SimiTableView.h>
#import <SimiCartBundle/SCMoreViewController.h>
#import <SimiCartBundle/SimiSection.h>
#import "SimiStoreLocatorViewController.h"
#import <SimiCartBundle/SCAppDelegate.h>
#import "SimiStoreLocatorViewController_iPad.h"
#import "SCLeftMenuView.h"
#import "SimiNavigationBarWorker.h"
@implementation SimiStoreLocatorWorker
{
    SCMoreViewController * moreViewController;
    SimiTable *cells;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCMoreViewController_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCMoreViewController_DidSelectCellAtIndexPath" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCMoreViewController-ViewDidLoad" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotificationFromCorePad:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotificationFromCorePad:) name:@"SCLeftMenu_DidSelectRow" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotificationFromThemeOne:) name:@"SCListMenu_Theme01-InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotificationFromThemeOne:) name:@"SCListMenu_DidSelectRow" object:nil];
    }
    [GMSServices provideAPIKey:@"AIzaSyAmBe73HHr9CU1lYU96CFg6PTwG2i6NDwU"];
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"SCMoreViewController_InitCellsAfter"]) {
        cells = noti.object;
        SimiSection *section = [SimiSection new];
        section.identifier = MOREVIEW_SECTION_STORELOCATOR;
        section.headerTitle = @"Plugin";
        [cells insertObject:section atIndex:[cells getSectionIndexByIdentifier:MOREVIEW_SECTION_MORE]];
        
        SimiRow *row = [[SimiRow alloc]initWithIdentifier:MOREVIEW_ROW_STORELOCATOR height:40];
        row.title = SCLocalizedString(@"Store Locator");
        row.image = [UIImage imageNamed:@"storelocator_locator.png"];
        row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [section addObject:row];
    }else if ([noti.name isEqualToString:@"SCMoreViewController_DidSelectCellAtIndexPath"])
    {
        NSIndexPath *indexPath = [noti.userInfo valueForKey:@"indexPath"];
        SimiSection *section = [cells objectAtIndex:indexPath.section];
        SimiRow *row = [section objectAtIndex:indexPath.row];
        if ([section.identifier isEqualToString:MOREVIEW_SECTION_STORELOCATOR]) {
            if ([row.identifier isEqualToString:MOREVIEW_ROW_STORELOCATOR]) {
                SimiStoreLocatorViewController *storeLocatorViewController = [[SimiStoreLocatorViewController alloc]init];
                [moreViewController.navigationController pushViewController:storeLocatorViewController animated:YES];
                moreViewController.isDiscontinue = YES;
            }
        }
    }else if ([noti.name isEqualToString:@"SCMoreViewController-ViewDidLoad"])
    {
        moreViewController = noti.object;
    }
}

-(void)didReceiveNotificationFromCorePad:(NSNotification*)noti
{
    if ([noti.name isEqualToString:@"SCLeftMenu_InitCellsAfter"]) {
        cells =  noti.object;
        SimiSection *section = [SimiSection new];
        section.identifier = LEFTMENU_SECTION_STORELOCATOR;
        section.headerTitle = @"Plugin";
        [cells insertObject:section atIndex:[cells getSectionIndexByIdentifier:LEFTMENU_SECTION_MOREVIEW]];
        
        SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_STORELOCATOR height:40];
        row.simiObjectIdentifier = @"StoreLocator";
        row.title = SCLocalizedString(@"Store Locator");
        row.image = [UIImage imageNamed:@"storelocator_locator.png"];
        row.accessoryType = UITableViewCellAccessoryNone;
        [section addObject:row];
    }else if ([noti.name isEqualToString:@"SCLeftMenu_DidSelectRow"])
    {
        SimiRow *row = [(SimiRow*)noti.userInfo valueForKey:@"simirow"];
        UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
        if ([row.identifier isEqualToString:LEFTMENU_ROW_STORELOCATOR]) {
            SimiNavigationBarWorker *navi = noti.object;
            SimiStoreLocatorViewController_iPad *storeLocatorViewController = [[SimiStoreLocatorViewController_iPad alloc]init];
            [(UINavigationController *)currentVC popToRootViewControllerAnimated:NO];
            [(UINavigationController *)currentVC pushViewController:storeLocatorViewController animated:YES];
            navi.isDiscontinue = YES;
        }
    }
}

- (void)didReceiveNotificationFromThemeOne:(NSNotification*)noti
{
    if ([noti.name isEqualToString:@"SCListMenu_Theme01-InitCellsAfter"])
    {
        cells = (SimiTable *)noti.object;
        for (int i = 0; i < cells.count; i++) {
            SimiSection *section = [cells objectAtIndex:i];
            if ([section.identifier isEqualToString:@"THEME01_LISTMENU_SECTION_MORE"] || [section.identifier isEqualToString:@"ZTHEME_SECTION_MORE"]) {
                SimiRow *row = [[SimiRow alloc]initWithIdentifier:THEME01_LISTMENU_ROW_STORELOCATOR height:40 sortOrder:10];
                row.title = SCLocalizedString(@"Store Locator");
                row.image = [[UIImage imageNamed:@"storelocator_locator.png"]imageWithColor:[UIColor whiteColor]];
                [section addRow:row];
                [section sortItems];
            }
        }
    }else if ([noti.name isEqualToString:@"SCListMenu_DidSelectRow"])
    {
        SimiRow *row = [noti.userInfo valueForKey:@"simirow"];
        NSObject *navi = noti.object;
        if ([row.identifier isEqualToString:THEME01_LISTMENU_ROW_STORELOCATOR]) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
                SimiStoreLocatorViewController_iPad *storeLocatorViewController = [[SimiStoreLocatorViewController_iPad alloc]init];
                [(UINavigationController *)currentVC pushViewController:storeLocatorViewController animated:YES];
            }else
            {
                UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
                SimiStoreLocatorViewController *storeLocatorViewController = [[SimiStoreLocatorViewController alloc]init];
                [(UINavigationController *)currentVC pushViewController:storeLocatorViewController animated:YES];
            }
            navi.isDiscontinue = YES;
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
