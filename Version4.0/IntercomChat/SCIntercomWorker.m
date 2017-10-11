//
//  SCIntercomWorker.m
//  SimiCartPluginFW
//
//  Created by Liam on 12/21/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCIntercomWorker.h"
#import <Intercom/Intercom.h>
@implementation SCIntercomWorker

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *intercomAppID = @"";
        NSString *intercomiOsKey = @"";
        
        if ([[GLOBALVAR.storeView valueForKey:@"intercom_chat"] valueForKey:@"intercom_app_id"]){
            intercomAppID = [NSString stringWithFormat:@"%@",[[GLOBALVAR.storeView valueForKey:@"intercom_chat"] valueForKey:@"intercom_app_id"]];
        }
        if ([[GLOBALVAR.storeView valueForKey:@"intercom_chat"] valueForKey:@"intercom_ios_app_key"]) {
            intercomiOsKey = [NSString stringWithFormat:@"%@",[[GLOBALVAR.storeView valueForKey:@"intercom_chat"] valueForKey:@"intercom_ios_app_key"]];
        }
        if (![intercomiOsKey isEqualToString:@""] && ![intercomAppID isEqualToString:@""]) {
            [Intercom setApiKey:intercomiOsKey forAppId:intercomAppID];
            [Intercom setLauncherVisible:YES];
            [Intercom registerUnidentifiedUser];
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
