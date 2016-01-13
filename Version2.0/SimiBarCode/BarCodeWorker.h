//
//  BarCodeWorker.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 1/16/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimiCartBundle/SimiNavigationController.h>
#import <SimiCartBundle/SCMoreViewController.h>
#import "BarCodeViewController.h"

static NSString *LEFTMENU_SECTION_BARCODE = @"LEFTMENU_SECTION_BARCODE";
static NSString *LEFTMENU_ROW_BARCODE = @"LEFTMENU_ROW_BARCODE";

static NSString *THEME01_LISTMENU_SECTION_BARCODE = @"THEME01_LISTMENU_SECTION_BARCODE";
static NSString *THEME01_LISTMENU_ROW_BARCODE = @"THEME01_LISTMENU_ROW_BARCODE";

static NSString *MOREVIEW_SECTION_BARCODE = @"MOREVIEW_SECTION_BARCODE";
static NSString *MOREVIEW_ROW_BARCODE = @"MOREVIEW_ROW_BARCODE";
@interface BarCodeWorker : NSObject
@property (nonatomic, strong) SCLeftMenuView *leftMenu;
@property (nonatomic, strong) SimiNavigationBarWorker *simiNavigationBarWorker;
@property (nonatomic, strong) BarCodeViewController* barCodeViewController;
@end
