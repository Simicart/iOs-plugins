//
//  ZThemeHomeModelCollection.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

#import "ZThemeHomeAPI.h"
@interface ZThemeHomeModelCollection : SimiModelCollection
- (void)getListCategoryWithParams:(NSDictionary *)params;
@end
