//
//  SimiThemeWorker.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/13/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimiCartBundle/SimiNavigationController.h>

#import "SCNavigationBar_Theme01.h"
#import "SCNavigationBarPad_Theme01.h"
#import "SCHomeViewController_Theme01.h"
#import "SCHomeViewControllerPad_Theme01.h"
#import "SCGridViewControllerPad_Theme01.h"
#import "SCCategoryViewController_Theme01.h"
#import "SCGridViewController_Theme01.h"

@interface SimiThemeWorker : NSObject

+ (SimiThemeWorker *)sharedInstance;
@property (nonatomic, strong) SCNavigationBar_Theme01 *navigationBar;
@property (nonatomic, strong) SCNavigationBarPad_Theme01 *navigationBarPad;
@property (nonatomic, strong) UITabBarController *rootController;
@end
