//
//  SimiStoreLocatorModelCollection.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/26/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiStoreLocatorModelCollection.h"

@implementation SimiStoreLocatorModelCollection
- (void)getStoreListWithLatitude:(NSString*)lat longitude:(NSString*)lng offset:(NSString*)offset limit:(NSString*)limit
{
    currentNotificationName = @"StoreLocator_DidGetStoreList";
    keyResponse = @"storelocations";
    [self preDoRequest];
    modelActionType = ModelActionTypeInsert;
    [(SimiStoreLocatorAPI *)[self getAPI] getStoreListWithParams:@{@"lat":lat,@"lng":lng,@"offset":offset,@"limit":limit} target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)getStoreListWithLatitude:(NSString *)lat longitude:(NSString *)lng offset:(NSString *)offset limit:(NSString *)limit country:(NSString*)country city:(NSString*)city state:(NSString*)state zipcode:(NSString*)zipcode tag:(NSString *)tag
{
    currentNotificationName = @"StoreLocator_DidGetStoreList";
    keyResponse = @"storelocations";
    modelActionType = ModelActionTypeInsert;
    [self preDoRequest];
    [(SimiStoreLocatorAPI *)[self getAPI] getStoreListWithParams:@{@"lat":lat,@"lng":lng,@"offset":offset,@"limit":limit,@"country":country,@"city":city,@"state":state,@"zipcode":zipcode,@"tag":tag} target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)getStoreListWithLatitude:(NSString *)lat longitude:(NSString *)lng offset:(NSString *)offset limit:(NSString *)limit country:(NSString*)country city:(NSString*)city state:(NSString*)state storeName:(NSString*)storeName tag:(NSString *)tag
{
    currentNotificationName = @"StoreLocator_DidGetStoreList";
    keyResponse = @"storelocations";
    modelActionType = ModelActionTypeInsert;
    [self preDoRequest];
    [(SimiStoreLocatorAPI *)[self getAPI] getStoreListWithParams:@{@"lat":lat,@"lng":lng,@"offset":offset,@"limit":limit,@"country":country?country:@"",@"city":city?city:@"",@"state":state?state:@"",@"store_name":storeName?storeName:@"",@"tag":tag?tag:@""} target:self selector:@selector(didFinishRequest:responder:)];
}


- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder{
    [super didFinishRequest:responseObject responder:responder];
    NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
    if([[responseObjectData objectForKey:@"search_configs"] isKindOfClass:[NSArray class]]){
        [SimiGlobalVar sharedInstance].searchConfigs = [responseObjectData objectForKey:@"search_configs"];
    }
}

@end
