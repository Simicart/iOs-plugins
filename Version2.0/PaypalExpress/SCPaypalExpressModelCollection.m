//
//  SCPaypalExpressModelCollection.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/22/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SCPaypalExpressModelCollection.h"

@implementation SCPaypalExpressModelCollection

- (void)updateAddressWithParam:(NSDictionary *)params{
    modelActionType = ModelActionTypeGet;
    currentNotificationName = @"DidUpdatePaypalCheckoutAddress";
    [self preDoRequest];
    [(SCPaypalExpressAPI *)[self getPaypalExpressAPI] updateAddressWithParam:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)getShippingMethods
{
    currentNotificationName = @"DidGetPaypalCheckoutShippingMethods";
    [self preDoRequest];
    modelActionType = ModelActionTypeGet;
    [(SCPaypalExpressAPI *)[self getPaypalExpressAPI] getShippingMethod:self selector:@selector(didFinishRequest:responder:)];
}

- (SCPaypalExpressAPI *)getPaypalExpressAPI{
    NSString *className = [self.class description];
    Class api = NSClassFromString([className stringByReplacingOccurrencesOfString:@"Model" withString:@"API"]);
    SCPaypalExpressAPI *simiApi;
    if (api != nil) {
        simiApi = [api new];
    }else{
        simiApi = [[SCPaypalExpressAPI alloc] init];
    }
    return simiApi;
}

@end
