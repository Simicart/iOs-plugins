//
//  SimiBraintreeModel.m
//  SimiCartPluginFW
//
//  Created by Axe on 12/30/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "SimiBraintreeModel.h"

NSString* const kBraintreeUpdatePayment = @"simiconnector/rest/v2/braintreeapis";

@implementation SimiBraintreeModel
-(void) sendNonceToServer:(NSString* )nonce andOrder:(SimiOrderModel *)order_{
    currentNotificationName = BRAINTREE_SENDNONCETOSERVER;
    SimiAPI *braintreeAPI = [[SimiAPI alloc] init];
    NSString* url = [NSString stringWithFormat:@"%@%@", kBaseURL, kBraintreeUpdatePayment];
    SimiOrderModel* order = [order_ copy];
    NSDecimalNumber* amount = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.02f",[[[order objectForKey:@"total"] valueForKey:@"grand_total_incl_tax"] floatValue]]];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:@{@"nonce":nonce,@"order_id":[order valueForKey:@"invoice_number"],@"amount":amount}];
    [braintreeAPI requestWithMethod:POST URL:url params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
@end
