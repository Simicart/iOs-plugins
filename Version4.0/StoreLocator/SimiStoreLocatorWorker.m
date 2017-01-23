//
//  SimiStoreLocatorWorker.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/25/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//
#import "SimiStoreLocatorWorker.h"
#import <SimiCartBundle/SimiTableView.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SimiTable.h>
#import "SimiStoreLocatorViewController.h"
#import "SimiStoreLocatorViewControllerPad.h"
#import <SimiCartBundle/SCNavigationBarPhone.h>
#import <SimiCartBundle/SCNavigationBarPad.h>
#import <SimiCartBundle/SCHomeViewController.h>

@implementation SimiStoreLocatorWorker
{
    SimiTable *cells;
    BOOL isAddedButtonItem;
    UIBarButtonItem* storeLocatorItem;
    UIBarButtonItem* spacerItem;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initCellsAfter:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectRow:) name:@"SCLeftMenu_DidSelectRow" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addItemToLeftBar:) name:@"AddingLeftBarItems" object:nil];
    }
    [GMSServices provideAPIKey:@"AIzaSyAmBe73HHr9CU1lYU96CFg6PTwG2i6NDwU"];
    return self;
}

-(void) addItemToLeftBar:(NSNotification*) noti{
    UINavigationController *currentVC = (UINavigationController*) [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    NSMutableArray* leftBarItems = noti.object;
    if([currentVC.viewControllers.lastObject isKindOfClass:[SCHomeViewController class]]){
        if(!isAddedButtonItem){
            UIButton* storeLocatorButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
            [storeLocatorButton setImage:[[UIImage imageNamed:@"sl_icon__09"] imageWithColor:THEME_NAVIGATION_ICON_COLOR] forState:UIControlStateNormal];
            [storeLocatorButton addTarget:self action:@selector(openStoreLocatorView:) forControlEvents:UIControlEventTouchUpInside];
            storeLocatorItem = [[UIBarButtonItem alloc] initWithCustomView:storeLocatorButton];
            spacerItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            spacerItem.width = 10;
            [leftBarItems addObjectsFromArray:@[spacerItem, storeLocatorItem]];
            isAddedButtonItem = YES;
        }
    }else{
        if(isAddedButtonItem){
            [leftBarItems removeObject:storeLocatorItem];
            [leftBarItems removeObject:spacerItem];
            isAddedButtonItem = NO;
        }
    }
}

-(void) openStoreLocatorView:(id) sender{
    UINavigationController *currentVC = (UINavigationController*) [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    if (PADDEVICE) {
        if(![currentVC.viewControllers.lastObject isKindOfClass:[SimiStoreLocatorViewControllerPad class]]){
            SimiStoreLocatorViewControllerPad *storeLocatorViewController = [[SimiStoreLocatorViewControllerPad alloc]init];
            [currentVC pushViewController:storeLocatorViewController animated:YES];
        }
    }else
    {
        if(![currentVC.viewControllers.lastObject isKindOfClass:[SimiStoreLocatorViewController class]]){
            SimiStoreLocatorViewController *storeLocatorViewController = [[SimiStoreLocatorViewController alloc]init];
            [currentVC pushViewController:storeLocatorViewController animated:YES];
        }
    }
}

- (void)initCellsAfter:(NSNotification*)noti
{
    cells = noti.object;
    for (int i = 0; i < cells.count; i++) {
        SimiSection *section = [cells objectAtIndex:i];
        if ([section.identifier isEqualToString:LEFTMENU_SECTION_MORE]) {
            SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_STORELOCATOR height:50 sortOrder:60];
            row.image = [UIImage imageNamed:@"storelocator_locator"];
            row.title = SCLocalizedString(@"Store Locator");
            row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [section addObject:row];
            [section sortItems];
        }
    }
}

- (void)didSelectRow:(NSNotification*)noti
{
    SimiRow *row = [noti.userInfo valueForKey:@"simirow"];
    SCNavigationBarPhone *navi = noti.object;
    if ([row.identifier isEqualToString:LEFTMENU_ROW_STORELOCATOR]) {
        if (PADDEVICE) {
            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
            SimiStoreLocatorViewControllerPad *storeLocatorViewController = [[SimiStoreLocatorViewControllerPad alloc]init];
            [(UINavigationController *)currentVC pushViewController:storeLocatorViewController animated:YES];
        }else{
            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
            SimiStoreLocatorViewController *storeLocatorViewController = [[SimiStoreLocatorViewController alloc]init];
            [(UINavigationController *)currentVC pushViewController:storeLocatorViewController animated:YES];
        }
        navi.isDiscontinue = YES;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
