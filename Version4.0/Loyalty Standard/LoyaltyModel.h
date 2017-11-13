//
//  LoyaltyModel.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 1/16/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
static NSString *const Loyalty_LoadedProgramOverview = @"LoadedProgramOverview";
static NSString *const Loyalty_SavedLoyaltySettings = @"SavedLoyaltySettings";

@interface LoyaltyModel : SimiModel

@property (strong, nonatomic) NSString *rewardId;
@property (nonatomic) float loyaltyPoint;
@property (strong, nonatomic) NSString *invertPoint;
@property (strong, nonatomic) NSString *loyaltyBalance;
@property (strong, nonatomic) NSString *loyaltyRedeem;
@property (nonatomic) float loyaltyHold;
@property (strong, nonatomic) NSString *loyaltyImage;
@property (nonatomic) BOOL isNotification;
@property (nonatomic) BOOL expireNotification;
@property (strong, nonatomic) NSString *earningLabel;
@property (strong, nonatomic) NSString *earningPolicy;
@property (strong, nonatomic) NSString *spendingLabel;
@property (strong, nonatomic) NSString *spendingPolicy;
@property (strong, nonatomic) NSString *spendingPoint;
@property (strong, nonatomic) NSString *spendingDiscount;
@property (nonatomic) int startDiscount;
@property (nonatomic) int spendingMin;
@property (strong, nonatomic) NSArray *policies;
- (void)loadProgramOverview;

- (void)saveSettings;

@end
