//
//  SCMixpabelWorker.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/23/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCMixpabelWorker.h"
#import "Mixpanel.h"
#import <SimiCartBundle/SCCategoryViewController.h>
#import <SimiCartBundle/SCProductListViewController.h>

#define SIMI_MIXPANEL_TOKEN @"56ac1bab6cde3e1e795cd8772151bbc5"

@implementation SCMixpabelWorker
{
    Mixpanel *mixpanel;
    NSString *ownerEmail;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *token = @"";
        if ([[[SimiGlobalVar sharedInstance].allConfig valueForKey:@"mixpanel_config"]isKindOfClass:[NSDictionary class]]){
            NSDictionary *mixPanelConfig = [[SimiGlobalVar sharedInstance].allConfig valueForKey:@"mixpanel_config"];
            if ([mixPanelConfig valueForKey:@"token"] && ![[mixPanelConfig valueForKey:@"token"] isKindOfClass:[NSNull class]]) {
                token = [NSString stringWithFormat:@"%@",[mixPanelConfig valueForKey:@"token"]];
            }
        }
        if(DEMO_MODE && [token isEqualToString:@""]) {
            token = SIMI_MIXPANEL_TOKEN;
        }
        if (![token isEqualToString:@""]) {
            [Mixpanel sharedInstanceWithToken:token];
        }else {
            return self;
        }
        mixpanel = [Mixpanel sharedInstance];
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
        NSString *appIdentidier = [info objectForKey:@"CFBundleIdentifier"];
        [mixpanel registerSuperProperties:@{@"app_version":version, @"app_id":appIdentidier}];
        if ([[SimiGlobalVar sharedInstance].baseConfig valueForKey:@"customer_ip"]) {
            NSString *customerIp = [NSString stringWithFormat:@"%@",[[SimiGlobalVar sharedInstance].baseConfig valueForKey:@"customer_ip"]];
            if (![customerIp isEqualToString:@""] && ![[[SimiGlobalVar sharedInstance].baseConfig valueForKey:@"customer_ip"] isKindOfClass:[NSNull class]]) {
                [mixpanel registerSuperProperties:@{@"customer_ip":customerIp}];
            }
        }
        
        if(DEMO_MODE && [token isEqualToString:SIMI_MIXPANEL_TOKEN]) {
            if([[SimiGlobalVar sharedInstance].appConfigure objectForKey:@"email"]) {
                ownerEmail = [NSString stringWithFormat:@"%@", [[SimiGlobalVar sharedInstance].appConfigure objectForKey:@"email"]];
            }else {
                ownerEmail = kCloudSimiKey;
            }
        }
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(trackingEvent:) name:TRACKINGEVENT object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(trackingViewedScreen:) name:@"SimiViewControllerViewDidAppear" object:nil];
    }
    return self;
}

- (void)trackingEvent:(NSNotification*)noti
{
    if ([noti.object isKindOfClass:[NSString class]]) {
        NSString *trackingName = noti.object;
        NSDictionary *properties = noti.userInfo;
        if (properties == nil) {
            properties = @{};
        }
        NSMutableDictionary *trackingProperties = [[NSMutableDictionary alloc]initWithDictionary:properties];
        if(ownerEmail && ![ownerEmail isEqualToString:@""]) {
            [trackingProperties addEntriesFromDictionary:@{@"owner_email":ownerEmail}];
        }
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
        [mixpanel track:trackingName properties:trackingProperties];
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
        if(ownerEmail && ![ownerEmail isEqualToString:@""]) {
            [trackingProperties addEntriesFromDictionary:@{@"owner_email":ownerEmail}];
        }
        [mixpanel track:@"page_view_action" properties:trackingProperties];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
