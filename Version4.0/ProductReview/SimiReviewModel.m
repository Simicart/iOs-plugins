//
//  SimiReviewModel.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/14/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiReviewModel.h"

@implementation SimiReviewModel
- (void)submitReviewForProductWithParams:(NSDictionary *)params{
    notificationName = DidSubmitProductReview;
    actionType = ModelActionTypeGet;
    self.resource = @"reviews";
    if (params.count > 0) {
        [self.body addEntriesFromDictionary:params];
    }
    self.method = MethodPost;
    [self preDoRequest];
    [self request];
}
@end
