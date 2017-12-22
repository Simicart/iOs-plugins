//
//  SimiOrderAPI+Avenue.m
//  SimiCartPluginFW
//
//  Created by biga on 11/7/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiOrderModel+Avenue.h"

@implementation SimiOrderModel (Avenue)

- (void)updateAvenueOrderWithParams:(NSDictionary *)params{
    self.parseKey = @"twoutapi";
    notificationName = CCAvenue_DidUpdateAvenuePayment;
    self.resource = @"twoutapis/update_order";
    if (params.count > 0) {
        [self.body addEntriesFromDictionary:params];
    }
    self.method = MethodPut;
    [self preDoRequest];
    [self request];
}
@end
