//
//  LoyaltyModel.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 1/16/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import "LoyaltyModel.h"
#import "LoyaltyAPI.h"

@implementation LoyaltyModel
//reward_id,loyalty_point,loyalty_balance,loyalty_redeem,loyalty_hold,loyalty_image,is_notification,expire_notification,earning_label,earning_policy,spending_label,spending_policy,spending_point,spending_discount,start_discount,spending_min,policies
- (void)parseData {
    [super parseData];
    if([self.modelData objectForKey:@"reward_id"])
        self.rewardId = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"reward_id"]];
    if([self.modelData objectForKey:@"loyalty_point"])
        self.loyaltyPoint = [[self.modelData objectForKey:@"loyalty_point"] floatValue];
    if([self.modelData objectForKey:@"invert_point"])
        self.invertPoint = [[self.modelData objectForKey:@"invert_point"] floatValue];
    if([self.modelData objectForKey:@"loyalty_balance"])
        self.loyaltyBalance = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"loyalty_balance"]];
    if([self.modelData objectForKey:@"loyalty_redeem"])
        self.loyaltyRedeem = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"loyalty_redeem"]];
    if([self.modelData objectForKey:@"loyalty_hold"])
        self.loyaltyHold = [[self.modelData objectForKey:@"loyalty_hold"] floatValue];
    if([self.modelData objectForKey:@"loyalty_image"])
        self.loyaltyImage = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"loyalty_image"]];
    if([self.modelData objectForKey:@"is_notification"])
        self.isNotification = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"is_notification"]];
    if([self.modelData objectForKey:@"expire_notification"])
        self.expireNotification = [[self.modelData objectForKey:@"expire_notification"] boolValue];
    if([self.modelData objectForKey:@"earning_label"])
        self.earningLabel = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"earning_label"]];
    if([self.modelData objectForKey:@"earning_policy"])
        self.earningPolicy = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"earning_policy"]];
    if([self.modelData objectForKey:@"spending_label"])
        self.spendingLabel = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"spending_label"]];
    if([self.modelData objectForKey:@"spending_policy"])
        self.spendingPolicy = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"spending_policy"]];
    if([self.modelData objectForKey:@"spending_point"])
        self.spendingPoint = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"spending_point"]];
    if([self.modelData objectForKey:@"spending_discount"])
        self.spendingDiscount = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"spending_discount"]];
    if([self.modelData objectForKey:@"start_discount"])
        self.startDiscount = [[self.modelData objectForKey:@"start_discount"] intValue];
    if([self.modelData objectForKey:@"spending_min"])
        self.spendingMin = [[self.modelData objectForKey:@"spending_min"] intValue];
    if([[self.modelData objectForKey:@"policies"] isKindOfClass:[NSArray class]]){
        self.policies = [self.modelData objectForKey:@"policies"];
    }
}

- (void)loadProgramOverview
{
    notificationName = @"LoadedProgramOverview";
    self.parseKey = @"simirewardpoint";
    actionType = ModelActionTypeGet;
    [self preDoRequest];
    [[LoyaltyAPI new] loadProgramOverviewWithParams:self.modelData target:self selector:@selector(didGetResponseFromNetwork:)];
}

- (void)saveSettings
{
    notificationName = @"SavedLoyaltySettings";
    self.parseKey = @"simirewardpoint";
    actionType = ModelActionTypeEdit;
    [self preDoRequest];
    [[LoyaltyAPI new] saveSettingsWithParams:self.modelData target:self selector:@selector(didGetResponseFromNetwork:)];
}

@end
