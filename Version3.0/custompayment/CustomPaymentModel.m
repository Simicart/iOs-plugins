//
//  CustomPaymentModel.m
//  SimiCartPluginFW
//
//  Created by Axe on 1/25/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "CustomPaymentModel.h"



@implementation CustomPaymentModel
-(void) cancelPaymentWithOrderID:(NSString* )orderID{
    currentNotificationName = DidCancelPayment;
    NSString* url = [NSString stringWithFormat:@"%@%@",kBaseURL, kSimiCancelPayment];
    [[self getAPI] requestWithURL:url params:@{@"order_id":orderID} target:self selector:@selector(didFinishRequest:responder:) header:nil];
}

@end
