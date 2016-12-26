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

- (void)loadProgramOverview
{
    currentNotificationName = @"LoadedProgramOverview";
    keyResponse = @"simirewardpoint";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    [(LoyaltyAPI *)[self getAPI] loadProgramOverviewWithTarget:self selector:@selector(didFinishRequest:responder:)];
}

- (void)saveSettings
{
    currentNotificationName = @"SavedLoyaltySettings";
    keyResponse = @"simirewardpoint";
    modelActionType = ModelActionTypeEdit;
    [self preDoRequest];
    [(LoyaltyAPI *)[self getAPI] saveSettings:self selector:@selector(didFinishRequest:responder:)];
}

- (void)activeCouponCodeWithParams: (NSDictionary *)params
{
    currentNotificationName = @"DidActiveCouponCode";
    keyResponse = @"simirewardpoint";
    [self preDoRequest];
    [(LoyaltyAPI *)[self getAPI] activeCouponCodeWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

@end
