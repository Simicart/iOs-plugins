//
//  LoyaltyModelCollection.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 1/27/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import "LoyaltyModelCollection.h"
#import "LoyaltyAPI.h"

@implementation LoyaltyModelCollection

- (void)getTransactionsWithOffset:(NSInteger)offset limit:(NSInteger)limit
{
    notificationName = Loyalty_DidGetLoyaltyTransactions;
    [self preDoRequest];
    actionType = CollectionActionTypeInsert;
    self.parseKey = @"simirewardpointstransactions";
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    [params setValue:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    
    [[LoyaltyAPI new] loadTransactionWithParams:params target:self selector:@selector(didGetResponseFromNetwork:)];
}

@end
