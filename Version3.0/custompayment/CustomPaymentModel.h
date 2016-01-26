//
//  CustomPaymentModel.h
//  SimiCartPluginFW
//
//  Created by Axe on 1/25/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "CustomPaymentAPI.h"

#define kSimiCancelPayment @"connector/checkout/cancel_order/"
#define DidCancelPayment @"DidCancelPayment"

@interface CustomPaymentModel : SimiModel
-(void) cancelPaymentWithOrderID:(NSString* )orderID;
@end
