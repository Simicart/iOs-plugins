//
//  SimiOrderModel+Ipay.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/28/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiOrderModel+Ipay.h"
#import "SimiOrderAPI+Ipay.h"

@implementation SimiOrderModel (Ipay)

- (void)updateIpayOrderWithParams:(NSMutableDictionary *)params{
    modelActionType = ModelActionTypeGet;
    currentNotificationName = @"DidUpdateIpayPayment";
    [self preDoRequest];
    [(SimiOrderAPI *)[self getAPI] updateIpayOrderWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

@end
