//
//  KlarnaModelCollection.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "KlarnaModelCollection.h"

@implementation KlarnaModelCollection
- (void)getParamsKlarnaWithParams:(NSDictionary *)params
{
    currentNotificationName = @"DidGetKlarnaParam";
    modelActionType = ModelActionTypeGet;
    [(KlarnaAPI *)[self getAPI] getParamsKlarnaWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)checkoutKlarnaWithParams:(NSDictionary *)params
{
    currentNotificationName = @"DidCheckOutKlarna";
    modelActionType = ModelActionTypeGet;
    [(KlarnaAPI *)[self getAPI] checkoutKlarnaWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}
@end
