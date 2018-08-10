//
//  SCDeeplinkModel.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/8/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCDeeplinkModel.h"


@implementation SCDeeplinkModel
- (void)getDeeplinkInformation:(NSString *)deeplinkURL {
    currentNotificationName = DidGetDeeplinkInformation;
    keyResponse = @"deeplink";
    [self preDoRequest];
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL, @"deeplinks"];
    [[SimiAPI new] requestWithMethod:GET URL:urlPath params:@{@"url":deeplinkURL} target:self selector:@selector(didFinishRequest:responder:) header:nil];
}

@end
