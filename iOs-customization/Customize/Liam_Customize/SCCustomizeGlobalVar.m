//
//  SCCustomizeGlobalVar.m
//  SimiCartPluginFW
//
//  Created by Liam on 4/25/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCustomizeGlobalVar.h"

@implementation SCCustomizeGlobalVar
+ (id)sharedInstance{
    static SCCustomizeGlobalVar *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SCCustomizeGlobalVar alloc] init];
        _sharedInstance.searchCache = [NSMutableDictionary new];
    });
    return _sharedInstance;
}
@end
