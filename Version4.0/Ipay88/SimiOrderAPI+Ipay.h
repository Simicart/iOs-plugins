//
//  SimiOrderAPI+Ipay.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/28/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiOrderAPI.h>

@interface SimiOrderAPI (Ipay)

- (void)updateIpayOrderWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

@end
