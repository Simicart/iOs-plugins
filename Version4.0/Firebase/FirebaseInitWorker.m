//
//  FirebaseInitWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/24/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "FirebaseInitWorker.h"
#import "Firebase.h"

#define kGCMMessageIDKey @"gcm.message_id"
#define CUSTOM_URL_SCHEME @"com.simicart.core40"

@implementation FirebaseInitWorker
-(id) init{
    if(self == [super init]){
        //Init Firebase configure
        [FIRApp configure];
        
        //Dynamic Links
        [FIROptions defaultOptions].deepLinkURLScheme = CUSTOM_URL_SCHEME;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationOpenURL:) name:@"ApplicationOpenURL" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continueUserActivity:) name:@"ContinueUserActivity" object:nil];
        
        //Logging events
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(trackingEvent:) name:TRACKINGEVENT object:nil];
//        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
//        NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
//        NSString *appIdentidier = [info objectForKey:@"CFBundleIdentifier"];
//        [FIRAnalytics setUserPropertyString:version forName:@"App Version"];
//        [FIRAnalytics setUserPropertyString:appIdentidier forName:@"App ID"];
        
        //Pushing notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveRemoteNotification:) name:@"ApplicationDidReceiveNotificationFromServer" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)
                                                     name:kFIRInstanceIDTokenRefreshNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:@"ApplicationDidEnterBackground" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:@"ApplicationDidBecomeActive" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidRegisterForRemote:) name:@"ApplicationDidRegisterForRemote" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFailToRegisterForRemote:) name:@"ApplicationDidFailToRegisterForRemote" object:nil];
        
    }
    return self;
}

#pragma mark Dynamic Links
-(void) applicationOpenURL:(NSNotification*) noti{
    NSURL* url = [noti.userInfo objectForKey:@"url"];
    NSNumber* number = noti.object;
    FIRDynamicLink *dynamicLink = [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
    
    if (dynamicLink) {
        // Handle the deep link. For example, show the deep-linked content or
        // apply a promotional offer to the user's account.
        // ...
        number = [NSNumber numberWithBool:YES];
    }else{
        number = [NSNumber numberWithBool:NO];
    }
}

-(void) continueUserActivity:(NSNotification*) noti{
    NSUserActivity* userActivity = [noti.userInfo objectForKey:@"userActivity"];
    NSNumber* handledNumber = [noti.userInfo objectForKey:@"handled"];
    BOOL handled = [[FIRDynamicLinks dynamicLinks] handleUniversalLink:userActivity.webpageURL
                    completion:^(FIRDynamicLink * _Nullable dynamicLink,
                                 NSError * _Nullable error) {
                        // ...
                    }];
    handledNumber = [NSNumber numberWithBool:handled];
}

#pragma mark Logging events and setting user properties
-(void)trackingEvent:(NSNotification*) noti{
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

#pragma mark Pushing notifications recieving
-(void) didRecieveRemoteNotification: (NSNotification*) noti{
    // Print message ID.
    //if ([noti.userInfo objectForKey:kGCMMessageIDKey]) {
        NSLog(@"%@", noti.userInfo);
    //}
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Message ID: %@", noti.userInfo] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    
    // Print full message.
    NSLog(@"%@", noti.userInfo);
//    [self connectToFcm];
}


// [START refresh_token]
- (void)tokenRefreshNotification:(NSNotification *)notification {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    
    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFcm];
    
    // TODO: If necessary send token to application server.
}
// [END refresh_token]


-(void) applicationDidEnterBackground:(NSNotification*) noti{
    [[FIRMessaging messaging] disconnect];
    NSLog(@"Disconnected from FCM");
}

// [START connect_to_fcm]
- (void)connectToFcm {
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
        }
    }];
}
// [END connect_to_fcm]


- (void)applicationDidBecomeActive:(NSNotification *)noti {
    [self connectToFcm];
}

// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
// If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
// the InstanceID token.
-(void) applicationDidRegisterForRemote:(NSNotification*) noti{
    // With swizzling disabled you must set the APNs token here.
//     [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeSandbox];
}


- (void)applicationDidFailToRegisterForRemote:(NSNotification*) noti{
    NSError* error = [noti.userInfo objectForKey:@"error"];
    NSLog(@"Unable to register for remote notifications: %@", error);
}

@end
