//
//  FirebaseInitWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/24/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "FirebaseInitWorker.h"
#import "Firebase.h"


@implementation FirebaseInitWorker
-(id) init{
    if(self == [super init]){
        //Init Firebase configure
        [FIRApp configure];
        
        //Logging events
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(trackingEvent:) name:TRACKINGEVENT object:nil];
//        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
//        NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
//        NSString *appIdentidier = [info objectForKey:@"CFBundleIdentifier"];
//        [FIRAnalytics setUserPropertyString:version forName:@"App Version"];
//        [FIRAnalytics setUserPropertyString:appIdentidier forName:@"App ID"];
    }
    return self;
}

#pragma mark Logging events and setting user properties
- (void)trackingEvent:(NSNotification*) noti{
    if([noti.object isKindOfClass:[NSString class]])
    {
        NSString *trackingName = noti.object;
        trackingName = [trackingName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSDictionary *params = noti.userInfo;
        NSMutableDictionary *trackingProperties = [NSMutableDictionary new];
        for (int i = 0; i < params.count; i ++) {
            NSString *key = [params.allKeys objectAtIndex:i];
            key = [key stringByReplacingOccurrencesOfString:@" " withString:@"_"];
            NSString *value = [params.allValues objectAtIndex:i];
            [trackingProperties setValue:value forKey:key];
        }
        [FIRAnalytics logEventWithName:trackingName
                            parameters:trackingProperties];
    }
}
@end
