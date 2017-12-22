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
    notificationName = DidUpdatePayfortPayment;
    actionType = ModelActionTypeEdit;
    self.parseKey = @"payfortapi";
    self.resource = @"payfortapis/update_payment";
    [self.params addEntriesFromDictionary:@{@"invoice_number":invoiceNumber}];
    self.method = MethodGet;
    [self preDoRequest];
    [self request];
}
@end
