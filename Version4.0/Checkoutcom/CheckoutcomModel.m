//
//  CheckoutcomModel.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 11/10/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "CheckoutcomModel.h"

@implementation CheckoutcomModel
-(void) completeOrderWithParams:(NSDictionary *)params{
    currentNotificationName = DidUpdateCheckoutComPayment;
    keyResponse = @"checkoutcomapi";
    [self preDoRequest];
    [[SimiAPI new] requestWithMethod:GET URL:[NSString stringWithFormat:@"%@simiconnector/rest/v2/checkoutcomapis/update_payment",kBaseURL] params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
@end
