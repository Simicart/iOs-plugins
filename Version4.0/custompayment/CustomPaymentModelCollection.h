//
//  CustomPaymentModelCollection.h
//  SimiCartPluginFW
//
//  Created by Axe on 10/19/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//
#import "CustomPaymentAPI.h"

#define DidGetCustomPayments @"DidGetCustomPayments"

@interface CustomPaymentModelCollection : SimiModelCollection
-(void) getCustomPaymentsWithParams:(NSDictionary*) params;
@end
