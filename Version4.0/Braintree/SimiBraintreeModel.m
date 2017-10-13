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
- (void)sendNonceToServer:(NSString* )nonce andOrder:(SimiOrderModel *)order{
    notificationName = BRAINTREE_SENDNONCETOSERVER;
    NSString* url = [NSString stringWithFormat:@"%@%@", kBaseURL, kBraintreeUpdatePayment];
    NSDecimalNumber* amount = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.02f",[[order.total valueForKey:@"grand_total_incl_tax"] floatValue]]];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:@{@"nonce":nonce,@"order_id":order.invoiceNumber,@"amount":amount}];
    SimiAPI *braintreeAPI = [[SimiAPI alloc] init];
    [braintreeAPI requestWithMethod:POST URL:url params:params target:self selector:@selector(didGetResponseFromNetwork:) header:nil];
}
@end
