//
//  SCTheme01ProductAPI.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/15/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiProductAPI.h>

@interface SCTheme01ProductAPI : SimiProductAPI
- (void)getSpotProductsWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
