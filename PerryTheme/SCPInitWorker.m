//
//  SCPInitWorker.m
//  SimiCartPluginFW
//
//  Created by Liam on 4/18/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPInitWorker.h"
#import "SCPGlobalVars.h"
#import <SimiCartBundle/InitWorker.h>
#import "SCPNavigationBarPhone.h"
#import "SCPHomeViewController.h"

@implementation SCPInitWorker
- (id)init{
    if(self == [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedRootController:) name:Simi_InitializedRootController object:nil];
    }
    return self;
}
- (void)initializedRootController:(NSNotification *)noti{
    if([[GLOBALVAR.appConfigModel objectForKey:@"perry_theme"] isKindOfClass:[NSDictionary class]]){
        [self setupThemeColors];
        InitWorker *initWorker = noti.object;
        initWorker.rootController.tabBar.hidden = YES;
        initWorker.isDiscontinue = YES;
        [SCAppController sharedInstance].navigationBarPhone = [SCPNavigationBarPhone new];
        //Init the root view
        UINavigationController *homeNavi = [[UINavigationController alloc] init];
        homeNavi.viewControllers = @[[SCPHomeViewController new]];
        initWorker.rootController.viewControllers = @[homeNavi];
    }
}
- (void)setupThemeColors{
    SCP_GLOBALVARS.themeConfig = [[SCPThemeConfigModel alloc] initWithModelData:[GLOBALVAR.appConfigModel objectForKey:@"perry_theme"]];
}
@end
