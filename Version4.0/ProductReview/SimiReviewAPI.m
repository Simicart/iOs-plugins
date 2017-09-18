//
//  SimiReviewAPI.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/14/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiReviewAPI.h"

@implementation SimiReviewAPI
- (void)getReviewCollectionWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL, kSimiReview];
    [self requestWithMethod:GET URL:url params:params target:target selector:selector header:nil];
}

@end
