//
//  SCTheme01ProductModelCollection.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/15/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCTheme01ProductModelCollection.h"
#import "SCTheme01ProductAPI.h"
@implementation SCTheme01ProductModelCollection
- (void)getSpotProductsWithKey:(NSString*)key limit:(NSString*)limit ofset:(NSString*)ofset width:(NSString*)width height:(NSString*)height sortOption:(NSInteger)sortOption
{
    modelActionType = ModelActionTypeInsert;
    currentNotificationName = @"SCTheme01-DidGetSpotProducts";
    NSString *stringSortOption = [NSString stringWithFormat:@"%ld",(long)sortOption];
    [(SCTheme01ProductAPI *)[self getAPI] getSpotProductsWithParams:@{@"key":key,@"limit":limit,@"offset":ofset,@"width":width,@"height":height,@"sort_option":stringSortOption} target:self selector:@selector(didFinishRequest:responder:)];
}
@end
