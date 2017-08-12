//
//  SCGiftCardGlobalVar.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/11/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCGiftCardGlobalVar.h"

@implementation SCGiftCardGlobalVar
+ (id)sharedInstance{
    static SCGiftCardGlobalVar *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SCGiftCardGlobalVar alloc] init];
    });
    return _sharedInstance;
}
@end
