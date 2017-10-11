//
//  KlarnaModel.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "KlarnaModel.h"
#import "KlarnaAPI.h"

@implementation KlarnaModel
- (void)checkoutKlarnaWithParams:(NSDictionary *)params{
    self.parseKey = @"simiklarnaapi";
    notificationName = Klarna_DidCheckoutWithKlarna;
    [[KlarnaAPI new] checkoutKlarnaWithParams:params target:self selector:@selector(didGetResponseFromNetwork:)];
}

- (void)getParamsKlarnaWithParams:(NSDictionary *)params{
    notificationName = Klarna_DidGetKlarnaParam;
    self.parseKey = @"simiklarnaapi";
    [[KlarnaAPI new] getParamsKlarnaWithParams:params target:self selector:@selector(didGetResponseFromNetwork:)];
}
@end
