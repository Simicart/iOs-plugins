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
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    formatter.numberStyle = NSNumberFormatterDecimalStyle;
//    formatter.maximumFractionDigits = 2;
//    NSNumber* amount = [formatter numberFromString: [NSString stringWithFormat:@"%@",[[order objectForKey:@"fee"] valueForKey:@"grand_total"]]];
    
    NSDecimalNumber* amount = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.02f",[[[order objectForKey:@"fee"] valueForKey:@"grand_total"] floatValue]]];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:@{@"nonce":nonce,@"order_id":[order valueForKey:@"invoice_number"],@"amount":amount}];
    [braintreeAPI requestWithURL:url params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
@end
