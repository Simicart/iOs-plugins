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
        if (![SimiGlobalVar sharedInstance].isFirebaseInited) {
            //Init Firebase configure
            [FIRApp configure];
            [SimiGlobalVar sharedInstance].isFirebaseInited = YES;
        }
        //Logging events
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(trackingEvent:) name:TRACKINGEVENT object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(trackingViewedScreen:) name:@"SimiViewControllerViewDidAppear" object:nil];
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
        NSString *appIdentidier = [info objectForKey:@"CFBundleIdentifier"];
        [FIRAnalytics setUserPropertyString:version forName:@"app_version"];
        [FIRAnalytics setUserPropertyString:appIdentidier forName:@"app_id"];
        if ([[SimiGlobalVar sharedInstance].baseConfig valueForKey:@"customer_ip"]) {
            NSString *customerIp = [NSString stringWithFormat:@"%@",[[SimiGlobalVar sharedInstance].baseConfig valueForKey:@"customer_ip"]];
            if (![customerIp isEqualToString:@""] && ![[[SimiGlobalVar sharedInstance].baseConfig valueForKey:@"customer_ip"] isKindOfClass:[NSNull class]]) {
                [FIRAnalytics setUserPropertyString:customerIp forName:@"customer_ip"];
            }
        }
    }
    return self;
}

#pragma mark Logging events and setting user properties
- (void)trackingEvent:(NSNotification*) noti{
    if([noti.object isKindOfClass:[NSString class]])
    {
        NSString *trackingName = noti.object;
        NSDictionary *params = noti.userInfo;
        if (params == nil) {
            params = @{};
        }
        NSMutableDictionary *trackingProperties = [[NSMutableDictionary alloc]initWithDictionary:params];
        if ([SimiGlobalVar sharedInstance].isLogin) {
            [trackingProperties setValue:[[SimiGlobalVar sharedInstance].customer valueForKey:@"email"]  forKey:@"customer_identity"];
        }else
        {
            if ([[SimiGlobalVar sharedInstance].baseConfig valueForKey:@"customer_identity"]) {
                NSString *customerIdentity = [NSString stringWithFormat:@"%@",[[SimiGlobalVar sharedInstance].baseConfig valueForKey:@"customer_identity"]];
                if (![customerIdentity isEqualToString:@""] && ![[[SimiGlobalVar sharedInstance].baseConfig valueForKey:@"customer_identity"] isKindOfClass:[NSNull class]]) {
                    [trackingProperties setValue:customerIdentity  forKey:@"customer_identity"];
                }
            }
        }
        [FIRAnalytics logEventWithName:trackingName
                            parameters:trackingProperties];
    }
}

- (void)trackingViewedScreen:(NSNotification*)noti
{
    SimiViewController *viewController = noti.object;
    if (viewController.screenTrackingName != nil && ![viewController.screenTrackingName isEqualToString:@""]) {
        NSString *actionValue = [NSString stringWithFormat:@"viewed_%@_screen",viewController.screenTrackingName];
        NSMutableDictionary *trackingProperties = [[NSMutableDictionary alloc]initWithDictionary:@{@"action":actionValue}];
        if ([SimiGlobalVar sharedInstance].isLogin) {
            [trackingProperties setValue:[[SimiGlobalVar sharedInstance].customer valueForKey:@"email"]  forKey:@"customer_identity"];
        }else
        {
            if ([[SimiGlobalVar sharedInstance].baseConfig valueForKey:@"customer_identity"]) {
                NSString *customerIdentity = [NSString stringWithFormat:@"%@",[[SimiGlobalVar sharedInstance].baseConfig valueForKey:@"customer_identity"]];
                if (![customerIdentity isEqualToString:@""] && ![[[SimiGlobalVar sharedInstance].baseConfig valueForKey:@"customer_identity"] isKindOfClass:[NSNull class]]) {
                    [trackingProperties setValue:customerIdentity  forKey:@"customer_identity"];
                }
            }
        }
        [FIRAnalytics logEventWithName:@"page_view_action"
                            parameters:trackingProperties];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
