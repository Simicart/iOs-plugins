//
//  SimiGiftCardTimeZoneModelCollection.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/11/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiGiftCardTimeZoneModelCollection.h"
#import "SimiGiftCardTimeZoneAPI.h"

@implementation SimiGiftCardTimeZoneModelCollection
- (void)getGiftCardTimeZoneWithParams:(NSDictionary *)params{
    currentNotificationName = DidGetSimiTimeZone;
    keyResponse = @"timezones";
    [self preDoRequest];
    [[SimiGiftCardTimeZoneAPI new] getGiftCardTimeZoneWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}
@end
