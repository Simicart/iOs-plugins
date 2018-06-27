//
//  SimiAnalyticModel.m
//  SimiCartPluginFW
//
//  Created by Liam on 6/25/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SimiAnalyticModel.h"

@implementation SimiAnalyticModel
- (void)simiTrackingWithParams:(NSDictionary*)params{
    notificationName = @"DidCompleteTracking";
    self.url = @"http://35.226.182.169/simicart/index.php/appanalytics/rest/v2/track";
    self.method = MethodPost;
    self.body = [[NSMutableDictionary alloc]initWithDictionary:params];
    [self requestWithMethod:self.method URL:self.url params:nil body:self.body header:nil];
}
@end
