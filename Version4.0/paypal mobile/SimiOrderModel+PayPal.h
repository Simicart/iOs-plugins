//
//  SimiOrderModel+PayPal.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/28/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiOrderModel.h>

static NSString *const Simi_DidSavePaypalPayment =  @"Simi_DidSavePaypalPayment";

@interface SimiOrderModel (PayPal)
- (void)savePaymentWithStatus:(NSString*) paymentStatus invoiceNumber:(NSString*) invoiceNumber proof:(NSDictionary*) proof;
@end
