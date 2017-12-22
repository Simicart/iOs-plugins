//
//  KlarnaModel.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "KlarnaModel.h"

@implementation KlarnaModel
- (void)checkoutKlarnaWithParams:(NSDictionary *)params{
    self.parseKey = @"simiklarnaapi";
    notificationName = Klarna_DidCheckoutWithKlarna;
    self.resource = @"simiklarnaapis/push";
    if (params.count > 0) {
        [self.params addEntriesFromDictionary:params];
    }
    self.method = MethodGet;
    [self request];
}

- (void)getParamsKlarnaWithParams:(NSDictionary *)params{
    notificationName = Klarna_DidGetKlarnaParam;
    self.parseKey = @"simiklarnaapi";
    self.resource =  @"simiklarnaapis/get_params";
    if (params.count > 0) {
        [self.params addEntriesFromDictionary:params];
    }
    self.method = MethodGet;
    [self request];
}
@end
