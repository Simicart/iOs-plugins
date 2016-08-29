//
//  SimiOrderAPI+Checkoutcom.h
//  SimiCartPluginFW
//
//  Created by biga on 11/7/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimiCartBundle/SimiOrderAPI.h>

@interface SimiOrderAPI (Checkoutcom)

- (void)updateCheckoutcomOrderWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

@end
