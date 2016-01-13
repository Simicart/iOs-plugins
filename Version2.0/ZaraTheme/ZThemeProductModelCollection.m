//
//  ZThemeProductModelCollection.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 5/8/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeProductModelCollection.h"
#import "ZThemeProductAPI.h"
@implementation ZThemeProductModelCollection
- (void)getSpotProductsWithKey:(NSString*)key limit:(NSString*)limit ofset:(NSString*)ofset width:(NSString*)width height:(NSString*)height sortOption:(NSInteger)sortOption
{
    modelActionType = ModelActionTypeInsert;
    currentNotificationName = @"SCTheme01-DidGetSpotProducts";
    NSString *stringSortOption = [NSString stringWithFormat:@"%ld",(long)sortOption];
    [(ZThemeProductAPI *)[self getAPI] getSpotProductsWithParams:@{@"key":key,@"limit":limit,@"offset":ofset,@"width":width,@"height":height,@"sort_option":stringSortOption} target:self selector:@selector(didFinishRequest:responder:)];
}
@end
