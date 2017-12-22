//
//  KlarnaModel.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
static NSString *const Klarna_DidCheckoutWithKlarna = @"Klarna_DidCheckoutWithKlarna";
static NSString *const Klarna_DidGetKlarnaParam = @"Klarna_DidGetKlarnaParam";

@interface KlarnaModel : SimiModel
- (void)checkoutKlarnaWithParams:(NSDictionary *)params;
- (void)getParamsKlarnaWithParams:(NSDictionary *)params;
@end
