//
//  SCTheme01ProductAPI.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/15/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCTheme01ProductAPI.h"
#import "SimiGlobalVar+Theme01.h"

@implementation SCTheme01ProductAPI
- (void)getSpotProductsWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiTheme01GetSpotProducts];
    [self requestWithURL:urlPath params:params target:target selector:selector header:nil];
}
@end
