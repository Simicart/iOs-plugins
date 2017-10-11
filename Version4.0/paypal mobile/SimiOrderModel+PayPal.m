//
//  SimiOrderModel+PayPal.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/28/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiOrderModel+PayPal.h"

#define kSavePaymentURL @"simiconnector/rest/v2/paypalmobiles"

@implementation SimiOrderModel (PayPal)
- (void)savePaymentWithStatus:(NSString *)paymentStatus invoiceNumber:(NSString *)invoiceNumber proof:(NSDictionary *)proof{
    notificationName = Simi_DidSavePaypalPayment;
    self.parseKey = @"paypalmobile";
    if(!proof){
        proof = @{};
    }
    NSString* url = [NSString stringWithFormat:@"%@%@",kBaseURL,kSavePaymentURL];
    [[SimiAPI new] requestWithMethod:POST URL:url params:@{@"payment_status":paymentStatus,@"invoice_number":invoiceNumber,@"proof":proof} target:self selector:@selector(didGetResponseFromNetwork:) header:nil];
}

@end
