//
//  ZThemeHomeAPI.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "SimiGlobalVar+ZTheme.h"
@interface ZThemeHomeAPI : SimiAPI
- (void)getListCategoryWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
