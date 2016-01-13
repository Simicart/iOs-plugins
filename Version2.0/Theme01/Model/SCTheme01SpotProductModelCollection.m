//
//  SCTheme01SpotProductModelCollection.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/15/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCTheme01SpotProductModelCollection.h"
#import "SCTheme01SpotProductAPI.h"

@implementation SCTheme01SpotProductModelCollection

- (void)getOrderSpotsWithParams:(NSDictionary *)params
{
    modelActionType = ModelActionTypeGet;
    currentNotificationName = @"SCTheme01-DidGetOrderSpots";
    [(SCTheme01SpotProductAPI *)[self getAPI] getOrderSpotsWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}
@end
