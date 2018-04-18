//
//  SCPGlobalVars.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 4/18/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPGlobalVars.h"

@implementation SCPGlobalVars

+ (instancetype)sharedInstance{
    static SCPGlobalVars *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SCPGlobalVars alloc] init];
    });
    return _sharedInstance;
}

- (SCPThemeConfigModel *)themeConfig{
    if(_themeConfig){
        return _themeConfig;
    }
    return [SCPThemeConfigModel new];
}
@end
