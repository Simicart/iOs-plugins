//
//  SimiHomeModel+SCP.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 5/9/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SimiHomeModel+SCP.h"

@implementation SimiHomeModel (SCP)
- (void)getHomeDataWithParams:(NSDictionary *)params{
    notificationName = Simi_DidGetHomeData;
    self.resource = @"homes";
    self.parseKey = @"home";
    [self.params addEntriesFromDictionary:params];
    self.method = MethodGet;
    [self request];
}
@end
