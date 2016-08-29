//
//  BarCodeModel.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 1/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "BarCodeModel.h"
#import "BarCodeAPI.h"

@implementation BarCodeModel
- (void)getProductIdWithBarCode:(NSString *)barCode type:(NSString *)type
{
    currentNotificationName = BarCodeDidGetProductID;
    keyResponse = @"simibarcode";
    modelActionType = ModelActionTypeGet;
    [(BarCodeAPI *)[self getAPI] getProductIdWithBarCode:barCode type:type target:self selector:@selector(didFinishRequest:responder:)];
}
@end
