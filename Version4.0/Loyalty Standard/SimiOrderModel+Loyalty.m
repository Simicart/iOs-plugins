//
//  SimiOrderModel+Loyalty.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 2/3/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import "SimiOrderModel+Loyalty.h"

@implementation SimiOrderModel (Loyalty)

- (void)spendPoints:(NSInteger)points ruleId:(id)ruleId{
    actionType = ModelActionTypeGet;
    notificationName = Loyalty_DidSpendPointsOrder;
    self.parseKey = @"order";
    self.resource = @"simirewardpoints/spend";
    [self.body addEntriesFromDictionary:@{@"ruleid":ruleId, @"usepoint": [NSNumber numberWithInteger:points]}];
    self.method = MethodPut;
    [self preDoRequest];
    [self request];
}

@end
