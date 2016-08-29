//
//  KlarnaModelCollection.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "KlarnaAPI.h"
@interface KlarnaModelCollection : SimiModelCollection
- (void)getParamsKlarnaWithParams:(NSDictionary *)params;
- (void)checkoutKlarnaWithParams:(NSDictionary *)params;
@end
