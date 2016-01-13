//
//  SCAppWishlist4iPad.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/5/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCAppWishlist.h"
#import "AppWishlistiPadViewController.h"


static NSString * MY_WISHLIST_ROW_IPAD    = @"mywishlist";

@interface SCAppWishlist4iPad : NSObject

#pragma mark flags

@property (nonatomic) BOOL actived;

@property (weak, nonatomic) SCAppWishlist * appwishlistCoreWorker;
@property (strong, nonatomic) NSMutableArray * productViewControllerMap;
@property (strong, nonatomic) AppWishlistiPadViewController * appWishlistPadView;


-(void)viewControllerDidLoad: (NSNotification *)noti;
-(BOOL)clickedAddToWishlist: (UIButton*)button;
-(BOOL)clickedRemoveFromWishlist:(UIButton *)button;
-(void)updateCurrentProductIdOnWishlist: (UIImageView *)image :(NSString *)id;


@end
