//
//  SimiTagModelCollection.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/27/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiTagModelCollection.h"

@implementation SimiTagModelCollection
- (void)getTagWithOffset:(NSString*)offset limit:(NSString*)limit{
    notificationName = @"DidFinishGetTagList";
    actionType = CollectionActionTypeInsert;
    self.parseKey = @"storelocatortags";
    self.resource = @"storelocatortags";
    [self addOffsetToParams:offset];
    [self addLimitToParams:limit];
    self.method = MethodGet;
    [self preDoRequest];
    [self request];
}
@end
