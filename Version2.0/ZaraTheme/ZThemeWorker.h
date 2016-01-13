//
//  ZThemeWorker.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimiCartBundle/SimiNavigationController.h>

#import "ZThemeHomeViewController.h"
#import "ZThemeNavigationBar.h"
#import "ZThemeHomeViewControllerPad.h"
#import "ZThemeNavigationBarPad.h"

@interface ZThemeWorker : NSObject

+(ZThemeWorker *)sharedInstance;
@property (nonatomic, strong) UITabBarController *rootController;
@property (nonatomic, strong) ZThemeNavigationBarPad *navigationBarPad;
@property (nonatomic, strong) ZThemeNavigationBar *navigationBar;
@end
