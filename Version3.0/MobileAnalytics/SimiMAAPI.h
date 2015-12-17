//
//  SimiMAAPI.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/6/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiAPI.h>
@interface SimiMAAPI : SimiAPI
- (void)getGoogleAnalyticsIDWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
