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
    [self preDoRequest];
    NSString *url = [NSString stringWithFormat:@"%@%@deeplinks?url=%@", kBaseURL, kSimiConnectorURL,deeplinkURL];
    [[SimiAPI new] requestWithMethod:GET URL:url params:@{} target:self selector:@selector(didGetResponseFromNetwork:) header:nil];
}
@end
