//
//  SCTheme01SpotProductAPI.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/15/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiAPI.h>

@interface SCTheme01SpotProductAPI : SimiAPI
- (void)getOrderSpotsWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
