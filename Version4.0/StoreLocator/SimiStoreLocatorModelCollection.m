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
     notificationName = @"StoreLocator_DidGetStoreList";
    self.parseKey = @"storelocations";
    [self preDoRequest];
    actionType = CollectionActionTypeInsert;
    [[SimiStoreLocatorAPI new] getStoreListWithParams:@{@"lat":lat,@"lng":lng,@"offset":offset,@"limit":limit} target:self selector:@selector(didGetResponseFromNetwork:)];
}

- (void)getStoreListWithLatitude:(NSString *)lat longitude:(NSString *)lng offset:(NSString *)offset limit:(NSString *)limit country:(NSString*)country city:(NSString*)city state:(NSString*)state zipcode:(NSString*)zipcode tag:(NSString *)tag
{
    notificationName = @"StoreLocator_DidGetStoreList";
    self.parseKey = @"storelocations";
    actionType = CollectionActionTypeInsert;
    [self preDoRequest];
    [[SimiStoreLocatorAPI new] getStoreListWithParams:@{@"lat":lat,@"lng":lng,@"offset":offset,@"limit":limit,@"country":country,@"city":city,@"state":state,@"zipcode":zipcode,@"tag":tag} target:self selector:@selector(didGetResponseFromNetwork:)];
}
@end
