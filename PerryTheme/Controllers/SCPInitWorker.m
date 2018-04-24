//
//  SCPInitWorker.m
//  SimiCartPluginFW
//
//  Created by Liam on 4/18/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/InitWorker.h>
#import "SCPInitWorker.h"
#import "SCPGlobalVars.h"
#import "SCPNavigationBarPhone.h"
#import "SCPHomeViewController.h"
#import "SCPCategoryViewController.h"
#import "SCPSearchViewController.h"

@implementation SCPInitWorker
- (id)init{
    if(self == [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedRootController:) name:Simi_InitializedRootController object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginConfigureNavigationBar:) name:Simi_BeginConfigureNavigationBar object:nil];
    }
    return self;
}
- (void)initializedRootController:(NSNotification *)noti{
    [self setupThemeColors];
    InitWorker *initWorker = noti.object;
    initWorker.isDiscontinue = YES;
    [SCAppController sharedInstance].navigationBarPhone = [SCPNavigationBarPhone new];
    //Init the root view
    NSMutableArray *navigationControllers = [NSMutableArray new];
    UINavigationController *homeNavi = [[UINavigationController alloc] init];
    homeNavi.viewControllers = @[[SCPHomeViewController new]];
    homeNavi.tabBarItem = [[UITabBarItem alloc]initWithTitle:SCLocalizedString(@"Home") image:[[[UIImage imageNamed:@"scp_ic_home_tabbar"]imageWithColor:SCP_ICON_COLOR]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[[UIImage imageNamed:@"scp_ic_home_tabbar"]imageWithColor:SCP_ICON_HIGHLIGHT_COLOR]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    homeNavi.sortOrder = 10;
    [navigationControllers addObject:homeNavi];
    
    UINavigationController *categoryNavi = [[UINavigationController alloc] init];
    categoryNavi.viewControllers = @[[SCPCategoryViewController new]];
    categoryNavi.tabBarItem = [[UITabBarItem alloc]initWithTitle:SCLocalizedString(@"Category") image:[[[UIImage imageNamed:@"scp_ic_category_tabbar"]imageWithColor:SCP_ICON_COLOR]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[[UIImage imageNamed:@"scp_ic_category_tabbar"]imageWithColor:SCP_ICON_HIGHLIGHT_COLOR]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    categoryNavi.sortOrder = 20;
    [navigationControllers addObject:categoryNavi];
    
    UINavigationController *searchNavi = [[UINavigationController alloc] init];
    searchNavi.viewControllers = @[[SCPSearchViewController new]];
    searchNavi.tabBarItem = [[UITabBarItem alloc]initWithTitle:SCLocalizedString(@"Search") image:[[[UIImage imageNamed:@"scp_ic_search_tabbar"]imageWithColor:SCP_ICON_COLOR]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[[UIImage imageNamed:@"scp_ic_search_tabbar"]imageWithColor:SCP_ICON_HIGHLIGHT_COLOR]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    searchNavi.sortOrder = 30;
    [navigationControllers addObject:searchNavi];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SCP_EndCreateTabbarItems" object:navigationControllers];
    [navigationControllers sortUsingComparator:^NSComparisonResult(UINavigationController *firstNavi, UINavigationController *secondNavi) {
        if (secondNavi.sortOrder < firstNavi.sortOrder) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    initWorker.rootController.viewControllers = navigationControllers;
    for (UITabBarItem *tabbarItem in initWorker.rootController.tabBar.items) {
        [tabbarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:SCP_ICON_COLOR} forState:UIControlStateNormal];
        [tabbarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:SCP_ICON_HIGHLIGHT_COLOR} forState:UIControlStateHighlighted];
    }
}

- (void)setupThemeColors{
    SCP_GLOBALVARS.themeConfig = [[SCPThemeConfigModel alloc] initWithModelData:@{}];
}

- (void)beginConfigureNavigationBar:(NSNotification*)noti{
    SimiViewController *viewController = noti.object;
    viewController.isDiscontinue = YES;
}
@end
