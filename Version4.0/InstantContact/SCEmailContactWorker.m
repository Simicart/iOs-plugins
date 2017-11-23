//
//  SCEmailContactWorker.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 10/15/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCEmailContactWorker.h"
#import "SCEmailContactViewController.h"
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SCLeftMenuViewController.h>
#import <SimiCartBundle/SCNavigationBarPhone.h>
#import <SimiCartBundle/SCNavigationBarPad.h>

@implementation SCEmailContactWorker
{
    NSMutableArray * cells;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initCellsEnd:) name:[NSString stringWithFormat:@"%@%@",SCLeftMenuViewController_RootEventName,SimiTableViewController_SubKey_InitCells_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectCell:) name:[NSString stringWithFormat:@"%@%@",SCLeftMenuViewController_RootEventName,SimiTableViewController_SubKey_DidSelectCell] object:nil];
    }
    return self;
}

- (void)initCellsEnd:(NSNotification*)noti{
    cells = noti.object;
    for (int i = 0; i < cells.count; i++) {
        SimiSection *section = [cells objectAtIndex:i];
        NSDictionary *instantContact = nil;
        if ([GLOBALVAR.storeView valueForKey:@"instant_contact"]) {
            instantContact = [GLOBALVAR.storeView valueForKey:@"instant_contact"];
        }
        if ([section.identifier isEqualToString:LEFTMENU_SECTION_MORE] && instantContact.count > 0) {
            SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_CONTACTUS height:50 sortOrder:70];
            row.image = [UIImage imageNamed:@"ic_contact"];
            row.title = SCLocalizedString(@"Contact Us");
            row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [section addObject:row];
            [section sortItems];
        }
    }
}

- (void)didSelectCell:(NSNotification*)noti{
    UINavigationController *navigationController = kNavigationController;
    NSIndexPath *indexPath = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    cells = noti.object;
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if ([row.identifier isEqualToString:LEFTMENU_ROW_CONTACTUS]) {
        SCEmailContactViewController *emailViewController = [[SCEmailContactViewController alloc]init];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            SCNavigationBarPhone *navi = noti.object;
            navi.isDiscontinue = YES;
            [navigationController pushViewController:emailViewController animated:YES];
        }else
        {
            UIViewController *baseViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
            UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:emailViewController];
            navi.modalPresentationStyle = UIModalPresentationPopover;
            UIPopoverPresentationController *popover = navi.popoverPresentationController;
            popover.sourceRect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
            popover.sourceView = baseViewController.view;
            popover.permittedArrowDirections = 0;
            [baseViewController presentViewController:navi animated:YES completion:nil];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
