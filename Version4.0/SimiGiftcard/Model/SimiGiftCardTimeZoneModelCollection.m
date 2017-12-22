//
//  SimiGiftCardTimeZoneModelCollection.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/11/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiGiftCardTimeZoneModelCollection.h"

@implementation SimiGiftCardTimeZoneModelCollection
- (void)getGiftCardTimeZoneWithParams:(NSDictionary *)params{
    notificationName = DidGetSimiTimeZone;
    self.parseKey = @"timezones";
    self.resource = @"simitimezones";
    if (params.count > 0) {
        [self.params addEntriesFromDictionary:params];
    }
    self.method = MethodGet;
    [self preDoRequest];
    [self request];
}
@end
