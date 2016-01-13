//
//  SimiMAModel.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 7/23/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiMAModel.h"
#import "SimiMAAPI.h"
@implementation SimiMAModel
- (void)getGoogleAnalyticsIDWithParams:(NSDictionary *)dict
{
    currentNotificationName = @"DidGetGoogleAnalyticsID";
    modelActionType = ModelActionTypeGet;
    [(SimiMAAPI*)[self getAPI] getGoogleAnalyticsIDWithParams:dict target:self selector:@selector(didFinishRequest:responder:)];
}
@end
