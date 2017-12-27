//
//  SimiTagModelCollection.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/27/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiTagModelCollection.h"

@implementation SimiTagModel
- (void)parseData{
    [super parseData];
    self.tagId = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"tag_id"]];
    self.simistorelocatorId = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"simistorelocator_id"]];
    self.value = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"value"]];
}
@end

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
