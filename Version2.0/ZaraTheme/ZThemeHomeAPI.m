//
//  ZThemeHomeAPI.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeHomeAPI.h"

@implementation ZThemeHomeAPI
- (void)getListCategoryWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@", kBaseURL, kZThemeGetHomeCategory];
    [self requestWithURL:urlPath params:params target:target selector:selector header:nil];
}
@end
