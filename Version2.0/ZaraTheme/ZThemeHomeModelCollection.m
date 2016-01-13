//
//  ZThemeHomeModelCollection.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeHomeModelCollection.h"

@implementation ZThemeHomeModelCollection
- (void)getListCategoryWithParams:(NSDictionary *)params
{
    modelActionType = ModelActionTypeGet;
    currentNotificationName = @"ZTheme-GetListCategories";
    [(ZThemeHomeAPI *)[self getAPI] getListCategoryWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}
@end
