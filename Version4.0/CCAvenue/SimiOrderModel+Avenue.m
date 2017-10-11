//
//  SimiOrderAPI+Avenue.m
//  SimiCartPluginFW
//
//  Created by biga on 11/7/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiOrderModel+Avenue.h"
#import "SimiOrderAPI+Avenue.h"

@implementation SimiOrderModel (Avenue)

- (void)updateAvenueOrderWithParams:(NSDictionary *)params{
    actionType = ModelActionTypeGet;
    self.parseKey = @"twoutapi";
    notificationName = @"DidUpdateAvenuePayment";
    [self preDoRequest];
    [[SimiOrderAPI new] updateAvenueOrderWithParams:params target:self selector:@selector(didGetResponseFromNetwork:)];
}

@end
