//
//  ZThemeProductAPI.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 5/8/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeProductAPI.h"

@implementation ZThemeProductAPI
- (void)getSpotProductsWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@", kBaseURL, kZThemeGetSpotProducts];
    [self requestWithURL:urlPath params:params target:target selector:selector header:nil];
}
@end
