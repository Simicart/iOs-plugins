//
//  SCTheme01CategoryAPI.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/15/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCTheme01CategoryAPI.h"
#import "SimiGlobalVar+Theme01.h"

@implementation SCTheme01CategoryAPI
- (void)getOrderCategoryWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiTheme01GetOrderCategories];
    [self requestWithURL:urlPath params:params target:target selector:selector header:nil];
}
@end
