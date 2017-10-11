//
//  CustomPaymentModelCollection.m
//  SimiCartPluginFW
//
//  Created by Axe on 10/19/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "CustomPaymentModelCollection.h"

@implementation CustomPaymentModelCollection

- (void)getCustomPaymentsWithParams: (NSDictionary*) params{
    notificationName = DidGetCustomPayments;
    self.parseKey = @"customizepayments";
    [[CustomPaymentAPI new] getCustomPaymentsWithParams:params target:self selector:@selector(didGetResponseFromNetwork:)];
}
@end
