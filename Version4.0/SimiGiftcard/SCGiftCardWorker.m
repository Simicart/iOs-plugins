//
//  SCGiftCardWorker.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCGiftCardWorker.h"
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SCLeftMenuViewController.h>
#import "SCGiftCardProductsViewController.h"
#import "SCAccountViewController.h"
#import "SCMyGiftCardViewController.h"

static NSString *LEFTMENU_ROW_GIFTCARD = @"LEFTMENU_ROW_GIFTCARD";
static NSString *ACCOUNT_GIFTCARD_ROW = @"ACCOUNT_GIFTCARD_ROW";
@implementation SCGiftCardWorker{
    SimiTable * cells;
    SimiGiftCardTimeZoneModelCollection *timeZoneModelCollection;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftmenuInitCellsAfter:) name:[NSString stringWithFormat:@"%@%@",SCLeftMenuViewController_RootEventName,SimiTableViewController_SubKey_InitCells_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftmenuDidSelectRow:) name:[NSString stringWithFormat:@"%@%@",SCLeftMenuViewController_RootEventName,SimiTableViewController_SubKey_DidSelectCell] object:nil];
        
        self.giftCardOnCartWorker = [[SCGiftCardOnCartWorker alloc] init];
        self.giftCardOnOrderWorker = [[SCGiftCardOnOrderWorker alloc] init];
        
        //My Account Screen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedAccountCellAfter:) name:[NSString stringWithFormat:@"%@%@",SCAccountViewController_RootEventName,SimiTableViewController_SubKey_InitCells_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectAccountCellAtIndexPath:) name:[NSString stringWithFormat:@"%@%@",SCAccountViewController_RootEventName,SimiTableViewController_SubKey_DidSelectCell] object:nil];
    }
    return self;
}

- (void)leftmenuInitCellsAfter:(NSNotification*)noti{
    cells = noti.object;
    SimiSection *section = [cells getSectionByIdentifier:LEFTMENU_SECTION_MAIN];
    SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_GIFTCARD height:50 sortOrder:600];
    row.image = [UIImage imageNamed:@"ic_giftcard"];
    row.title = SCLocalizedString(@"GiftCard Products");
    row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [section addObject:row];
    [section sortItems];
    if ([SCGiftCardGlobalVar sharedInstance].timeZoneModelCollection == nil || [SCGiftCardGlobalVar sharedInstance].timeZoneModelCollection.count == 0) {
        timeZoneModelCollection = [SimiGiftCardTimeZoneModelCollection new];
        [timeZoneModelCollection getGiftCardTimeZoneWithParams:@{}];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetTimeZone:) name:DidGetSimiTimeZone object:timeZoneModelCollection];
    }
}

- (void)didGetTimeZone:(NSNotification*)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    [self removeObserverForNotification:noti];
    if (responder.status == SUCCESS) {
        [SCGiftCardGlobalVar sharedInstance].timeZoneModelCollection = timeZoneModelCollection;
    }
}

- (void)leftmenuDidSelectRow:(NSNotification*)noti{
    NSIndexPath *indexPath = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    cells = noti.object;
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if ([row.identifier isEqualToString:LEFTMENU_ROW_GIFTCARD]) {
        SCGiftCardProductsViewController *giftCardProductViewController = [SCGiftCardProductsViewController new];
        [[SimiGlobalVar sharedInstance].currentlyNavigationController pushViewController:giftCardProductViewController animated:YES];
    }
}

#pragma mark Add to My Account Screen
-(void)initializedAccountCellAfter:(NSNotification *)noti{
    SimiTable *accountCells = noti.object;
    SimiSection* section = [accountCells getSectionByIdentifier:ACCOUNT_MAIN_SECTION];
    SimiRow *giftcardRow = [[SimiRow alloc]initWithIdentifier:ACCOUNT_GIFTCARD_ROW height:45 sortOrder:350];
    giftcardRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    giftcardRow.title = SCLocalizedString(@"My Giftcard");
    giftcardRow.image = [UIImage imageNamed:@"ic_giftcard"];
    [section addRow:giftcardRow];
}

-(void)didSelectAccountCellAtIndexPath:(NSNotification *)noti{
    NSIndexPath *indexPath = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    cells = noti.object;
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if ([row.identifier isEqualToString:ACCOUNT_GIFTCARD_ROW]) {
        SCAccountViewController *accountVC = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
        SCMyGiftCardViewController *myGiftCardViewController = [SCMyGiftCardViewController new];
        [accountVC.navigationController pushViewController:myGiftCardViewController animated:YES];
        accountVC.isDiscontinue = YES;
    }
}
@end
