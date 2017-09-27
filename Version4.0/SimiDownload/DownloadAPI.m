//
//  DownLoadAPI.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 9/9/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "DownloadAPI.h"
NSString *const kSimiGetDownloadItems = @"downloadableproducts";
@implementation DownloadAPI
- (void)getDownloadItemsWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL, kSimiGetDownloadItems];
    [self requestWithMethod:GET URL:url params:params target:target selector:selector header:nil];
}
@end
