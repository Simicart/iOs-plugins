//
//  SimiCMSPageModel.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/4/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiCMSPageModel.h"

@implementation SimiCMSPageModel

- (void)getCMSPageWithID:(NSString *)cmsID{
    currentNotificationName = @"Simi_DidGetCMSPage";
    keyResponse = @"cmspage";
    [self preDoRequest];
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@/%@", kBaseURL, kSimiConnectorURL, @"cmspages", cmsID];
    [[SimiAPI new] requestWithMethod:GET URL:urlPath params:@{} target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
@end
