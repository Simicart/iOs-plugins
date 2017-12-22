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
    self.resource = @"addresses/geocoding";
    if (params.count > 0) {
        [self.params addEntriesFromDictionary:params];
    }
    self.method = MethodGet;
    [self preDoRequest];
    [self request];
}
@end
