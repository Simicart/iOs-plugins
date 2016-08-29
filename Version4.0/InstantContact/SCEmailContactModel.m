//
//  SCEmailContactModel.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 10/24/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCEmailContactModel.h"
#import "SCEmailContactAPI.h"
@implementation SCEmailContactModel
- (void)getEmailContactWithParams:(NSDictionary*)dict
{
    currentNotificationName = @"DidGetEmailContactConfig";
    modelActionType = ModelActionTypeGet;
    [(SCEmailContactAPI *)[self getAPI] getEmailContactWithParams:dict target:self selector:@selector(didFinishRequest:responder:)];
}
@end
