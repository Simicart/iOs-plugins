//
//  KlarnaModel.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "KlarnaAPI.h"
@interface KlarnaModel : SimiModel
- (void)checkoutKlarnaWithParams:(NSDictionary *)params;
- (void)getParamsKlarnaWithParams:(NSDictionary *)params;
@end
