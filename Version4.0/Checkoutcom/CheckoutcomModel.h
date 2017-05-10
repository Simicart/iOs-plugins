//
//  CheckoutcomModel.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 11/10/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

#define DidUpdateCheckoutComPayment @"DidUpdateCheckoutComPayment"

@interface CheckoutcomModel : SimiModel

-(void) completeOrderWithParams:(NSDictionary*) params;

@end
