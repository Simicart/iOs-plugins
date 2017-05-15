//
//  SimiOrderModel+Loyalty.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 2/3/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import "SimiOrderModel+Loyalty.h"
#import "LoyaltyAPI.h"

@implementation SimiOrderModel (Loyalty)

- (void)spendPoints:(NSInteger)points ruleId:(id)ruleId
{
    modelActionType = ModelActionTypeGet;
    currentNotificationName = @"DidSpendPointsOrder";
    keyResponse = @"order";
    [self preDoRequest];
    [[LoyaltyAPI new] spendPointsWithParams:@{@"ruleid":ruleId, @"usepoint": [NSNumber numberWithInteger:points]} target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)spendPoints:(NSString *)points{
    modelActionType = ModelActionTypeGet;
    currentNotificationName = @"DidSpendPointsOrder";
    keyResponse = @"order";
    [self preDoRequest];
    [[LoyaltyAPI new] spendPointsWithParams:@{@"usepoint": points} target:self selector:@selector(didFinishRequest:responder:)];
}

@end
