//
//  SimiOrderAPI+Avenue.h
//  SimiCartPluginFW
//
//  Created by biga on 11/7/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimiCartBundle/SimiOrderModel.h>
static NSString *const CCAvenue_DidUpdateAvenuePayment = @"CCAvenue_DidUpdateAvenuePayment";

@interface SimiOrderModel (Avenue)
- (void)updateAvenueOrderWithParams:(NSDictionary *)params;
@end
