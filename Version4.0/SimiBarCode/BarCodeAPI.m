//
//  BarCodeAPI.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 1/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "BarCodeAPI.h"
NSString *const kBarCodeGetProductID = @"simiconnector/rest/v2/simibarcodes/";

@implementation BarCodeAPI
- (void)getProductIdWithBarCode:(NSString *)barCode type:(NSString*) type target:(id)target selector:(SEL)selector{
    url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kBarCodeGetProductID,barCode];
    [self requestWithMethod:@"GET" URL:url params:@{@"type":type} target:target selector:selector header:nil];
}
@end
