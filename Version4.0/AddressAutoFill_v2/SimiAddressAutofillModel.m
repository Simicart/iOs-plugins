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
    notificationName = @"DidGetAddress";
    self.parseKey = @"address";
    [self preDoRequest];
    NSString *url = [NSString stringWithFormat:@"%@%@%@",kBaseURL, kSimiConnectorURL, @"addresses/geocoding"];
    [[SimiAPI new] requestWithMethod:GET URL:url params:params target:self selector:@selector(didGetResponseFromNetwork:) header:nil];
}
@end
