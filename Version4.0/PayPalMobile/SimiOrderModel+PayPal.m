//
//  SimiOrderModel+PayPal.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/28/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiOrderModel+PayPal.h"
#import "SimiOrderAPI+PayPal.h"

@implementation SimiOrderModel (PayPal)

- (void)updateOrderWithPaymentStatus:(PaymentStatus)paymentStatus proof:(NSDictionary *)proof{
    currentNotificationName = @"DidUpdatePaymentStatus";
    if (proof == nil) {
        proof = @{};
    }
    [(SimiOrderAPI *)[self getAPI] updateOrderWithParams:@{@"invoice_number": [self valueForKey:@"invoice_number"], @"payment_status": [NSString stringWithFormat:@"%ld", (long)paymentStatus], @"proof": proof} target:self selector:@selector(didFinishRequest:responder:)];
}

@end
