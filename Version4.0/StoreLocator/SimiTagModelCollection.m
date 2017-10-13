//
//  SimiTagModelCollection.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/27/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiTagModelCollection.h"
#import "SimiTagAPI.h"

@implementation SimiTagModelCollection
- (void)getTagWithOffset:(NSString*)offset limit:(NSString*)limit{
    notificationName = @"DidFinishGetTagList";
    actionType = CollectionActionTypeInsert;
    self.parseKey = @"storelocatortags";
    [self preDoRequest];
    [[SimiTagAPI new] getTagListWithParams:@{@"offset":offset,@"limit":limit} target:self selector:@selector(didGetResponseFromNetwork:)];
}
@end
