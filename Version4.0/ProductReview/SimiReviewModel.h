//
//  SimiReviewModel.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/14/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiModel.h"

#define DidSubmitProductReview @"DidSubmitProductReview"

@interface SimiReviewModel : SimiModel

- (void)submitReviewForProductWithParams:(NSDictionary *) params;

@end
