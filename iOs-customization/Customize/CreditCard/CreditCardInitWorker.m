//
//  CreditCardInitWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 2/5/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "CreditCardInitWorker.h"
#import <SimiCartBundle/SCAccountViewController.h>
#import "SCListCreditCardViewController.h"

#define MY_CREDIT_CARDS @"MY_CREDIT_CARDS"

@implementation CreditCardInitWorker

- (id)init{
    if(self == [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAccountInitCellsEnd:) name:[NSString stringWithFormat:@"%@%@",SCAccountViewController_RootEventName,SimiTableViewController_SubKey_InitCells_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAccountDidSelectCell:) name:[NSString stringWithFormat:@"%@%@",SCAccountViewController_RootEventName,SimiTableViewController_SubKey_DidSelectCell] object:nil];
    }
    return self;
}

- (void)myAccountInitCellsEnd:(NSNotification *)noti{
    SimiTable *cells = noti.object;
    SimiSection *section = [cells getSectionByIdentifier:ACCOUNT_MAIN_SECTION];
    SimiRow *row = [section getRowByIdentifier:ACCOUNT_ORDERS_ROW];
    SimiRow *myCreditCards = [section addRowWithIdentifier:MY_CREDIT_CARDS height:row.height sortOrder:row.sortOrder + 1];
    myCreditCards.image = [[UIImage imageNamed:@"custom_ic_credit_card"] imageWithColor:THEME_ICON_COLOR];
    myCreditCards.title = SCLocalizedString(@"MY CREDIT CARDS");
}

- (void)myAccountDidSelectCell:(NSNotification *)noti{
    SimiTable *cells = noti.object;
    NSIndexPath *indexPath = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    SCAccountViewController *accountVC = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if([row.identifier isEqualToString:MY_CREDIT_CARDS]){
        accountVC.isDiscontinue = YES;
        SCListCreditCardViewController *listCardVC = [SCListCreditCardViewController new];
        [accountVC.navigationController pushViewController:listCardVC animated:YES];
    }
}
@end
