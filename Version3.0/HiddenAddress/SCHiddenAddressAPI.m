//
//  SCHiddenAddressAPI.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/4/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCHiddenAddressAPI.h"
#import "SimiGlobalVar+SCHiddenAddress.h"
@implementation SCHiddenAddressAPI
- (void)getAddressHideWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSCHiddenAddress_GetAddressHide];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}
@end
