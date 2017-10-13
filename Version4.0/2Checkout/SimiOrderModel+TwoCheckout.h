//
//  SimiOrderModel+TwoCheckout.h
//  SimiCartPluginFW
//
//  Created by biga on 11/7/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimiCartBundle/SimiOrderModel.h>
static NSString *const TwoutCheckOut_DidUpdate2CheckoutPayment = @"DidUpdate2CheckoutPayment";
@interface SimiOrderModel (TwoCheckout)

- (void)updateTwoutOrderWithParams:(NSDictionary *)params;

@end
