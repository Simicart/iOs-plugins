//
//  ZThemeProductAPI.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 5/8/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiProductAPI.h>

#import "SimiGlobalVar+ZTheme.h"

@interface ZThemeProductAPI : SimiProductAPI
- (void)getSpotProductsWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
