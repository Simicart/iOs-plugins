//
//  SCPayfortModel.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 7/24/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#define DidUpdatePayfortPayment @"DidUpdatePayfortPayment"

@interface SCPayfortModel : SimiModel
- (void)updateOrderWithInvoiceNumber: (NSString *)invoiceNumber;
@end
