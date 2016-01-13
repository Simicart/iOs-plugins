//
//  SCTheme01CategoryModelCollection.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/15/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCTheme01CategoryModelCollection.h"
#import "SCTheme01CategoryAPI.h"
@implementation SCTheme01CategoryModelCollection
- (void)getOrderCategoryWithParams:(NSDictionary *)params;
{
    modelActionType = ModelActionTypeGet;
    currentNotificationName = @"SCTheme01-DidGetOrderCategory";
    [(SCTheme01CategoryAPI *)[self getAPI] getOrderCategoryWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}
@end
