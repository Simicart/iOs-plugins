//
//  SimiBraintreeModel.m
//  SimiCartPluginFW
//
//  Created by Axe on 12/30/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "SimiBraintreeModel.h"

@implementation SimiBraintreeModel
- (void)sendNonceToServer:(NSString* )nonce andOrder:(SimiOrderModel *)order{
    notificationName = BRAINTREE_SENDNONCETOSERVER;
    self.parseKey = @"";
    self.resource = @"braintreeapis";
    self.method = MethodPost;
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.02f",[[order.total valueForKey:@"grand_total_incl_tax"] floatValue]]];
    [self.body addEntriesFromDictionary:@{@"nonce":nonce,@"order_id":order.invoiceNumber,@"amount":amount}];
    [self request];
}
@end
