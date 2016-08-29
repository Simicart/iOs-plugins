//
//  CustomPaymentModelCollection.h
//  SimiCartPluginFW
//
//  Created by Axe on 10/19/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "CustomPaymentAPI.h"

@interface CustomPaymentModelCollection : SimiModelCollection
-(void) getCustomPaymentsWithParams:(NSDictionary*) params;
@end

#define kSimiCancelPayment @"connector/checkout/cancel_order/"
#define DidCancelPayment @"DidCancelPayment"


//inner class because conflict to server source files for customization
@interface CustomPaymentModel : SimiModel
-(void) cancelPaymentWithOrderID:(NSString* )orderID;
@end