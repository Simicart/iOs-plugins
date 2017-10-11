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
    actionType = CollectionActionTypeInsert;
    [self preDoRequest];
    [[SimiReviewAPI new] getReviewCollectionWithParams:@{@"filter[product_id]": productId, @"offset": [NSString stringWithFormat:@"%ld", (long)offset], @"limit": [NSString stringWithFormat:@"%ld",(long)limit]} target:self selector:@selector(didGetResponseFromNetwork:)];
}

@end
