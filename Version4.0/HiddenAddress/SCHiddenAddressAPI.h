//
//  SCHiddenAddressAPI.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/4/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SCHiddenAddressAPI : SimiAPI
- (void)getAddressHideWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
