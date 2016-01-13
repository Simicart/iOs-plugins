//
//  SCWishlistModelCollection.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 11/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCPaypalExpressModel.h"

@implementation SCPaypalExpressModel


- (void)startPaypalExpress
{
    currentNotificationName = @"DidStartPaypalExpress";
    [self preDoRequest];
    modelActionType = ModelActionTypeGet;
    [(SCPaypalExpressAPI *)[self getPaypalExpressAPI] startPaypalExpress:self selector:@selector(didFinishRequest:responder:)];
}

- (void)reviewAddress
{
    currentNotificationName = @"DidGetPaypalAdressInformation";
    [self preDoRequest];
    modelActionType = ModelActionTypeGet;
    [(SCPaypalExpressAPI *)[self getPaypalExpressAPI] reviewAddress:self selector:@selector(didFinishRequest:responder:)];
}

- (void)placeOrderWithParam:(NSDictionary *)params{
    modelActionType = ModelActionTypeGet;
    currentNotificationName = @"DidPlaceOrder-After";
    [self preDoRequest];
    [(SCPaypalExpressAPI *)[self getPaypalExpressAPI] placeOrderWithParam:params target:self selector:@selector(didFinishRequest:responder:)];
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
