//
//  SCHiddenAddressModel.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/4/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCHiddenAddressModel.h"
#import "SCHiddenAddressAPI.h"
@implementation SCHiddenAddressModel
- (void)getAddressHideWithParams:(NSDictionary *)params
{
    currentNotificationName = @"SCHiddenAddress_DidGetAddressHide";
    modelActionType = ModelActionTypeEdit;
    [(SCHiddenAddressAPI *)[self getAPI] getAddressHideWithParams:@{} target:self selector:@selector(didFinishRequest:responder:)];
}
@end
