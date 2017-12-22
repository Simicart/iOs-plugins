//
//  LoyaltyModelCollection.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 1/27/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import "LoyaltyModelCollection.h"

@implementation LoyaltyModelCollection
- (void)getTransactionsWithOffset:(NSInteger)offset limit:(NSInteger)limit{
    notificationName = Loyalty_DidGetLoyaltyTransactions;
    actionType = CollectionActionTypeInsert;
    self.parseKey = @"simirewardpointstransactions";
    self.resource = @"simirewardpointstransactions";
    [self addOffsetToParams:[NSString stringWithFormat:@"%ld",offset]];
    [self addLimitToParams:[NSString stringWithFormat:@"%ld",limit]];
    self.method = MethodGet;
    [self preDoRequest];
    [self request];
}
@end
