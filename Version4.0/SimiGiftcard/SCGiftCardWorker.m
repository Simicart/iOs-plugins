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
#import <SimiCartBundle/SCCartViewController.h>
#import <SimiCartBundle/SimiCheckbox.h>
#import "SCGiftCardProductsViewController.h"

#define CART_VIEW_GIFTCARD @"CART_VIEW_GIFTCARD"

@implementation SCGiftCardWorker{
    SimiTable * cells;
    SimiCheckbox *giftCardCreditCb, *giftCardCb;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftmenuInitCellsAfter:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftmenuDidSelectRow:) name:@"SCLeftMenu_DidSelectRow" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartViewInitCells:) name:@"InitCartCell-After" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartViewCellForRow:) name:@"InitializedCartCell-After" object:nil];
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

- (void)cartViewInitCells:(NSNotification *)noti {
    NSDictionary *giftCardData = [SimiGlobalVar sharedInstance].cart.giftCardData;
    if([[giftCardData objectForKey:@"use_giftcard"] boolValue]) {
        SimiTable *cartCell = noti.object;
        SimiSection *totalSection = [cartCell getSectionByIdentifier:CART_TOTALS];
        [totalSection addRowWithIdentifier:CART_VIEW_GIFTCARD height:60 sortOrder:200];
        [totalSection sortItems];
    }
}

- (void)cartViewCellForRow:(NSNotification *)noti {
    UITableView *tableView = [noti.userInfo objectForKey:@"tableView"];
    SimiRow *row = [noti.userInfo objectForKey:@"row"];
    if([row.identifier isEqualToString:CART_VIEW_GIFTCARD]) {
        NSDictionary *giftCardData = [SimiGlobalVar sharedInstance].cart.giftCardData;
        NSDictionary *customerData = [giftCardData objectForKey:@"customer"];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CART_VIEW_GIFTCARD];
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CART_VIEW_GIFTCARD];
            giftCardCreditCb = [[SimiCheckbox alloc] initWithTitle:[NSString stringWithFormat:@"%@(%@)",SCLocalizedString(@"Use Gift Card credit to check out"),[customerData objectForKey:@"balance"]]];
            giftCardCreditCb.frame = CGRectMake(10, 0, tableView.frame.size.width - 20, 30);
            [cell.contentView addSubview:giftCardCreditCb];
            
            giftCardCb = [[SimiCheckbox alloc] initWithTitle:[NSString stringWithFormat:@"%@",SCLocalizedString(@"Use Gift Card to check out")]];
            giftCardCreditCb.frame = CGRectMake(10, 30, tableView.frame.size.width - 20, 30);
            [cell.contentView addSubview:giftCardCb];
        }
        UITableViewCell *aCell = [noti.userInfo objectForKey:@"cell"];
        aCell = cell;
    }
}

@end
