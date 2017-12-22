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
    self.parseKey = @"deeplink";
    notificationName = DidGetDeeplinkInformation;
    self.resource = @"deeplinks";
    [self addParamsWithKey:@"url" value:deeplinkURL];
    self.method = MethodGet;
    [self preDoRequest];
    [self request];
}
@end
