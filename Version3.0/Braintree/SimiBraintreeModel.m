//
//  SimiBraintreeModel.m
//  SimiCartPluginFW
//
//  Created by Axe on 12/30/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "SimiBraintreeModel.h"

NSString* const kBraintreeUpdatePayment = @"simibraintree/index/update_payment";

@implementation SimiBraintreeModel
-(void) sendNonceToServer:(NSString* )nonce andOrder:(SimiOrderModel *)order_{
    currentNotificationName = @"BRAINTREE-SENDNONCETOSERVER";
    SimiAPI *braintreeAPI = [[SimiAPI alloc] init];
    NSString* url = [NSString stringWithFormat:@"%@%@", kBaseURL, kBraintreeUpdatePayment];
    SimiOrderModel* order = [order_ copy];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:@{@"nonce":nonce,@"order_id":[order valueForKey:@"invoice_number"],@"amount":[[order valueForKey:@"fee"] valueForKey:@"grand_total"]}];
    [braintreeAPI requestWithURL:url params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
@end
