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
        _sharedInstance.padding = SCALEVALUE(15);
        _sharedInstance.lineSpacing = SCALEVALUE(10);
        _sharedInstance.interitemSpacing = SCALEVALUE(10);
        _sharedInstance.textPadding = SCALEVALUE(5);
    });
    return _sharedInstance;
}

- (SCPThemeConfigModel *)themeConfig{
    if(_themeConfig){
        return _themeConfig;
    }
    return [SCPThemeConfigModel new];
}

- (UITabBarController *)rootController{
    if(_rootController){
        return _rootController;
    }else{
        return [UITabBarController new];
    }
}

@end
