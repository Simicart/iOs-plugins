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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:@"DidLogin" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:@"ApplicationDidFinishLaunching" object:nil];
        [FIRApp configure];
    }
    return self;
}

-(void) didLogin: (NSNotification*) noti{
    SimiResponder* responder = [noti.userInfo objectForKey:@"responder"];
    [FIRAnalytics logEventWithName:@"DidLogin" parameters:@{@"state":[responder.status isEqualToString:@"SUCCESS"]?@1:@0}];
}

-(void) applicationDidFinishLaunching: (NSNotification* )noti{
}

@end
