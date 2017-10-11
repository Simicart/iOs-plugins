//
//  SimiGiftCodeModel.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiGiftCodeModel.h"
#import "SimiGiftCodeAPI.h"

@implementation SimiGiftCodeModel
- (void)getGiftCodeDetailWithParams:(NSDictionary *)params{
    notificationName = DidGetGiftCodeDetail;
    self.parseKey = @"simigiftcode";
    [self preDoRequest];
    [[SimiGiftCodeAPI new]getGiftCodeDetailWithParams:params target:self selector:@selector(didGetResponseFromNetwork:)];
}
@end
