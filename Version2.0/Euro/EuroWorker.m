//
//  EuroWorker.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/16/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "EuroWorker.h"
#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/SCOrderViewController.h>

@implementation EuroWorker
{
    SimiTable *orderTable;
}
- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCOrderViewController-InitTableAfter" object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if([noti.name isEqualToString:@"SCOrderViewController-InitTableAfter"])
    {
        SimiTable *tempTable = [SimiTable new];
        orderTable = noti.object;
        SimiSection *section01 = [orderTable getSectionByIdentifier:ORDER_COUPON_SECTION];
        if (section01) {
            [tempTable addObject:section01];
        }
        for (int i = 0; i < orderTable.count; i++) {
            SimiSection *section02 = [orderTable objectAtIndex:i];
            if ([section02.identifier isEqualToString:ORDER_TERMS_SECTION]) {
                [tempTable addObject:section02];
            }
        }
        SimiSection *section03 = [orderTable getSectionByIdentifier:ORDER_ADDRESS_SECTION];
        if (section03) {
            [tempTable addObject:section03];
        }
        SimiSection *section04 = [orderTable getSectionByIdentifier:ORDER_SHIPMENT_SECTION];
        if (section04) {
            [tempTable addObject:section04];
        }
        SimiSection *section05 = [orderTable getSectionByIdentifier:ORDER_PAYMENT_SECTION];
        if (section05) {
            [tempTable addObject:section05];
        }
        SimiSection *section06 = [orderTable getSectionByIdentifier:ORDER_TOTALS_SECTION];
        if (section06) {
            [tempTable addObject:section06];
        }
        SimiSection *section07 = [orderTable getSectionByIdentifier:ORDER_BUTTON_SECTION];
        if (section07) {
            [tempTable addObject:section07];
        }
        [orderTable removeAllObjects];
        for (int i = 0; i < tempTable.count; i++) {
            [orderTable addObject:[tempTable objectAtIndex:i]];
        }
    }
}
@end
