//
//  BarCodeWorker.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 1/16/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//
#import <SimiCartBundle/SCHomeViewController.h>
#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/SimiGlobalVar.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>
#import <SimiCartBundle/SimiTable.h>

#import "SCLeftMenuView.h"
#import "SimiNavigationBarWorker.h"
#import "BarCodeWorker.h"
@implementation BarCodeWorker
{
    SimiTable *cells;
    UISearchBar *searchBar;
    UITableViewCell *cell;
    UIButton *btnScanBarCode;
    NSIndexPath *indexPath;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotification:) name:@"InitializedHomeCell-After" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotification:) name:@"SCMoreViewController_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotification:) name:@"SCMoreViewController_DidSelectCellAtIndexPath" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotificationFromThemeOne:) name:@"SCListMenu_Theme01-InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotificationFromThemeOne:) name:@"SCListMenu_DidSelectRow" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotificationFromCorePad:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotificationFromCorePad:) name:@"SCLeftMenu_DidSelectRow" object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"InitializedHomeCell-After"]) {
        cell = noti.object;
        if ([cell.reuseIdentifier isEqualToString:HOME_SEARCH_CELL]) {
            cells = (SimiTable*)[noti.userInfo valueForKey:@"cells"];
            indexPath = (NSIndexPath*)[noti.userInfo valueForKey:@"indexPath"];
            
            NSArray *subViewsArray = cell.subviews;
            if (SIMI_SYSTEM_IOS < 8.0)
                subViewsArray = cell.contentView.subviews;
            
            for (UIView *view in subViewsArray)
            {
                if ([view.simiObjectName isEqualToString:@"SearchBarOnHome"]) {
                    searchBar = (UISearchBar*)view;
                    CGRect frame = cell.frame;
                    frame.size.width -= frame.size.width/4;
                    [searchBar setFrame:frame];
                }
            }
            
            CGRect frame = cell.frame;
            frame.origin.x = searchBar.frame.origin.x + searchBar.frame.size.width + 10;
            frame.size.width = frame.size.width - frame.origin.x - 10;
            btnScanBarCode = [[UIButton alloc]initWithFrame:frame];
            [btnScanBarCode setImage:[UIImage imageNamed:@"barcode_icon"] forState:UIControlStateNormal];
            [btnScanBarCode setImageEdgeInsets:UIEdgeInsetsMake((frame.size.height - 32)/2, (frame.size.width - 32)/2, (frame.size.height - 32)/2, (frame.size.width - 32)/2)];
            [btnScanBarCode setBackgroundColor:[UIColor clearColor]];
            [btnScanBarCode addTarget:self action:@selector(didTapButtonScan) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:btnScanBarCode];
        }
    }else if ([noti.name isEqualToString:@"SCMoreViewController_InitCellsAfter"])
    {
        cells = noti.object;
        SimiSection *section = [[SimiSection alloc] initWithHeaderTitle:[SCLocalizedString(@"QR & Barcode") uppercaseString] footerTitle:nil];
        section.identifier = MOREVIEW_SECTION_BARCODE;
        
        SimiRow *row = [[SimiRow alloc]initWithIdentifier:MOREVIEW_ROW_BARCODE height:45];
        row.title = SCLocalizedString(@"Scan Now");
        row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        row.image = [[UIImage imageNamed:@"barcode_icon"] imageWithColor:[UIColor blackColor]];
        [section addRow:row];
        [cells insertObject:section atIndex:[cells getSectionIndexByIdentifier:MOREVIEW_SECTION_MYACCOUNT] + 1];
    }else if([noti.name isEqualToString:@"SCMoreViewController_DidSelectCellAtIndexPath"])
    {
        cells = noti.object;
        indexPath = [noti.userInfo valueForKey:@"indexPath"];
        SimiSection *section = [cells objectAtIndex:indexPath.section];
        SimiRow *row = [section objectAtIndex:indexPath.row];
        if ([section.identifier isEqualToString:MOREVIEW_SECTION_BARCODE]) {
            if ([row.identifier isEqualToString:MOREVIEW_ROW_BARCODE]) {
                [self didTapButtonScan];
            }
        }
        
        
    }
}

