//
//  SCVideoModelCollecion.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/29/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCVideoModelCollection.h"

#define kGetVideoForProductURL @"simiconnector/rest/v2/simivideos"

@implementation SCVideoModelCollection
-(void) getVideosForProductWithID:(NSString *)productID{
    currentNotificationName = DidGetVideosForProduct;
    keyResponse = @"simivideos";
    modelActionType = ModelActionTypeGet;
    NSString* url = [NSString stringWithFormat:@"%@%@",kBaseURL,kGetVideoForProductURL];
    [[SimiAPI new] requestWithMethod:@"GET" URL:url params:@{@"product_id":productID} target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
@end
