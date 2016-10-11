//
//  SimiAddressAutofillModel.m
//  SimiCartPluginFW
//
//  Created by Liam on 9/8/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SimiAddressAutofillModel.h"

@implementation SimiAddressAutofillModel
- (void)getAddressWithParams:(NSDictionary*)params{
    currentNotificationName = @"DidGetAddress";
    keyResponse = @"address";
    [self preDoRequest];
    NSString *url = [NSString stringWithFormat:@"%@%@%@",kBaseURL, kSimiConnectorURL, @"addresses/geocoding"];
    [[self getAPI] requestWithMethod:GET URL:url params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
@end
