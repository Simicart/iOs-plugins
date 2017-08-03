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

@implementation SCGiftCardWorker{
    SimiTable * cells;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftmenuInitCellsAfter:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftmenuDidSelectRow:) name:@"SCLeftMenu_DidSelectRow" object:nil];
    }
    return self;
}

- (void)leftmenuInitCellsAfter:(NSNotification*)noti{
    cells = noti.object;
    SimiSection *section = [cells getSectionByIdentifier:LEFTMENU_SECTION_MAIN];
    SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_GIFTCARD height:50 sortOrder:600];
    row.image = [UIImage imageNamed:@"ic_contact"];
    row.title = SCLocalizedString(@"GiftCard Products");
    row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [section addObject:row];
    [section sortItems];
}

- (void)leftmenuDidSelectRow:(NSNotification*)noti{
    SimiRow *row = [noti.userInfo valueForKey:@"simirow"];
    if ([row.identifier isEqualToString:LEFTMENU_ROW_GIFTCARD]) {
        SCGiftCardProductsViewController *giftCardProductViewController = [SCGiftCardProductsViewController new];
        [[SimiGlobalVar sharedInstance].currentlyNavigationController pushViewController:giftCardProductViewController animated:YES];
    }
}
@end
