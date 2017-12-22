//
//  SimiReviewModelCollection.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/14/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiReviewModelCollection.h"
#import "SimiReviewAPI.h"

@implementation SimiReviewModelCollection

- (void)getReviewCollectionWithProductId:(NSString *)productId offset:(NSInteger)offset limit:(NSInteger)limit{
    notificationName = @"DidGetReviewCollection";
    self.parseKey = @"reviews";
    self.resource = @"reviews";
    actionType = CollectionActionTypeInsert;
    [self addOffsetToParams:[NSString stringWithFormat:@"%ld",offset]];
    [self addLimitToParams:[NSString stringWithFormat:@"%ld",limit]];
    [self addFilterWithKey:@"product_id" value:productId];
    self.method = MethodGet;
    [self preDoRequest];
    [self request];
}

@end
