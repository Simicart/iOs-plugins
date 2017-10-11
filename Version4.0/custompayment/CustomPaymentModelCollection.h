//
//  CustomPaymentModelCollection.h
//  SimiCartPluginFW
//
//  Created by Axe on 10/19/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//
#import "CustomPaymentAPI.h"

static NSString *const Custompayment_DidGetCustomPayments = @"Custompayment_DidGetCustomPayments";

@interface CustomPaymentModelCollection : SimiModelCollection
- (void)getCustomPaymentsWithParams:(NSDictionary*)params;
@end
