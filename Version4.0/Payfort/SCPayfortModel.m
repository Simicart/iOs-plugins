//
//  SCPayfortModel.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 7/24/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCPayfortModel.h"

@implementation SCPayfortModel
- (void)updateOrderWithInvoiceNumber: (NSString *)invoiceNumber {
    currentNotificationName = DidUpdatePayfortPayment;
    keyResponse = @"payfortapi";
    [self preDoRequest];
    [[SimiAPI new] requestWithMethod:GET URL:[NSString stringWithFormat:@"%@simiconnector/rest/v2/payfortapis/update_payment",kBaseURL] params:@{@"invoice_number":invoiceNumber} target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
@end
