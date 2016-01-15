//
//  CustomPaymentAPI.h
//  SimiCartPluginFW
//
//  Created by Axe on 10/21/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

//NSString* kSimiGetCustomPayments = @"simicustompayment/api/get_custom_payments";

@interface CustomPaymentAPI : SimiAPI
- (void)getCustomPaymentsWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
