//
//  SimiReviewModel.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/14/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiReviewModel.h"

#define kSubmitReviewURL @"simiconnector/rest/v2/reviews/"

@implementation SimiReviewModel

- (void)submitReviewForProductWithParams:(NSDictionary *) params{
    notificationName = DidSubmitProductReview;
    actionType = ModelActionTypeGet;
    [self preDoRequest];
    [[SimiAPI new] requestWithMethod:POST URL:[NSString stringWithFormat:@"%@%@",kBaseURL,kSubmitReviewURL] params:params target:self selector:@selector(didGetResponseFromNetwork:) header:nil];
}
@end
