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
    currentNotificationName = @"DidGetReviewCollection";
    keyResponse = @"reviews";
    modelActionType = ModelActionTypeInsert;
    [self preDoRequest];
    [(SimiReviewAPI *)[self getAPI] getReviewCollectionWithParams:@{@"filter[product_id]": productId, @"offset": [NSString stringWithFormat:@"%ld", (long)offset], @"limit": [NSString stringWithFormat:@"%ld",(long)limit],@"fields":@"review_id,created_at,title,detail,nickname,rate_points",@"order":@"entity_id",@"dir":@"desc"} target:self selector:@selector(didFinishRequest:responder:)];
}

@end
