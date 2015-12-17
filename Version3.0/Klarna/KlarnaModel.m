//
//  KlarnaModel.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "KlarnaModel.h"

@implementation KlarnaModel
- (void)getParamsKlarnaWithParams:(NSDictionary *)params
{
    currentNotificationName = @"DidGetKlarnaParam";
    [(KlarnaAPI *)[self getAPI] getParamsKlarnaWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}
- (void)checkoutKlarnaWithParams:(NSDictionary *)params
{
    currentNotificationName = @"DidCheckoutWithKlarna";
    [(KlarnaAPI *)[self getAPI] checkoutKlarnaWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}
@end
