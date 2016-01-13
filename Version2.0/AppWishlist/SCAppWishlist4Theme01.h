//
//  SCAppWishlist4Theme01.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/4/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCAppWishlist.h"


static NSString *THEME01_SIMIOBJECT_MYWISHLIST = @"THEME01_SIMIOBJECT_MYWISHLIST";
static NSString *THEME01_ACCOUNT_CELL = @"THEME01_ACCOUNT_CELL";

@interface SCAppWishlist4Theme01 : NSObject <UIPopoverControllerDelegate>

#pragma mark flags

@property (nonatomic) BOOL actived;


@property (strong, nonatomic) UIImageView * imageView4Theme;;
@property (weak, nonatomic) SCAppWishlist * appwishlistCoreWorker;
@property (strong, nonatomic) SimiRow * listMenuViewRow;
@property (strong, nonatomic) NSString * iconImagePath;

-(void)viewControllerDidLoad: (NSNotification *)noti;
-(void)pushWishlistViewController;

@end
