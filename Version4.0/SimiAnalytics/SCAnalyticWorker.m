//
//  SCAnalyticWorker.m
//  SimiCartPluginFW
//
//  Created by Liam on 6/25/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCAnalyticWorker.h"
#import <sys/utsname.h>
#import "SimiAnalyticModel.h"

NSString* deviceName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

@implementation SCAnalyticWorker
- (instancetype)init{
    self = [super init];
    section_id = @"123456789";
    [self generateCommonData];
    [self generateCommonProperties];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(trackingEvent:) name:SIMI_TRACKINGEVENT object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(trackingViewedScreen:) name:@"SimiViewControllerViewDidAppear" object:nil];
    return self;
}

- (void)trackingEvent:(NSNotification*)noti{
    NSString *trackingName = noti.object;
    NSDictionary *properties = noti.userInfo;
    if (properties == nil) {
        properties = @{};
    }
    NSMutableDictionary *trackingProperties = [[NSMutableDictionary alloc]initWithDictionary:properties];
    [trackingProperties addEntriesFromDictionary:commonProperties];
    NSMutableDictionary *trackingParams = [[NSMutableDictionary alloc]initWithDictionary:commonData];
    [trackingParams setValue:trackingName forKey:@"event_key"];
    if (GLOBALVAR.isLogin) {
        [trackingParams setValue:GLOBALVAR.customer.email forKey:@"user_email"];
    }else{
        [trackingParams setValue:@"" forKey:@"user_email"];
    }
    if (trackingProperties != nil) {
        [trackingParams setValue:trackingProperties forKey:@"properties"];
    }
    SimiAnalyticModel *analyticModel = [SimiAnalyticModel new];
    [analyticModel simiTrackingWithParams:trackingParams];
}

- (void)generateCommonData{
    NSString *deviceType = @"0";
    if (PADDEVICE) {
        deviceType = @"2";
    }
    NSString *appToken = GLOBALVAR.deviceToken;
    if (appToken == nil) {
        appToken = @"";
    }
    NSString *timeStamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    NSString *sessionId = [NSString stringWithFormat:@"%@%@%@",kCloudSimiKey,appToken,timeStamp];
    commonData = [[NSMutableDictionary alloc]initWithDictionary:@{@"device_type":deviceType,@"bear_token":kCloudSimiKey,@"app_token":appToken,@"session_id":sessionId}];
}

- (void)generateCommonProperties{
    commonProperties = [NSMutableDictionary new];
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    NSString *appIdentidier = [info objectForKey:@"CFBundleIdentifier"];
    [commonProperties setValue:version forKey:@"app_version"];
    [commonProperties setValue:appIdentidier forKey:@"app_id"];
    if ([GLOBALVAR.storeView.base valueForKey:@"customer_ip"]) {
        NSString *customerIp = [NSString stringWithFormat:@"%@",[GLOBALVAR.storeView.base valueForKey:@"customer_ip"]];
        if (![customerIp isEqualToString:@""] && ![[GLOBALVAR.storeView.base valueForKey:@"customer_ip"] isKindOfClass:[NSNull class]]) {
            [commonProperties setValue:customerIp forKey:@"customer_ip"];
        }
    }
    [commonProperties setValue:[[UIDevice currentDevice] systemVersion] forKey:@"os_version"];
    [commonProperties setValue:@"Apple" forKey:@"manufacture"];
    [commonProperties setValue:@"iOS" forKey:@"os"];
    [commonProperties setValue:deviceName() forKey:@"model"];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == ReachableViaWiFi){
        [commonProperties setValue:@"YES" forKey:@"wifi"];
    }else{
        [commonProperties setValue:@"NO" forKey:@"wifi"];
    }
}
@end
