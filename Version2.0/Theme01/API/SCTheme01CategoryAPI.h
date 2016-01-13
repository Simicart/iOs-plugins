//
//  SCTheme01CategoryAPI.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/15/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiCategoryAPI.h>

@interface SCTheme01CategoryAPI : SimiCategoryAPI
- (void)getOrderCategoryWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

@end
