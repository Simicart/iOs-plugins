//
//  SimiStoreLocatorModelCollection.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/26/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiStoreLocatorModelCollection.h"

@implementation SimiStoreLocatorModelCollection

- (void)getStoreListWithLatitude:(NSString*)lat longitude:(NSString*)lng offset:(NSString*)offset limit:(NSString*)limit{
    notificationName = StoreLocator_DidGetStoreList;
    actionType = CollectionActionTypeInsert;
    self.parseKey = @"storelocations";
    self.resource = @"storelocations";
    [self.params addEntriesFromDictionary:@{@"lat":lat,@"lng":lng,@"offset":offset,@"limit":limit}];
    self.method = MethodGet;
    [self preDoRequest];
    [self request];
}

- (void)getStoreListWithLatitude:(NSString *)lat longitude:(NSString *)lng offset:(NSString *)offset limit:(NSString *)limit country:(NSString*)country city:(NSString*)city state:(NSString*)state zipcode:(NSString*)zipcode tag:(NSString *)tag
{
    notificationName = StoreLocator_DidGetStoreList;
    actionType = CollectionActionTypeInsert;
    self.parseKey = @"storelocations";
    self.resource = @"storelocations";
    [self.params addEntriesFromDictionary:@{@"lat":lat,@"lng":lng,@"offset":offset,@"limit":limit,@"country":country,@"city":city,@"state":state,@"zipcode":zipcode,@"tag":tag}];
    self.method = MethodGet;
    [self preDoRequest];
    [self request];
}
@end