- (void)didReceiveNotificationFromThemeOne:(NSNotification *)noti
{
    if([noti.name isEqualToString:@"SCListMenu_Theme01-InitCellsAfter"])
    {
        cells = noti.object;
        SimiSection *section = [[SimiSection alloc] initWithHeaderTitle:[SCLocalizedString(@"QR & Barcode") uppercaseString] footerTitle:nil];
        section.identifier = THEME01_LISTMENU_SECTION_BARCODE;
        SimiRow *row = [[SimiRow alloc]initWithIdentifier:THEME01_LISTMENU_ROW_BARCODE height:45];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            row.height = 60;
        }
        row.title = SCLocalizedString(@"Scan Now");
        row.image = [[UIImage imageNamed:@"barcode_icon"] imageWithColor:[UIColor whiteColor]];
        [section addRow:row];
        [cells insertObject:section atIndex:1];
    }else if ([noti.name isEqualToString:@"SCListMenu_DidSelectRow"])
    {
        SimiRow *row = [noti.userInfo valueForKey:@"simirow"];
        if ([row.identifier isEqualToString:THEME01_LISTMENU_ROW_BARCODE]) {
            NSObject *navi = noti.object;
            navi.isDiscontinue = YES;
            [self didTapButtonScan];
        }
    }
}

- (void)didReceiveNotificationFromCorePad:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"SCLeftMenu_InitCellsAfter"])
    {
        cells = noti.object;
        SimiSection *section = [[SimiSection alloc] initWithHeaderTitle:[SCLocalizedString(@"QR & Barcode") uppercaseString] footerTitle:nil];
        section.identifier = LEFTMENU_SECTION_BARCODE;
        SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_BARCODE height:45];
        row.title = SCLocalizedString(@"Scan Now");
        row.image = [[UIImage imageNamed:@"barcode_icon"] imageWithColor:[UIColor blackColor]];
        [section addRow:row];
        [cells insertObject:section atIndex:[cells getSectionIndexByIdentifier:LEFTMENU_SECTION_MYACCOUNT]];
    }else if ([noti.name isEqualToString:@"SCLeftMenu_DidSelectRow"])
    {
        _simiNavigationBarWorker = noti.object;
        _leftMenu = _simiNavigationBarWorker.leftMenu;
        SimiRow *row = [noti.userInfo valueForKey:@"simirow"];
        if ([row.identifier isEqualToString:LEFTMENU_ROW_BARCODE]) {
            [self didTapButtonScan];
        }
    }
}

- (void)didTapButtonScan
{
    UIViewController *currentViewController = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    if (_barCodeViewController == nil) {
        _barCodeViewController = [BarCodeViewController new];
    }
    _barCodeViewController.leftMenuView = _leftMenu;
    switch ([SimiGlobalVar sharedInstance].themeUsing) {
        case ThemeShowDefault:
        {
            [(UINavigationController*)currentViewController pushViewController:_barCodeViewController animated:NO];
        }
            break;
        case ThemeShowMatrixTheme:
        {
            SimiNavigationController *navi = (SimiNavigationController*)currentViewController;
            if ([navi.viewControllers containsObject:_barCodeViewController]    ) {
                [navi popToViewController:_barCodeViewController animated:NO];
            }else
            {
                [navi pushViewController:_barCodeViewController animated:NO];
            }
        }
            break;
        case ThemeShowZTheme:
        {
            SimiNavigationController *navi = (SimiNavigationController*)currentViewController;
            if ([navi.viewControllers containsObject:_barCodeViewController]    ) {
                [navi popToViewController:_barCodeViewController animated:NO];
            }else
            {
                [navi pushViewController:_barCodeViewController animated:NO];
            }
        }
        default:
            break;
    }
    
        
    
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
