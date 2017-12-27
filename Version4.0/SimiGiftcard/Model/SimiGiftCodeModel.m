//
//  SimiGiftCodeModel.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiGiftCodeModel.h"

@implementation SimiGiftCodeModel
- (void)getGiftCodeDetailWithParams:(NSDictionary *)params{
    notificationName = DidGetGiftCodeDetail;
    self.parseKey = @"simigiftcode";
    self.resource = @"simigiftcodes";
    [self addExtendsUrlWithKey:[params valueForKey:@"id"]];
    if (params.count > 0) {
        [self.params addEntriesFromDictionary:params];
        [self.params removeObjectForKey:@"id"];
    }
    self.method = MethodGet;
    [self preDoRequest];
    [self request];
}
@end
