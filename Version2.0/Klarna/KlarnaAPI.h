//
//  KlarnaAPI.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiAPI.h>
extern NSString *const kSimiGetParamsKlarna;
extern NSString *const kSimiCheckoutWithKlarna;
@interface KlarnaAPI : SimiAPI
- (void)getParamsKlarnaWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
- (void)checkoutKlarnaWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
